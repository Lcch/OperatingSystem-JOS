
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
  80003a:	c7 05 00 30 80 00 80 	movl   $0x801d80,0x803000
  800041:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 4c 01 00 00       	call   800195 <sys_yield>
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
  800057:	e8 15 01 00 00       	call   800171 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	29 d0                	sub    %edx,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 f6                	test   %esi,%esi
  800079:	7e 07                	jle    800082 <libmain+0x36>
		binaryname = argv[0];
  80007b:	8b 03                	mov    (%ebx),%eax
  80007d:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	53                   	push   %ebx
  800086:	56                   	push   %esi
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	c9                   	leave  
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a2:	e8 5f 04 00 00       	call   800506 <close_all>
	sys_env_destroy(0);
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 9e 00 00 00       	call   80014f <sys_env_destroy>
  8000b1:	83 c4 10             	add    $0x10,%esp
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	83 ec 1c             	sub    $0x1c,%esp
  8000c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000c7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d5:	cd 30                	int    $0x30
  8000d7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000dd:	74 1c                	je     8000fb <syscall+0x43>
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	7e 18                	jle    8000fb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	50                   	push   %eax
  8000e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ea:	68 8f 1d 80 00       	push   $0x801d8f
  8000ef:	6a 42                	push   $0x42
  8000f1:	68 ac 1d 80 00       	push   $0x801dac
  8000f6:	e8 b5 0e 00 00       	call   800fb0 <_panic>

	return ret;
}
  8000fb:	89 d0                	mov    %edx,%eax
  8000fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010b:	6a 00                	push   $0x0
  80010d:	6a 00                	push   $0x0
  80010f:	6a 00                	push   $0x0
  800111:	ff 75 0c             	pushl  0xc(%ebp)
  800114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800117:	ba 00 00 00 00       	mov    $0x0,%edx
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 92 ff ff ff       	call   8000b8 <syscall>
  800126:	83 c4 10             	add    $0x10,%esp
	return;
}
  800129:	c9                   	leave  
  80012a:	c3                   	ret    

0080012b <sys_cgetc>:

int
sys_cgetc(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800131:	6a 00                	push   $0x0
  800133:	6a 00                	push   $0x0
  800135:	6a 00                	push   $0x0
  800137:	6a 00                	push   $0x0
  800139:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 01 00 00 00       	mov    $0x1,%eax
  800148:	e8 6b ff ff ff       	call   8000b8 <syscall>
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	6a 00                	push   $0x0
  80015b:	6a 00                	push   $0x0
  80015d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800160:	ba 01 00 00 00       	mov    $0x1,%edx
  800165:	b8 03 00 00 00       	mov    $0x3,%eax
  80016a:	e8 49 ff ff ff       	call   8000b8 <syscall>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800184:	ba 00 00 00 00       	mov    $0x0,%edx
  800189:	b8 02 00 00 00       	mov    $0x2,%eax
  80018e:	e8 25 ff ff ff       	call   8000b8 <syscall>
}
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <sys_yield>:

void
sys_yield(void)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ad:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b2:	e8 01 ff ff ff       	call   8000b8 <syscall>
  8001b7:	83 c4 10             	add    $0x10,%esp
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c2:	6a 00                	push   $0x0
  8001c4:	6a 00                	push   $0x0
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cf:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d9:	e8 da fe ff ff       	call   8000b8 <syscall>
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001e6:	ff 75 18             	pushl  0x18(%ebp)
  8001e9:	ff 75 14             	pushl  0x14(%ebp)
  8001ec:	ff 75 10             	pushl  0x10(%ebp)
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ff:	e8 b4 fe ff ff       	call   8000b8 <syscall>
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80020c:	6a 00                	push   $0x0
  80020e:	6a 00                	push   $0x0
  800210:	6a 00                	push   $0x0
  800212:	ff 75 0c             	pushl  0xc(%ebp)
  800215:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800218:	ba 01 00 00 00       	mov    $0x1,%edx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	e8 91 fe ff ff       	call   8000b8 <syscall>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80022f:	6a 00                	push   $0x0
  800231:	6a 00                	push   $0x0
  800233:	6a 00                	push   $0x0
  800235:	ff 75 0c             	pushl  0xc(%ebp)
  800238:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023b:	ba 01 00 00 00       	mov    $0x1,%edx
  800240:	b8 08 00 00 00       	mov    $0x8,%eax
  800245:	e8 6e fe ff ff       	call   8000b8 <syscall>
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800252:	6a 00                	push   $0x0
  800254:	6a 00                	push   $0x0
  800256:	6a 00                	push   $0x0
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025e:	ba 01 00 00 00       	mov    $0x1,%edx
  800263:	b8 09 00 00 00       	mov    $0x9,%eax
  800268:	e8 4b fe ff ff       	call   8000b8 <syscall>
}
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800275:	6a 00                	push   $0x0
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800281:	ba 01 00 00 00       	mov    $0x1,%edx
  800286:	b8 0a 00 00 00       	mov    $0xa,%eax
  80028b:	e8 28 fe ff ff       	call   8000b8 <syscall>
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800298:	6a 00                	push   $0x0
  80029a:	ff 75 14             	pushl  0x14(%ebp)
  80029d:	ff 75 10             	pushl  0x10(%ebp)
  8002a0:	ff 75 0c             	pushl  0xc(%ebp)
  8002a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b0:	e8 03 fe ff ff       	call   8000b8 <syscall>
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	6a 00                	push   $0x0
  8002c3:	6a 00                	push   $0x0
  8002c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002cd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002d2:	e8 e1 fd ff ff       	call   8000b8 <syscall>
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002df:	6a 00                	push   $0x0
  8002e1:	6a 00                	push   $0x0
  8002e3:	6a 00                	push   $0x0
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002f5:	e8 be fd ff ff       	call   8000b8 <syscall>
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	05 00 00 00 30       	add    $0x30000000,%eax
  800307:	c1 e8 0c             	shr    $0xc,%eax
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 e5 ff ff ff       	call   8002fc <fd2num>
  800317:	83 c4 04             	add    $0x4,%esp
  80031a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80031f:	c1 e0 0c             	shl    $0xc,%eax
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	53                   	push   %ebx
  800328:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80032b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800330:	a8 01                	test   $0x1,%al
  800332:	74 34                	je     800368 <fd_alloc+0x44>
  800334:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800339:	a8 01                	test   $0x1,%al
  80033b:	74 32                	je     80036f <fd_alloc+0x4b>
  80033d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800342:	89 c1                	mov    %eax,%ecx
  800344:	89 c2                	mov    %eax,%edx
  800346:	c1 ea 16             	shr    $0x16,%edx
  800349:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800350:	f6 c2 01             	test   $0x1,%dl
  800353:	74 1f                	je     800374 <fd_alloc+0x50>
  800355:	89 c2                	mov    %eax,%edx
  800357:	c1 ea 0c             	shr    $0xc,%edx
  80035a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800361:	f6 c2 01             	test   $0x1,%dl
  800364:	75 17                	jne    80037d <fd_alloc+0x59>
  800366:	eb 0c                	jmp    800374 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800368:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80036d:	eb 05                	jmp    800374 <fd_alloc+0x50>
  80036f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800374:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800376:	b8 00 00 00 00       	mov    $0x0,%eax
  80037b:	eb 17                	jmp    800394 <fd_alloc+0x70>
  80037d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800382:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800387:	75 b9                	jne    800342 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800389:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80038f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800394:	5b                   	pop    %ebx
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80039d:	83 f8 1f             	cmp    $0x1f,%eax
  8003a0:	77 36                	ja     8003d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003a7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003aa:	89 c2                	mov    %eax,%edx
  8003ac:	c1 ea 16             	shr    $0x16,%edx
  8003af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b6:	f6 c2 01             	test   $0x1,%dl
  8003b9:	74 24                	je     8003df <fd_lookup+0x48>
  8003bb:	89 c2                	mov    %eax,%edx
  8003bd:	c1 ea 0c             	shr    $0xc,%edx
  8003c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c7:	f6 c2 01             	test   $0x1,%dl
  8003ca:	74 1a                	je     8003e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8003d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d6:	eb 13                	jmp    8003eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dd:	eb 0c                	jmp    8003eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e4:	eb 05                	jmp    8003eb <fd_lookup+0x54>
  8003e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003eb:	c9                   	leave  
  8003ec:	c3                   	ret    

008003ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	53                   	push   %ebx
  8003f1:	83 ec 04             	sub    $0x4,%esp
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003fa:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800400:	74 0d                	je     80040f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800402:	b8 00 00 00 00       	mov    $0x0,%eax
  800407:	eb 14                	jmp    80041d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800409:	39 0a                	cmp    %ecx,(%edx)
  80040b:	75 10                	jne    80041d <dev_lookup+0x30>
  80040d:	eb 05                	jmp    800414 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80040f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800414:	89 13                	mov    %edx,(%ebx)
			return 0;
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	eb 31                	jmp    80044e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80041d:	40                   	inc    %eax
  80041e:	8b 14 85 38 1e 80 00 	mov    0x801e38(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	75 e0                	jne    800409 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800429:	a1 04 40 80 00       	mov    0x804004,%eax
  80042e:	8b 40 48             	mov    0x48(%eax),%eax
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	51                   	push   %ecx
  800435:	50                   	push   %eax
  800436:	68 bc 1d 80 00       	push   $0x801dbc
  80043b:	e8 48 0c 00 00       	call   801088 <cprintf>
	*dev = 0;
  800440:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80044e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800451:	c9                   	leave  
  800452:	c3                   	ret    

00800453 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 20             	sub    $0x20,%esp
  80045b:	8b 75 08             	mov    0x8(%ebp),%esi
  80045e:	8a 45 0c             	mov    0xc(%ebp),%al
  800461:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800464:	56                   	push   %esi
  800465:	e8 92 fe ff ff       	call   8002fc <fd2num>
  80046a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80046d:	89 14 24             	mov    %edx,(%esp)
  800470:	50                   	push   %eax
  800471:	e8 21 ff ff ff       	call   800397 <fd_lookup>
  800476:	89 c3                	mov    %eax,%ebx
  800478:	83 c4 08             	add    $0x8,%esp
  80047b:	85 c0                	test   %eax,%eax
  80047d:	78 05                	js     800484 <fd_close+0x31>
	    || fd != fd2)
  80047f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800482:	74 0d                	je     800491 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800484:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800488:	75 48                	jne    8004d2 <fd_close+0x7f>
  80048a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048f:	eb 41                	jmp    8004d2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800497:	50                   	push   %eax
  800498:	ff 36                	pushl  (%esi)
  80049a:	e8 4e ff ff ff       	call   8003ed <dev_lookup>
  80049f:	89 c3                	mov    %eax,%ebx
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	78 1c                	js     8004c4 <fd_close+0x71>
		if (dev->dev_close)
  8004a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ab:	8b 40 10             	mov    0x10(%eax),%eax
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	74 0d                	je     8004bf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004b2:	83 ec 0c             	sub    $0xc,%esp
  8004b5:	56                   	push   %esi
  8004b6:	ff d0                	call   *%eax
  8004b8:	89 c3                	mov    %eax,%ebx
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb 05                	jmp    8004c4 <fd_close+0x71>
		else
			r = 0;
  8004bf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	56                   	push   %esi
  8004c8:	6a 00                	push   $0x0
  8004ca:	e8 37 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  8004cf:	83 c4 10             	add    $0x10,%esp
}
  8004d2:	89 d8                	mov    %ebx,%eax
  8004d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e4:	50                   	push   %eax
  8004e5:	ff 75 08             	pushl  0x8(%ebp)
  8004e8:	e8 aa fe ff ff       	call   800397 <fd_lookup>
  8004ed:	83 c4 08             	add    $0x8,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 10                	js     800504 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	6a 01                	push   $0x1
  8004f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8004fc:	e8 52 ff ff ff       	call   800453 <fd_close>
  800501:	83 c4 10             	add    $0x10,%esp
}
  800504:	c9                   	leave  
  800505:	c3                   	ret    

00800506 <close_all>:

void
close_all(void)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	53                   	push   %ebx
  80050a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80050d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800512:	83 ec 0c             	sub    $0xc,%esp
  800515:	53                   	push   %ebx
  800516:	e8 c0 ff ff ff       	call   8004db <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80051b:	43                   	inc    %ebx
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 fb 20             	cmp    $0x20,%ebx
  800522:	75 ee                	jne    800512 <close_all+0xc>
		close(i);
}
  800524:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800527:	c9                   	leave  
  800528:	c3                   	ret    

00800529 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800529:	55                   	push   %ebp
  80052a:	89 e5                	mov    %esp,%ebp
  80052c:	57                   	push   %edi
  80052d:	56                   	push   %esi
  80052e:	53                   	push   %ebx
  80052f:	83 ec 2c             	sub    $0x2c,%esp
  800532:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800535:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800538:	50                   	push   %eax
  800539:	ff 75 08             	pushl  0x8(%ebp)
  80053c:	e8 56 fe ff ff       	call   800397 <fd_lookup>
  800541:	89 c3                	mov    %eax,%ebx
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	85 c0                	test   %eax,%eax
  800548:	0f 88 c0 00 00 00    	js     80060e <dup+0xe5>
		return r;
	close(newfdnum);
  80054e:	83 ec 0c             	sub    $0xc,%esp
  800551:	57                   	push   %edi
  800552:	e8 84 ff ff ff       	call   8004db <close>

	newfd = INDEX2FD(newfdnum);
  800557:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80055d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800560:	83 c4 04             	add    $0x4,%esp
  800563:	ff 75 e4             	pushl  -0x1c(%ebp)
  800566:	e8 a1 fd ff ff       	call   80030c <fd2data>
  80056b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80056d:	89 34 24             	mov    %esi,(%esp)
  800570:	e8 97 fd ff ff       	call   80030c <fd2data>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057b:	89 d8                	mov    %ebx,%eax
  80057d:	c1 e8 16             	shr    $0x16,%eax
  800580:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800587:	a8 01                	test   $0x1,%al
  800589:	74 37                	je     8005c2 <dup+0x99>
  80058b:	89 d8                	mov    %ebx,%eax
  80058d:	c1 e8 0c             	shr    $0xc,%eax
  800590:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800597:	f6 c2 01             	test   $0x1,%dl
  80059a:	74 26                	je     8005c2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80059c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a3:	83 ec 0c             	sub    $0xc,%esp
  8005a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ab:	50                   	push   %eax
  8005ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005af:	6a 00                	push   $0x0
  8005b1:	53                   	push   %ebx
  8005b2:	6a 00                	push   $0x0
  8005b4:	e8 27 fc ff ff       	call   8001e0 <sys_page_map>
  8005b9:	89 c3                	mov    %eax,%ebx
  8005bb:	83 c4 20             	add    $0x20,%esp
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	78 2d                	js     8005ef <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c5:	89 c2                	mov    %eax,%edx
  8005c7:	c1 ea 0c             	shr    $0xc,%edx
  8005ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005d1:	83 ec 0c             	sub    $0xc,%esp
  8005d4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005da:	52                   	push   %edx
  8005db:	56                   	push   %esi
  8005dc:	6a 00                	push   $0x0
  8005de:	50                   	push   %eax
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 fa fb ff ff       	call   8001e0 <sys_page_map>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	79 1d                	jns    80060c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	56                   	push   %esi
  8005f3:	6a 00                	push   $0x0
  8005f5:	e8 0c fc ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005fa:	83 c4 08             	add    $0x8,%esp
  8005fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  800600:	6a 00                	push   $0x0
  800602:	e8 ff fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb 02                	jmp    80060e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80060c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80060e:	89 d8                	mov    %ebx,%eax
  800610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800613:	5b                   	pop    %ebx
  800614:	5e                   	pop    %esi
  800615:	5f                   	pop    %edi
  800616:	c9                   	leave  
  800617:	c3                   	ret    

00800618 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	53                   	push   %ebx
  80061c:	83 ec 14             	sub    $0x14,%esp
  80061f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	e8 6b fd ff ff       	call   800397 <fd_lookup>
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	85 c0                	test   %eax,%eax
  800631:	78 67                	js     80069a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800639:	50                   	push   %eax
  80063a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80063d:	ff 30                	pushl  (%eax)
  80063f:	e8 a9 fd ff ff       	call   8003ed <dev_lookup>
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 4f                	js     80069a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	8b 50 08             	mov    0x8(%eax),%edx
  800651:	83 e2 03             	and    $0x3,%edx
  800654:	83 fa 01             	cmp    $0x1,%edx
  800657:	75 21                	jne    80067a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800659:	a1 04 40 80 00       	mov    0x804004,%eax
  80065e:	8b 40 48             	mov    0x48(%eax),%eax
  800661:	83 ec 04             	sub    $0x4,%esp
  800664:	53                   	push   %ebx
  800665:	50                   	push   %eax
  800666:	68 fd 1d 80 00       	push   $0x801dfd
  80066b:	e8 18 0a 00 00       	call   801088 <cprintf>
		return -E_INVAL;
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800678:	eb 20                	jmp    80069a <read+0x82>
	}
	if (!dev->dev_read)
  80067a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80067d:	8b 52 08             	mov    0x8(%edx),%edx
  800680:	85 d2                	test   %edx,%edx
  800682:	74 11                	je     800695 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800684:	83 ec 04             	sub    $0x4,%esp
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	50                   	push   %eax
  80068e:	ff d2                	call   *%edx
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb 05                	jmp    80069a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80069a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	57                   	push   %edi
  8006a3:	56                   	push   %esi
  8006a4:	53                   	push   %ebx
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ae:	85 f6                	test   %esi,%esi
  8006b0:	74 31                	je     8006e3 <readn+0x44>
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	89 f2                	mov    %esi,%edx
  8006c1:	29 c2                	sub    %eax,%edx
  8006c3:	52                   	push   %edx
  8006c4:	03 45 0c             	add    0xc(%ebp),%eax
  8006c7:	50                   	push   %eax
  8006c8:	57                   	push   %edi
  8006c9:	e8 4a ff ff ff       	call   800618 <read>
		if (m < 0)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	78 17                	js     8006ec <readn+0x4d>
			return m;
		if (m == 0)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 11                	je     8006ea <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d9:	01 c3                	add    %eax,%ebx
  8006db:	89 d8                	mov    %ebx,%eax
  8006dd:	39 f3                	cmp    %esi,%ebx
  8006df:	72 db                	jb     8006bc <readn+0x1d>
  8006e1:	eb 09                	jmp    8006ec <readn+0x4d>
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 02                	jmp    8006ec <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006ea:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 14             	sub    $0x14,%esp
  8006fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	53                   	push   %ebx
  800703:	e8 8f fc ff ff       	call   800397 <fd_lookup>
  800708:	83 c4 08             	add    $0x8,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 62                	js     800771 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800719:	ff 30                	pushl  (%eax)
  80071b:	e8 cd fc ff ff       	call   8003ed <dev_lookup>
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 4a                	js     800771 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072e:	75 21                	jne    800751 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800730:	a1 04 40 80 00       	mov    0x804004,%eax
  800735:	8b 40 48             	mov    0x48(%eax),%eax
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	53                   	push   %ebx
  80073c:	50                   	push   %eax
  80073d:	68 19 1e 80 00       	push   $0x801e19
  800742:	e8 41 09 00 00       	call   801088 <cprintf>
		return -E_INVAL;
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb 20                	jmp    800771 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800751:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800754:	8b 52 0c             	mov    0xc(%edx),%edx
  800757:	85 d2                	test   %edx,%edx
  800759:	74 11                	je     80076c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80075b:	83 ec 04             	sub    $0x4,%esp
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	50                   	push   %eax
  800765:	ff d2                	call   *%edx
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb 05                	jmp    800771 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80076c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <seek>:

int
seek(int fdnum, off_t offset)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	ff 75 08             	pushl  0x8(%ebp)
  800783:	e8 0f fc ff ff       	call   800397 <fd_lookup>
  800788:	83 c4 08             	add    $0x8,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 0e                	js     80079d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80078f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	83 ec 14             	sub    $0x14,%esp
  8007a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	53                   	push   %ebx
  8007ae:	e8 e4 fb ff ff       	call   800397 <fd_lookup>
  8007b3:	83 c4 08             	add    $0x8,%esp
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 5f                	js     800819 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c4:	ff 30                	pushl  (%eax)
  8007c6:	e8 22 fc ff ff       	call   8003ed <dev_lookup>
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 47                	js     800819 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d9:	75 21                	jne    8007fc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007db:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007e0:	8b 40 48             	mov    0x48(%eax),%eax
  8007e3:	83 ec 04             	sub    $0x4,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	50                   	push   %eax
  8007e8:	68 dc 1d 80 00       	push   $0x801ddc
  8007ed:	e8 96 08 00 00       	call   801088 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fa:	eb 1d                	jmp    800819 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8007fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ff:	8b 52 18             	mov    0x18(%edx),%edx
  800802:	85 d2                	test   %edx,%edx
  800804:	74 0e                	je     800814 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	50                   	push   %eax
  80080d:	ff d2                	call   *%edx
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	eb 05                	jmp    800819 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800814:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	83 ec 14             	sub    $0x14,%esp
  800825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800828:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082b:	50                   	push   %eax
  80082c:	ff 75 08             	pushl  0x8(%ebp)
  80082f:	e8 63 fb ff ff       	call   800397 <fd_lookup>
  800834:	83 c4 08             	add    $0x8,%esp
  800837:	85 c0                	test   %eax,%eax
  800839:	78 52                	js     80088d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800841:	50                   	push   %eax
  800842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800845:	ff 30                	pushl  (%eax)
  800847:	e8 a1 fb ff ff       	call   8003ed <dev_lookup>
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 3a                	js     80088d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80085a:	74 2c                	je     800888 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80085c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800866:	00 00 00 
	stat->st_isdir = 0;
  800869:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800870:	00 00 00 
	stat->st_dev = dev;
  800873:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	53                   	push   %ebx
  80087d:	ff 75 f0             	pushl  -0x10(%ebp)
  800880:	ff 50 14             	call   *0x14(%eax)
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	eb 05                	jmp    80088d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800888:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	6a 00                	push   $0x0
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 78 01 00 00       	call   800a1c <open>
  8008a4:	89 c3                	mov    %eax,%ebx
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	78 1b                	js     8008c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	50                   	push   %eax
  8008b4:	e8 65 ff ff ff       	call   80081e <fstat>
  8008b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8008bb:	89 1c 24             	mov    %ebx,(%esp)
  8008be:	e8 18 fc ff ff       	call   8004db <close>
	return r;
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	89 f3                	mov    %esi,%ebx
}
  8008c8:	89 d8                	mov    %ebx,%eax
  8008ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    
  8008d1:	00 00                	add    %al,(%eax)
	...

008008d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	89 c3                	mov    %eax,%ebx
  8008db:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e4:	75 12                	jne    8008f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008e6:	83 ec 0c             	sub    $0xc,%esp
  8008e9:	6a 01                	push   $0x1
  8008eb:	e8 96 11 00 00       	call   801a86 <ipc_find_env>
  8008f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8008f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f8:	6a 07                	push   $0x7
  8008fa:	68 00 50 80 00       	push   $0x805000
  8008ff:	53                   	push   %ebx
  800900:	ff 35 00 40 80 00    	pushl  0x804000
  800906:	e8 26 11 00 00       	call   801a31 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80090b:	83 c4 0c             	add    $0xc,%esp
  80090e:	6a 00                	push   $0x0
  800910:	56                   	push   %esi
  800911:	6a 00                	push   $0x0
  800913:	e8 a4 10 00 00       	call   8019bc <ipc_recv>
}
  800918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	83 ec 04             	sub    $0x4,%esp
  800926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 40 0c             	mov    0xc(%eax),%eax
  80092f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
  800939:	b8 05 00 00 00       	mov    $0x5,%eax
  80093e:	e8 91 ff ff ff       	call   8008d4 <fsipc>
  800943:	85 c0                	test   %eax,%eax
  800945:	78 2c                	js     800973 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800947:	83 ec 08             	sub    $0x8,%esp
  80094a:	68 00 50 80 00       	push   $0x805000
  80094f:	53                   	push   %ebx
  800950:	e8 e9 0c 00 00       	call   80163e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800955:	a1 80 50 80 00       	mov    0x805080,%eax
  80095a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800960:	a1 84 50 80 00       	mov    0x805084,%eax
  800965:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 3c ff ff ff       	call   8008d4 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009ad:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b8:	b8 03 00 00 00       	mov    $0x3,%eax
  8009bd:	e8 12 ff ff ff       	call   8008d4 <fsipc>
  8009c2:	89 c3                	mov    %eax,%ebx
  8009c4:	85 c0                	test   %eax,%eax
  8009c6:	78 4b                	js     800a13 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009c8:	39 c6                	cmp    %eax,%esi
  8009ca:	73 16                	jae    8009e2 <devfile_read+0x48>
  8009cc:	68 48 1e 80 00       	push   $0x801e48
  8009d1:	68 4f 1e 80 00       	push   $0x801e4f
  8009d6:	6a 7d                	push   $0x7d
  8009d8:	68 64 1e 80 00       	push   $0x801e64
  8009dd:	e8 ce 05 00 00       	call   800fb0 <_panic>
	assert(r <= PGSIZE);
  8009e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009e7:	7e 16                	jle    8009ff <devfile_read+0x65>
  8009e9:	68 6f 1e 80 00       	push   $0x801e6f
  8009ee:	68 4f 1e 80 00       	push   $0x801e4f
  8009f3:	6a 7e                	push   $0x7e
  8009f5:	68 64 1e 80 00       	push   $0x801e64
  8009fa:	e8 b1 05 00 00       	call   800fb0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8009ff:	83 ec 04             	sub    $0x4,%esp
  800a02:	50                   	push   %eax
  800a03:	68 00 50 80 00       	push   $0x805000
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	e8 ef 0d 00 00       	call   8017ff <memmove>
	return r;
  800a10:	83 c4 10             	add    $0x10,%esp
}
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	83 ec 1c             	sub    $0x1c,%esp
  800a24:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a27:	56                   	push   %esi
  800a28:	e8 bf 0b 00 00       	call   8015ec <strlen>
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a35:	7f 65                	jg     800a9c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a37:	83 ec 0c             	sub    $0xc,%esp
  800a3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a3d:	50                   	push   %eax
  800a3e:	e8 e1 f8 ff ff       	call   800324 <fd_alloc>
  800a43:	89 c3                	mov    %eax,%ebx
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 55                	js     800aa1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	56                   	push   %esi
  800a50:	68 00 50 80 00       	push   $0x805000
  800a55:	e8 e4 0b 00 00       	call   80163e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a65:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6a:	e8 65 fe ff ff       	call   8008d4 <fsipc>
  800a6f:	89 c3                	mov    %eax,%ebx
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	85 c0                	test   %eax,%eax
  800a76:	79 12                	jns    800a8a <open+0x6e>
		fd_close(fd, 0);
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	6a 00                	push   $0x0
  800a7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a80:	e8 ce f9 ff ff       	call   800453 <fd_close>
		return r;
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	eb 17                	jmp    800aa1 <open+0x85>
	}

	return fd2num(fd);
  800a8a:	83 ec 0c             	sub    $0xc,%esp
  800a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a90:	e8 67 f8 ff ff       	call   8002fc <fd2num>
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	eb 05                	jmp    800aa1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800a9c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800aa1:	89 d8                	mov    %ebx,%eax
  800aa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    
	...

00800aac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ab4:	83 ec 0c             	sub    $0xc,%esp
  800ab7:	ff 75 08             	pushl  0x8(%ebp)
  800aba:	e8 4d f8 ff ff       	call   80030c <fd2data>
  800abf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ac1:	83 c4 08             	add    $0x8,%esp
  800ac4:	68 7b 1e 80 00       	push   $0x801e7b
  800ac9:	56                   	push   %esi
  800aca:	e8 6f 0b 00 00       	call   80163e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800acf:	8b 43 04             	mov    0x4(%ebx),%eax
  800ad2:	2b 03                	sub    (%ebx),%eax
  800ad4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800ada:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800ae1:	00 00 00 
	stat->st_dev = &devpipe;
  800ae4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800aeb:	30 80 00 
	return 0;
}
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b04:	53                   	push   %ebx
  800b05:	6a 00                	push   $0x0
  800b07:	e8 fa f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b0c:	89 1c 24             	mov    %ebx,(%esp)
  800b0f:	e8 f8 f7 ff ff       	call   80030c <fd2data>
  800b14:	83 c4 08             	add    $0x8,%esp
  800b17:	50                   	push   %eax
  800b18:	6a 00                	push   $0x0
  800b1a:	e8 e7 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800b1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 1c             	sub    $0x1c,%esp
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b32:	a1 04 40 80 00       	mov    0x804004,%eax
  800b37:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	57                   	push   %edi
  800b3e:	e8 a1 0f 00 00       	call   801ae4 <pageref>
  800b43:	89 c6                	mov    %eax,%esi
  800b45:	83 c4 04             	add    $0x4,%esp
  800b48:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4b:	e8 94 0f 00 00       	call   801ae4 <pageref>
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	39 c6                	cmp    %eax,%esi
  800b55:	0f 94 c0             	sete   %al
  800b58:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b5b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b61:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b64:	39 cb                	cmp    %ecx,%ebx
  800b66:	75 08                	jne    800b70 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b70:	83 f8 01             	cmp    $0x1,%eax
  800b73:	75 bd                	jne    800b32 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b75:	8b 42 58             	mov    0x58(%edx),%eax
  800b78:	6a 01                	push   $0x1
  800b7a:	50                   	push   %eax
  800b7b:	53                   	push   %ebx
  800b7c:	68 82 1e 80 00       	push   $0x801e82
  800b81:	e8 02 05 00 00       	call   801088 <cprintf>
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb a7                	jmp    800b32 <_pipeisclosed+0xe>

00800b8b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 28             	sub    $0x28,%esp
  800b94:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b97:	56                   	push   %esi
  800b98:	e8 6f f7 ff ff       	call   80030c <fd2data>
  800b9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba6:	75 4a                	jne    800bf2 <devpipe_write+0x67>
  800ba8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bad:	eb 56                	jmp    800c05 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800baf:	89 da                	mov    %ebx,%edx
  800bb1:	89 f0                	mov    %esi,%eax
  800bb3:	e8 6c ff ff ff       	call   800b24 <_pipeisclosed>
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	75 4d                	jne    800c09 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bbc:	e8 d4 f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bc1:	8b 43 04             	mov    0x4(%ebx),%eax
  800bc4:	8b 13                	mov    (%ebx),%edx
  800bc6:	83 c2 20             	add    $0x20,%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 e2                	jae    800baf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bd5:	79 05                	jns    800bdc <devpipe_write+0x51>
  800bd7:	4a                   	dec    %edx
  800bd8:	83 ca e0             	or     $0xffffffe0,%edx
  800bdb:	42                   	inc    %edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800be2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800be6:	40                   	inc    %eax
  800be7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bea:	47                   	inc    %edi
  800beb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800bee:	77 07                	ja     800bf7 <devpipe_write+0x6c>
  800bf0:	eb 13                	jmp    800c05 <devpipe_write+0x7a>
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bf7:	8b 43 04             	mov    0x4(%ebx),%eax
  800bfa:	8b 13                	mov    (%ebx),%edx
  800bfc:	83 c2 20             	add    $0x20,%edx
  800bff:	39 d0                	cmp    %edx,%eax
  800c01:	73 ac                	jae    800baf <devpipe_write+0x24>
  800c03:	eb c8                	jmp    800bcd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c05:	89 f8                	mov    %edi,%eax
  800c07:	eb 05                	jmp    800c0e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 18             	sub    $0x18,%esp
  800c1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c22:	57                   	push   %edi
  800c23:	e8 e4 f6 ff ff       	call   80030c <fd2data>
  800c28:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c31:	75 44                	jne    800c77 <devpipe_read+0x61>
  800c33:	be 00 00 00 00       	mov    $0x0,%esi
  800c38:	eb 4f                	jmp    800c89 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c3a:	89 f0                	mov    %esi,%eax
  800c3c:	eb 54                	jmp    800c92 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c3e:	89 da                	mov    %ebx,%edx
  800c40:	89 f8                	mov    %edi,%eax
  800c42:	e8 dd fe ff ff       	call   800b24 <_pipeisclosed>
  800c47:	85 c0                	test   %eax,%eax
  800c49:	75 42                	jne    800c8d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c4b:	e8 45 f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c50:	8b 03                	mov    (%ebx),%eax
  800c52:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c55:	74 e7                	je     800c3e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c57:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c5c:	79 05                	jns    800c63 <devpipe_read+0x4d>
  800c5e:	48                   	dec    %eax
  800c5f:	83 c8 e0             	or     $0xffffffe0,%eax
  800c62:	40                   	inc    %eax
  800c63:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c6d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6f:	46                   	inc    %esi
  800c70:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c73:	77 07                	ja     800c7c <devpipe_read+0x66>
  800c75:	eb 12                	jmp    800c89 <devpipe_read+0x73>
  800c77:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c7c:	8b 03                	mov    (%ebx),%eax
  800c7e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c81:	75 d4                	jne    800c57 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c83:	85 f6                	test   %esi,%esi
  800c85:	75 b3                	jne    800c3a <devpipe_read+0x24>
  800c87:	eb b5                	jmp    800c3e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c89:	89 f0                	mov    %esi,%eax
  800c8b:	eb 05                	jmp    800c92 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 28             	sub    $0x28,%esp
  800ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ca6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ca9:	50                   	push   %eax
  800caa:	e8 75 f6 ff ff       	call   800324 <fd_alloc>
  800caf:	89 c3                	mov    %eax,%ebx
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	0f 88 24 01 00 00    	js     800de0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cbc:	83 ec 04             	sub    $0x4,%esp
  800cbf:	68 07 04 00 00       	push   $0x407
  800cc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cc7:	6a 00                	push   $0x0
  800cc9:	e8 ee f4 ff ff       	call   8001bc <sys_page_alloc>
  800cce:	89 c3                	mov    %eax,%ebx
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	0f 88 05 01 00 00    	js     800de0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ce1:	50                   	push   %eax
  800ce2:	e8 3d f6 ff ff       	call   800324 <fd_alloc>
  800ce7:	89 c3                	mov    %eax,%ebx
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	85 c0                	test   %eax,%eax
  800cee:	0f 88 dc 00 00 00    	js     800dd0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	68 07 04 00 00       	push   $0x407
  800cfc:	ff 75 e0             	pushl  -0x20(%ebp)
  800cff:	6a 00                	push   $0x0
  800d01:	e8 b6 f4 ff ff       	call   8001bc <sys_page_alloc>
  800d06:	89 c3                	mov    %eax,%ebx
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	0f 88 bd 00 00 00    	js     800dd0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d19:	e8 ee f5 ff ff       	call   80030c <fd2data>
  800d1e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d20:	83 c4 0c             	add    $0xc,%esp
  800d23:	68 07 04 00 00       	push   $0x407
  800d28:	50                   	push   %eax
  800d29:	6a 00                	push   $0x0
  800d2b:	e8 8c f4 ff ff       	call   8001bc <sys_page_alloc>
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	0f 88 83 00 00 00    	js     800dc0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	ff 75 e0             	pushl  -0x20(%ebp)
  800d43:	e8 c4 f5 ff ff       	call   80030c <fd2data>
  800d48:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d4f:	50                   	push   %eax
  800d50:	6a 00                	push   $0x0
  800d52:	56                   	push   %esi
  800d53:	6a 00                	push   $0x0
  800d55:	e8 86 f4 ff ff       	call   8001e0 <sys_page_map>
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	83 c4 20             	add    $0x20,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	78 4f                	js     800db2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d63:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d78:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d81:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d83:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d86:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d93:	e8 64 f5 ff ff       	call   8002fc <fd2num>
  800d98:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d9a:	83 c4 04             	add    $0x4,%esp
  800d9d:	ff 75 e0             	pushl  -0x20(%ebp)
  800da0:	e8 57 f5 ff ff       	call   8002fc <fd2num>
  800da5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	eb 2e                	jmp    800de0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800db2:	83 ec 08             	sub    $0x8,%esp
  800db5:	56                   	push   %esi
  800db6:	6a 00                	push   $0x0
  800db8:	e8 49 f4 ff ff       	call   800206 <sys_page_unmap>
  800dbd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 39 f4 ff ff       	call   800206 <sys_page_unmap>
  800dcd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dd0:	83 ec 08             	sub    $0x8,%esp
  800dd3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 29 f4 ff ff       	call   800206 <sys_page_unmap>
  800ddd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800df0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df3:	50                   	push   %eax
  800df4:	ff 75 08             	pushl  0x8(%ebp)
  800df7:	e8 9b f5 ff ff       	call   800397 <fd_lookup>
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 18                	js     800e1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	ff 75 f4             	pushl  -0xc(%ebp)
  800e09:	e8 fe f4 ff ff       	call   80030c <fd2data>
	return _pipeisclosed(fd, p);
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e13:	e8 0c fd ff ff       	call   800b24 <_pipeisclosed>
  800e18:	83 c4 10             	add    $0x10,%esp
}
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    
  800e1d:	00 00                	add    %al,(%eax)
	...

00800e20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e30:	68 9a 1e 80 00       	push   $0x801e9a
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	e8 01 08 00 00       	call   80163e <strcpy>
	return 0;
}
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e54:	74 45                	je     800e9b <devcons_write+0x57>
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e60:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e69:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e6b:	83 fb 7f             	cmp    $0x7f,%ebx
  800e6e:	76 05                	jbe    800e75 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e70:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	53                   	push   %ebx
  800e79:	03 45 0c             	add    0xc(%ebp),%eax
  800e7c:	50                   	push   %eax
  800e7d:	57                   	push   %edi
  800e7e:	e8 7c 09 00 00       	call   8017ff <memmove>
		sys_cputs(buf, m);
  800e83:	83 c4 08             	add    $0x8,%esp
  800e86:	53                   	push   %ebx
  800e87:	57                   	push   %edi
  800e88:	e8 78 f2 ff ff       	call   800105 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e8d:	01 de                	add    %ebx,%esi
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e97:	72 cd                	jb     800e66 <devcons_write+0x22>
  800e99:	eb 05                	jmp    800ea0 <devcons_write+0x5c>
  800e9b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb4:	75 07                	jne    800ebd <devcons_read+0x13>
  800eb6:	eb 25                	jmp    800edd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eb8:	e8 d8 f2 ff ff       	call   800195 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ebd:	e8 69 f2 ff ff       	call   80012b <sys_cgetc>
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	74 f2                	je     800eb8 <devcons_read+0xe>
  800ec6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 1d                	js     800ee9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ecc:	83 f8 04             	cmp    $0x4,%eax
  800ecf:	74 13                	je     800ee4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed4:	88 10                	mov    %dl,(%eax)
	return 1;
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	eb 0c                	jmp    800ee9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	eb 05                	jmp    800ee9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ef7:	6a 01                	push   $0x1
  800ef9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800efc:	50                   	push   %eax
  800efd:	e8 03 f2 ff ff       	call   800105 <sys_cputs>
  800f02:	83 c4 10             	add    $0x10,%esp
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <getchar>:

int
getchar(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f0d:	6a 01                	push   $0x1
  800f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	6a 00                	push   $0x0
  800f15:	e8 fe f6 ff ff       	call   800618 <read>
	if (r < 0)
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 0f                	js     800f30 <getchar+0x29>
		return r;
	if (r < 1)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	7e 06                	jle    800f2b <getchar+0x24>
		return -E_EOF;
	return c;
  800f25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f29:	eb 05                	jmp    800f30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	ff 75 08             	pushl  0x8(%ebp)
  800f3f:	e8 53 f4 ff ff       	call   800397 <fd_lookup>
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 11                	js     800f5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f54:	39 10                	cmp    %edx,(%eax)
  800f56:	0f 94 c0             	sete   %al
  800f59:	0f b6 c0             	movzbl %al,%eax
}
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <opencons>:

int
opencons(void)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	e8 b7 f3 ff ff       	call   800324 <fd_alloc>
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 3a                	js     800fae <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 07 04 00 00       	push   $0x407
  800f7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 36 f2 ff ff       	call   8001bc <sys_page_alloc>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 21                	js     800fae <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f96:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	50                   	push   %eax
  800fa6:	e8 51 f3 ff ff       	call   8002fc <fd2num>
  800fab:	83 c4 10             	add    $0x10,%esp
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fb5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fb8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fbe:	e8 ae f1 ff ff       	call   800171 <sys_getenvid>
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	ff 75 0c             	pushl  0xc(%ebp)
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	53                   	push   %ebx
  800fcd:	50                   	push   %eax
  800fce:	68 a8 1e 80 00       	push   $0x801ea8
  800fd3:	e8 b0 00 00 00       	call   801088 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd8:	83 c4 18             	add    $0x18,%esp
  800fdb:	56                   	push   %esi
  800fdc:	ff 75 10             	pushl  0x10(%ebp)
  800fdf:	e8 53 00 00 00       	call   801037 <vcprintf>
	cprintf("\n");
  800fe4:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  800feb:	e8 98 00 00 00       	call   801088 <cprintf>
  800ff0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ff3:	cc                   	int3   
  800ff4:	eb fd                	jmp    800ff3 <_panic+0x43>
	...

00800ff8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801002:	8b 03                	mov    (%ebx),%eax
  801004:	8b 55 08             	mov    0x8(%ebp),%edx
  801007:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80100b:	40                   	inc    %eax
  80100c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80100e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801013:	75 1a                	jne    80102f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	68 ff 00 00 00       	push   $0xff
  80101d:	8d 43 08             	lea    0x8(%ebx),%eax
  801020:	50                   	push   %eax
  801021:	e8 df f0 ff ff       	call   800105 <sys_cputs>
		b->idx = 0;
  801026:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80102c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80102f:	ff 43 04             	incl   0x4(%ebx)
}
  801032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801040:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801047:	00 00 00 
	b.cnt = 0;
  80104a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801051:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	68 f8 0f 80 00       	push   $0x800ff8
  801066:	e8 82 01 00 00       	call   8011ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80106b:	83 c4 08             	add    $0x8,%esp
  80106e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801074:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80107a:	50                   	push   %eax
  80107b:	e8 85 f0 ff ff       	call   800105 <sys_cputs>

	return b.cnt;
}
  801080:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801086:	c9                   	leave  
  801087:	c3                   	ret    

00801088 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80108e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801091:	50                   	push   %eax
  801092:	ff 75 08             	pushl  0x8(%ebp)
  801095:	e8 9d ff ff ff       	call   801037 <vcprintf>
	va_end(ap);

	return cnt;
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 2c             	sub    $0x2c,%esp
  8010a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a8:	89 d6                	mov    %edx,%esi
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010bc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010c9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010cc:	72 0c                	jb     8010da <printnum+0x3e>
  8010ce:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010d1:	76 07                	jbe    8010da <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010d3:	4b                   	dec    %ebx
  8010d4:	85 db                	test   %ebx,%ebx
  8010d6:	7f 31                	jg     801109 <printnum+0x6d>
  8010d8:	eb 3f                	jmp    801119 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	57                   	push   %edi
  8010de:	4b                   	dec    %ebx
  8010df:	53                   	push   %ebx
  8010e0:	50                   	push   %eax
  8010e1:	83 ec 08             	sub    $0x8,%esp
  8010e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8010ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8010ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8010f0:	e8 33 0a 00 00       	call   801b28 <__udivdi3>
  8010f5:	83 c4 18             	add    $0x18,%esp
  8010f8:	52                   	push   %edx
  8010f9:	50                   	push   %eax
  8010fa:	89 f2                	mov    %esi,%edx
  8010fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ff:	e8 98 ff ff ff       	call   80109c <printnum>
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	eb 10                	jmp    801119 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	56                   	push   %esi
  80110d:	57                   	push   %edi
  80110e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801111:	4b                   	dec    %ebx
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 db                	test   %ebx,%ebx
  801117:	7f f0                	jg     801109 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	56                   	push   %esi
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	ff 75 d4             	pushl  -0x2c(%ebp)
  801123:	ff 75 d0             	pushl  -0x30(%ebp)
  801126:	ff 75 dc             	pushl  -0x24(%ebp)
  801129:	ff 75 d8             	pushl  -0x28(%ebp)
  80112c:	e8 13 0b 00 00       	call   801c44 <__umoddi3>
  801131:	83 c4 14             	add    $0x14,%esp
  801134:	0f be 80 cb 1e 80 00 	movsbl 0x801ecb(%eax),%eax
  80113b:	50                   	push   %eax
  80113c:	ff 55 e4             	call   *-0x1c(%ebp)
  80113f:	83 c4 10             	add    $0x10,%esp
}
  801142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80114d:	83 fa 01             	cmp    $0x1,%edx
  801150:	7e 0e                	jle    801160 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801152:	8b 10                	mov    (%eax),%edx
  801154:	8d 4a 08             	lea    0x8(%edx),%ecx
  801157:	89 08                	mov    %ecx,(%eax)
  801159:	8b 02                	mov    (%edx),%eax
  80115b:	8b 52 04             	mov    0x4(%edx),%edx
  80115e:	eb 22                	jmp    801182 <getuint+0x38>
	else if (lflag)
  801160:	85 d2                	test   %edx,%edx
  801162:	74 10                	je     801174 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801164:	8b 10                	mov    (%eax),%edx
  801166:	8d 4a 04             	lea    0x4(%edx),%ecx
  801169:	89 08                	mov    %ecx,(%eax)
  80116b:	8b 02                	mov    (%edx),%eax
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
  801172:	eb 0e                	jmp    801182 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801174:	8b 10                	mov    (%eax),%edx
  801176:	8d 4a 04             	lea    0x4(%edx),%ecx
  801179:	89 08                	mov    %ecx,(%eax)
  80117b:	8b 02                	mov    (%edx),%eax
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801182:	c9                   	leave  
  801183:	c3                   	ret    

00801184 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801187:	83 fa 01             	cmp    $0x1,%edx
  80118a:	7e 0e                	jle    80119a <getint+0x16>
		return va_arg(*ap, long long);
  80118c:	8b 10                	mov    (%eax),%edx
  80118e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801191:	89 08                	mov    %ecx,(%eax)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	8b 52 04             	mov    0x4(%edx),%edx
  801198:	eb 1a                	jmp    8011b4 <getint+0x30>
	else if (lflag)
  80119a:	85 d2                	test   %edx,%edx
  80119c:	74 0c                	je     8011aa <getint+0x26>
		return va_arg(*ap, long);
  80119e:	8b 10                	mov    (%eax),%edx
  8011a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a3:	89 08                	mov    %ecx,(%eax)
  8011a5:	8b 02                	mov    (%edx),%eax
  8011a7:	99                   	cltd   
  8011a8:	eb 0a                	jmp    8011b4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011aa:	8b 10                	mov    (%eax),%edx
  8011ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011af:	89 08                	mov    %ecx,(%eax)
  8011b1:	8b 02                	mov    (%edx),%eax
  8011b3:	99                   	cltd   
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011bf:	8b 10                	mov    (%eax),%edx
  8011c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c4:	73 08                	jae    8011ce <sprintputch+0x18>
		*b->buf++ = ch;
  8011c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c9:	88 0a                	mov    %cl,(%edx)
  8011cb:	42                   	inc    %edx
  8011cc:	89 10                	mov    %edx,(%eax)
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d9:	50                   	push   %eax
  8011da:	ff 75 10             	pushl  0x10(%ebp)
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	ff 75 08             	pushl  0x8(%ebp)
  8011e3:	e8 05 00 00 00       	call   8011ed <vprintfmt>
	va_end(ap);
  8011e8:	83 c4 10             	add    $0x10,%esp
}
  8011eb:	c9                   	leave  
  8011ec:	c3                   	ret    

008011ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 2c             	sub    $0x2c,%esp
  8011f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8011fc:	eb 13                	jmp    801211 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011fe:	85 c0                	test   %eax,%eax
  801200:	0f 84 6d 03 00 00    	je     801573 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	57                   	push   %edi
  80120a:	50                   	push   %eax
  80120b:	ff 55 08             	call   *0x8(%ebp)
  80120e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801211:	0f b6 06             	movzbl (%esi),%eax
  801214:	46                   	inc    %esi
  801215:	83 f8 25             	cmp    $0x25,%eax
  801218:	75 e4                	jne    8011fe <vprintfmt+0x11>
  80121a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80121e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801225:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80122c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801233:	b9 00 00 00 00       	mov    $0x0,%ecx
  801238:	eb 28                	jmp    801262 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80123c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801240:	eb 20                	jmp    801262 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801242:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801244:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801248:	eb 18                	jmp    801262 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80124c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801253:	eb 0d                	jmp    801262 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801255:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801258:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80125b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	8a 06                	mov    (%esi),%al
  801264:	0f b6 d0             	movzbl %al,%edx
  801267:	8d 5e 01             	lea    0x1(%esi),%ebx
  80126a:	83 e8 23             	sub    $0x23,%eax
  80126d:	3c 55                	cmp    $0x55,%al
  80126f:	0f 87 e0 02 00 00    	ja     801555 <vprintfmt+0x368>
  801275:	0f b6 c0             	movzbl %al,%eax
  801278:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80127f:	83 ea 30             	sub    $0x30,%edx
  801282:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801285:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801288:	8d 50 d0             	lea    -0x30(%eax),%edx
  80128b:	83 fa 09             	cmp    $0x9,%edx
  80128e:	77 44                	ja     8012d4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801290:	89 de                	mov    %ebx,%esi
  801292:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801295:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801296:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801299:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80129d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012a0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012a3:	83 fb 09             	cmp    $0x9,%ebx
  8012a6:	76 ed                	jbe    801295 <vprintfmt+0xa8>
  8012a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012ab:	eb 29                	jmp    8012d6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b0:	8d 50 04             	lea    0x4(%eax),%edx
  8012b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012b6:	8b 00                	mov    (%eax),%eax
  8012b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012bd:	eb 17                	jmp    8012d6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012c3:	78 85                	js     80124a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	89 de                	mov    %ebx,%esi
  8012c7:	eb 99                	jmp    801262 <vprintfmt+0x75>
  8012c9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012d2:	eb 8e                	jmp    801262 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012da:	79 86                	jns    801262 <vprintfmt+0x75>
  8012dc:	e9 74 ff ff ff       	jmp    801255 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012e1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	89 de                	mov    %ebx,%esi
  8012e4:	e9 79 ff ff ff       	jmp    801262 <vprintfmt+0x75>
  8012e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8d 50 04             	lea    0x4(%eax),%edx
  8012f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	57                   	push   %edi
  8012f9:	ff 30                	pushl  (%eax)
  8012fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8012fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801301:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801304:	e9 08 ff ff ff       	jmp    801211 <vprintfmt+0x24>
  801309:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80130c:	8b 45 14             	mov    0x14(%ebp),%eax
  80130f:	8d 50 04             	lea    0x4(%eax),%edx
  801312:	89 55 14             	mov    %edx,0x14(%ebp)
  801315:	8b 00                	mov    (%eax),%eax
  801317:	85 c0                	test   %eax,%eax
  801319:	79 02                	jns    80131d <vprintfmt+0x130>
  80131b:	f7 d8                	neg    %eax
  80131d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131f:	83 f8 0f             	cmp    $0xf,%eax
  801322:	7f 0b                	jg     80132f <vprintfmt+0x142>
  801324:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  80132b:	85 c0                	test   %eax,%eax
  80132d:	75 1a                	jne    801349 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80132f:	52                   	push   %edx
  801330:	68 e3 1e 80 00       	push   $0x801ee3
  801335:	57                   	push   %edi
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 92 fe ff ff       	call   8011d0 <printfmt>
  80133e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801344:	e9 c8 fe ff ff       	jmp    801211 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801349:	50                   	push   %eax
  80134a:	68 61 1e 80 00       	push   $0x801e61
  80134f:	57                   	push   %edi
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 78 fe ff ff       	call   8011d0 <printfmt>
  801358:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80135e:	e9 ae fe ff ff       	jmp    801211 <vprintfmt+0x24>
  801363:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801366:	89 de                	mov    %ebx,%esi
  801368:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80136b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80136e:	8b 45 14             	mov    0x14(%ebp),%eax
  801371:	8d 50 04             	lea    0x4(%eax),%edx
  801374:	89 55 14             	mov    %edx,0x14(%ebp)
  801377:	8b 00                	mov    (%eax),%eax
  801379:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80137c:	85 c0                	test   %eax,%eax
  80137e:	75 07                	jne    801387 <vprintfmt+0x19a>
				p = "(null)";
  801380:	c7 45 d0 dc 1e 80 00 	movl   $0x801edc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801387:	85 db                	test   %ebx,%ebx
  801389:	7e 42                	jle    8013cd <vprintfmt+0x1e0>
  80138b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80138f:	74 3c                	je     8013cd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	51                   	push   %ecx
  801395:	ff 75 d0             	pushl  -0x30(%ebp)
  801398:	e8 6f 02 00 00       	call   80160c <strnlen>
  80139d:	29 c3                	sub    %eax,%ebx
  80139f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 db                	test   %ebx,%ebx
  8013a7:	7e 24                	jle    8013cd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013a9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013ad:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	57                   	push   %edi
  8013b7:	53                   	push   %ebx
  8013b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bb:	4e                   	dec    %esi
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 f6                	test   %esi,%esi
  8013c1:	7f f0                	jg     8013b3 <vprintfmt+0x1c6>
  8013c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013d0:	0f be 02             	movsbl (%edx),%eax
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	75 47                	jne    80141e <vprintfmt+0x231>
  8013d7:	eb 37                	jmp    801410 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013dd:	74 16                	je     8013f5 <vprintfmt+0x208>
  8013df:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013e2:	83 fa 5e             	cmp    $0x5e,%edx
  8013e5:	76 0e                	jbe    8013f5 <vprintfmt+0x208>
					putch('?', putdat);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	57                   	push   %edi
  8013eb:	6a 3f                	push   $0x3f
  8013ed:	ff 55 08             	call   *0x8(%ebp)
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 0b                	jmp    801400 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	57                   	push   %edi
  8013f9:	50                   	push   %eax
  8013fa:	ff 55 08             	call   *0x8(%ebp)
  8013fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801400:	ff 4d e4             	decl   -0x1c(%ebp)
  801403:	0f be 03             	movsbl (%ebx),%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	74 03                	je     80140d <vprintfmt+0x220>
  80140a:	43                   	inc    %ebx
  80140b:	eb 1b                	jmp    801428 <vprintfmt+0x23b>
  80140d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801410:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801414:	7f 1e                	jg     801434 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801416:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801419:	e9 f3 fd ff ff       	jmp    801211 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80141e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801421:	43                   	inc    %ebx
  801422:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801425:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801428:	85 f6                	test   %esi,%esi
  80142a:	78 ad                	js     8013d9 <vprintfmt+0x1ec>
  80142c:	4e                   	dec    %esi
  80142d:	79 aa                	jns    8013d9 <vprintfmt+0x1ec>
  80142f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801432:	eb dc                	jmp    801410 <vprintfmt+0x223>
  801434:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	57                   	push   %edi
  80143b:	6a 20                	push   $0x20
  80143d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801440:	4b                   	dec    %ebx
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 db                	test   %ebx,%ebx
  801446:	7f ef                	jg     801437 <vprintfmt+0x24a>
  801448:	e9 c4 fd ff ff       	jmp    801211 <vprintfmt+0x24>
  80144d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801450:	89 ca                	mov    %ecx,%edx
  801452:	8d 45 14             	lea    0x14(%ebp),%eax
  801455:	e8 2a fd ff ff       	call   801184 <getint>
  80145a:	89 c3                	mov    %eax,%ebx
  80145c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80145e:	85 d2                	test   %edx,%edx
  801460:	78 0a                	js     80146c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801462:	b8 0a 00 00 00       	mov    $0xa,%eax
  801467:	e9 b0 00 00 00       	jmp    80151c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	57                   	push   %edi
  801470:	6a 2d                	push   $0x2d
  801472:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801475:	f7 db                	neg    %ebx
  801477:	83 d6 00             	adc    $0x0,%esi
  80147a:	f7 de                	neg    %esi
  80147c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80147f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801484:	e9 93 00 00 00       	jmp    80151c <vprintfmt+0x32f>
  801489:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80148c:	89 ca                	mov    %ecx,%edx
  80148e:	8d 45 14             	lea    0x14(%ebp),%eax
  801491:	e8 b4 fc ff ff       	call   80114a <getuint>
  801496:	89 c3                	mov    %eax,%ebx
  801498:	89 d6                	mov    %edx,%esi
			base = 10;
  80149a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80149f:	eb 7b                	jmp    80151c <vprintfmt+0x32f>
  8014a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014a4:	89 ca                	mov    %ecx,%edx
  8014a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a9:	e8 d6 fc ff ff       	call   801184 <getint>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014b2:	85 d2                	test   %edx,%edx
  8014b4:	78 07                	js     8014bd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014bb:	eb 5f                	jmp    80151c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	57                   	push   %edi
  8014c1:	6a 2d                	push   $0x2d
  8014c3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014c6:	f7 db                	neg    %ebx
  8014c8:	83 d6 00             	adc    $0x0,%esi
  8014cb:	f7 de                	neg    %esi
  8014cd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d5:	eb 45                	jmp    80151c <vprintfmt+0x32f>
  8014d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	57                   	push   %edi
  8014de:	6a 30                	push   $0x30
  8014e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	57                   	push   %edi
  8014e7:	6a 78                	push   $0x78
  8014e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ef:	8d 50 04             	lea    0x4(%eax),%edx
  8014f2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014f5:	8b 18                	mov    (%eax),%ebx
  8014f7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8014fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8014ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801504:	eb 16                	jmp    80151c <vprintfmt+0x32f>
  801506:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801509:	89 ca                	mov    %ecx,%edx
  80150b:	8d 45 14             	lea    0x14(%ebp),%eax
  80150e:	e8 37 fc ff ff       	call   80114a <getuint>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	89 d6                	mov    %edx,%esi
			base = 16;
  801517:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801523:	52                   	push   %edx
  801524:	ff 75 e4             	pushl  -0x1c(%ebp)
  801527:	50                   	push   %eax
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	89 fa                	mov    %edi,%edx
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	e8 68 fb ff ff       	call   80109c <printnum>
			break;
  801534:	83 c4 20             	add    $0x20,%esp
  801537:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80153a:	e9 d2 fc ff ff       	jmp    801211 <vprintfmt+0x24>
  80153f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	57                   	push   %edi
  801546:	52                   	push   %edx
  801547:	ff 55 08             	call   *0x8(%ebp)
			break;
  80154a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80154d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801550:	e9 bc fc ff ff       	jmp    801211 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	57                   	push   %edi
  801559:	6a 25                	push   $0x25
  80155b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	eb 02                	jmp    801565 <vprintfmt+0x378>
  801563:	89 c6                	mov    %eax,%esi
  801565:	8d 46 ff             	lea    -0x1(%esi),%eax
  801568:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80156c:	75 f5                	jne    801563 <vprintfmt+0x376>
  80156e:	e9 9e fc ff ff       	jmp    801211 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801573:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 18             	sub    $0x18,%esp
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801587:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80158a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80158e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801591:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 26                	je     8015c2 <vsnprintf+0x47>
  80159c:	85 d2                	test   %edx,%edx
  80159e:	7e 29                	jle    8015c9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015a0:	ff 75 14             	pushl  0x14(%ebp)
  8015a3:	ff 75 10             	pushl  0x10(%ebp)
  8015a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	68 b6 11 80 00       	push   $0x8011b6
  8015af:	e8 39 fc ff ff       	call   8011ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	eb 0c                	jmp    8015ce <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c7:	eb 05                	jmp    8015ce <vsnprintf+0x53>
  8015c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015d9:	50                   	push   %eax
  8015da:	ff 75 10             	pushl  0x10(%ebp)
  8015dd:	ff 75 0c             	pushl  0xc(%ebp)
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 93 ff ff ff       	call   80157b <vsnprintf>
	va_end(ap);

	return rc;
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    
	...

008015ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015f2:	80 3a 00             	cmpb   $0x0,(%edx)
  8015f5:	74 0e                	je     801605 <strlen+0x19>
  8015f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015fc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801601:	75 f9                	jne    8015fc <strlen+0x10>
  801603:	eb 05                	jmp    80160a <strlen+0x1e>
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801615:	85 d2                	test   %edx,%edx
  801617:	74 17                	je     801630 <strnlen+0x24>
  801619:	80 39 00             	cmpb   $0x0,(%ecx)
  80161c:	74 19                	je     801637 <strnlen+0x2b>
  80161e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801623:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801624:	39 d0                	cmp    %edx,%eax
  801626:	74 14                	je     80163c <strnlen+0x30>
  801628:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80162c:	75 f5                	jne    801623 <strnlen+0x17>
  80162e:	eb 0c                	jmp    80163c <strnlen+0x30>
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
  801635:	eb 05                	jmp    80163c <strnlen+0x30>
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	8b 45 08             	mov    0x8(%ebp),%eax
  801645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801648:	ba 00 00 00 00       	mov    $0x0,%edx
  80164d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801650:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801653:	42                   	inc    %edx
  801654:	84 c9                	test   %cl,%cl
  801656:	75 f5                	jne    80164d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801658:	5b                   	pop    %ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801662:	53                   	push   %ebx
  801663:	e8 84 ff ff ff       	call   8015ec <strlen>
  801668:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801671:	50                   	push   %eax
  801672:	e8 c7 ff ff ff       	call   80163e <strcpy>
	return dst;
}
  801677:	89 d8                	mov    %ebx,%eax
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	56                   	push   %esi
  801682:	53                   	push   %ebx
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 55 0c             	mov    0xc(%ebp),%edx
  801689:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80168c:	85 f6                	test   %esi,%esi
  80168e:	74 15                	je     8016a5 <strncpy+0x27>
  801690:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801695:	8a 1a                	mov    (%edx),%bl
  801697:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80169a:	80 3a 01             	cmpb   $0x1,(%edx)
  80169d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016a0:	41                   	inc    %ecx
  8016a1:	39 ce                	cmp    %ecx,%esi
  8016a3:	77 f0                	ja     801695 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	57                   	push   %edi
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016b8:	85 f6                	test   %esi,%esi
  8016ba:	74 32                	je     8016ee <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016bc:	83 fe 01             	cmp    $0x1,%esi
  8016bf:	74 22                	je     8016e3 <strlcpy+0x3a>
  8016c1:	8a 0b                	mov    (%ebx),%cl
  8016c3:	84 c9                	test   %cl,%cl
  8016c5:	74 20                	je     8016e7 <strlcpy+0x3e>
  8016c7:	89 f8                	mov    %edi,%eax
  8016c9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016ce:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016d1:	88 08                	mov    %cl,(%eax)
  8016d3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016d4:	39 f2                	cmp    %esi,%edx
  8016d6:	74 11                	je     8016e9 <strlcpy+0x40>
  8016d8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016dc:	42                   	inc    %edx
  8016dd:	84 c9                	test   %cl,%cl
  8016df:	75 f0                	jne    8016d1 <strlcpy+0x28>
  8016e1:	eb 06                	jmp    8016e9 <strlcpy+0x40>
  8016e3:	89 f8                	mov    %edi,%eax
  8016e5:	eb 02                	jmp    8016e9 <strlcpy+0x40>
  8016e7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016e9:	c6 00 00             	movb   $0x0,(%eax)
  8016ec:	eb 02                	jmp    8016f0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ee:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016f0:	29 f8                	sub    %edi,%eax
}
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5f                   	pop    %edi
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801700:	8a 01                	mov    (%ecx),%al
  801702:	84 c0                	test   %al,%al
  801704:	74 10                	je     801716 <strcmp+0x1f>
  801706:	3a 02                	cmp    (%edx),%al
  801708:	75 0c                	jne    801716 <strcmp+0x1f>
		p++, q++;
  80170a:	41                   	inc    %ecx
  80170b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80170c:	8a 01                	mov    (%ecx),%al
  80170e:	84 c0                	test   %al,%al
  801710:	74 04                	je     801716 <strcmp+0x1f>
  801712:	3a 02                	cmp    (%edx),%al
  801714:	74 f4                	je     80170a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801716:	0f b6 c0             	movzbl %al,%eax
  801719:	0f b6 12             	movzbl (%edx),%edx
  80171c:	29 d0                	sub    %edx,%eax
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	8b 55 08             	mov    0x8(%ebp),%edx
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80172d:	85 c0                	test   %eax,%eax
  80172f:	74 1b                	je     80174c <strncmp+0x2c>
  801731:	8a 1a                	mov    (%edx),%bl
  801733:	84 db                	test   %bl,%bl
  801735:	74 24                	je     80175b <strncmp+0x3b>
  801737:	3a 19                	cmp    (%ecx),%bl
  801739:	75 20                	jne    80175b <strncmp+0x3b>
  80173b:	48                   	dec    %eax
  80173c:	74 15                	je     801753 <strncmp+0x33>
		n--, p++, q++;
  80173e:	42                   	inc    %edx
  80173f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801740:	8a 1a                	mov    (%edx),%bl
  801742:	84 db                	test   %bl,%bl
  801744:	74 15                	je     80175b <strncmp+0x3b>
  801746:	3a 19                	cmp    (%ecx),%bl
  801748:	74 f1                	je     80173b <strncmp+0x1b>
  80174a:	eb 0f                	jmp    80175b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80174c:	b8 00 00 00 00       	mov    $0x0,%eax
  801751:	eb 05                	jmp    801758 <strncmp+0x38>
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801758:	5b                   	pop    %ebx
  801759:	c9                   	leave  
  80175a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80175b:	0f b6 02             	movzbl (%edx),%eax
  80175e:	0f b6 11             	movzbl (%ecx),%edx
  801761:	29 d0                	sub    %edx,%eax
  801763:	eb f3                	jmp    801758 <strncmp+0x38>

00801765 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80176e:	8a 10                	mov    (%eax),%dl
  801770:	84 d2                	test   %dl,%dl
  801772:	74 18                	je     80178c <strchr+0x27>
		if (*s == c)
  801774:	38 ca                	cmp    %cl,%dl
  801776:	75 06                	jne    80177e <strchr+0x19>
  801778:	eb 17                	jmp    801791 <strchr+0x2c>
  80177a:	38 ca                	cmp    %cl,%dl
  80177c:	74 13                	je     801791 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80177e:	40                   	inc    %eax
  80177f:	8a 10                	mov    (%eax),%dl
  801781:	84 d2                	test   %dl,%dl
  801783:	75 f5                	jne    80177a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801785:	b8 00 00 00 00       	mov    $0x0,%eax
  80178a:	eb 05                	jmp    801791 <strchr+0x2c>
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80179c:	8a 10                	mov    (%eax),%dl
  80179e:	84 d2                	test   %dl,%dl
  8017a0:	74 11                	je     8017b3 <strfind+0x20>
		if (*s == c)
  8017a2:	38 ca                	cmp    %cl,%dl
  8017a4:	75 06                	jne    8017ac <strfind+0x19>
  8017a6:	eb 0b                	jmp    8017b3 <strfind+0x20>
  8017a8:	38 ca                	cmp    %cl,%dl
  8017aa:	74 07                	je     8017b3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017ac:	40                   	inc    %eax
  8017ad:	8a 10                	mov    (%eax),%dl
  8017af:	84 d2                	test   %dl,%dl
  8017b1:	75 f5                	jne    8017a8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	57                   	push   %edi
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c4:	85 c9                	test   %ecx,%ecx
  8017c6:	74 30                	je     8017f8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ce:	75 25                	jne    8017f5 <memset+0x40>
  8017d0:	f6 c1 03             	test   $0x3,%cl
  8017d3:	75 20                	jne    8017f5 <memset+0x40>
		c &= 0xFF;
  8017d5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d8:	89 d3                	mov    %edx,%ebx
  8017da:	c1 e3 08             	shl    $0x8,%ebx
  8017dd:	89 d6                	mov    %edx,%esi
  8017df:	c1 e6 18             	shl    $0x18,%esi
  8017e2:	89 d0                	mov    %edx,%eax
  8017e4:	c1 e0 10             	shl    $0x10,%eax
  8017e7:	09 f0                	or     %esi,%eax
  8017e9:	09 d0                	or     %edx,%eax
  8017eb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017ed:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017f0:	fc                   	cld    
  8017f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8017f3:	eb 03                	jmp    8017f8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f5:	fc                   	cld    
  8017f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017f8:	89 f8                	mov    %edi,%eax
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5f                   	pop    %edi
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	57                   	push   %edi
  801803:	56                   	push   %esi
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 75 0c             	mov    0xc(%ebp),%esi
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80180d:	39 c6                	cmp    %eax,%esi
  80180f:	73 34                	jae    801845 <memmove+0x46>
  801811:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801814:	39 d0                	cmp    %edx,%eax
  801816:	73 2d                	jae    801845 <memmove+0x46>
		s += n;
		d += n;
  801818:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80181b:	f6 c2 03             	test   $0x3,%dl
  80181e:	75 1b                	jne    80183b <memmove+0x3c>
  801820:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801826:	75 13                	jne    80183b <memmove+0x3c>
  801828:	f6 c1 03             	test   $0x3,%cl
  80182b:	75 0e                	jne    80183b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80182d:	83 ef 04             	sub    $0x4,%edi
  801830:	8d 72 fc             	lea    -0x4(%edx),%esi
  801833:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801836:	fd                   	std    
  801837:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801839:	eb 07                	jmp    801842 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80183b:	4f                   	dec    %edi
  80183c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80183f:	fd                   	std    
  801840:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801842:	fc                   	cld    
  801843:	eb 20                	jmp    801865 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801845:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80184b:	75 13                	jne    801860 <memmove+0x61>
  80184d:	a8 03                	test   $0x3,%al
  80184f:	75 0f                	jne    801860 <memmove+0x61>
  801851:	f6 c1 03             	test   $0x3,%cl
  801854:	75 0a                	jne    801860 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801856:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801859:	89 c7                	mov    %eax,%edi
  80185b:	fc                   	cld    
  80185c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185e:	eb 05                	jmp    801865 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801860:	89 c7                	mov    %eax,%edi
  801862:	fc                   	cld    
  801863:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80186c:	ff 75 10             	pushl  0x10(%ebp)
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	ff 75 08             	pushl  0x8(%ebp)
  801875:	e8 85 ff ff ff       	call   8017ff <memmove>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
  801888:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80188b:	85 ff                	test   %edi,%edi
  80188d:	74 32                	je     8018c1 <memcmp+0x45>
		if (*s1 != *s2)
  80188f:	8a 03                	mov    (%ebx),%al
  801891:	8a 0e                	mov    (%esi),%cl
  801893:	38 c8                	cmp    %cl,%al
  801895:	74 19                	je     8018b0 <memcmp+0x34>
  801897:	eb 0d                	jmp    8018a6 <memcmp+0x2a>
  801899:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80189d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018a1:	42                   	inc    %edx
  8018a2:	38 c8                	cmp    %cl,%al
  8018a4:	74 10                	je     8018b6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018a6:	0f b6 c0             	movzbl %al,%eax
  8018a9:	0f b6 c9             	movzbl %cl,%ecx
  8018ac:	29 c8                	sub    %ecx,%eax
  8018ae:	eb 16                	jmp    8018c6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b0:	4f                   	dec    %edi
  8018b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b6:	39 fa                	cmp    %edi,%edx
  8018b8:	75 df                	jne    801899 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bf:	eb 05                	jmp    8018c6 <memcmp+0x4a>
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018d1:	89 c2                	mov    %eax,%edx
  8018d3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018d6:	39 d0                	cmp    %edx,%eax
  8018d8:	73 12                	jae    8018ec <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018da:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018dd:	38 08                	cmp    %cl,(%eax)
  8018df:	75 06                	jne    8018e7 <memfind+0x1c>
  8018e1:	eb 09                	jmp    8018ec <memfind+0x21>
  8018e3:	38 08                	cmp    %cl,(%eax)
  8018e5:	74 05                	je     8018ec <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e7:	40                   	inc    %eax
  8018e8:	39 c2                	cmp    %eax,%edx
  8018ea:	77 f7                	ja     8018e3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	57                   	push   %edi
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fa:	eb 01                	jmp    8018fd <strtol+0xf>
		s++;
  8018fc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018fd:	8a 02                	mov    (%edx),%al
  8018ff:	3c 20                	cmp    $0x20,%al
  801901:	74 f9                	je     8018fc <strtol+0xe>
  801903:	3c 09                	cmp    $0x9,%al
  801905:	74 f5                	je     8018fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801907:	3c 2b                	cmp    $0x2b,%al
  801909:	75 08                	jne    801913 <strtol+0x25>
		s++;
  80190b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80190c:	bf 00 00 00 00       	mov    $0x0,%edi
  801911:	eb 13                	jmp    801926 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801913:	3c 2d                	cmp    $0x2d,%al
  801915:	75 0a                	jne    801921 <strtol+0x33>
		s++, neg = 1;
  801917:	8d 52 01             	lea    0x1(%edx),%edx
  80191a:	bf 01 00 00 00       	mov    $0x1,%edi
  80191f:	eb 05                	jmp    801926 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801921:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801926:	85 db                	test   %ebx,%ebx
  801928:	74 05                	je     80192f <strtol+0x41>
  80192a:	83 fb 10             	cmp    $0x10,%ebx
  80192d:	75 28                	jne    801957 <strtol+0x69>
  80192f:	8a 02                	mov    (%edx),%al
  801931:	3c 30                	cmp    $0x30,%al
  801933:	75 10                	jne    801945 <strtol+0x57>
  801935:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801939:	75 0a                	jne    801945 <strtol+0x57>
		s += 2, base = 16;
  80193b:	83 c2 02             	add    $0x2,%edx
  80193e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801943:	eb 12                	jmp    801957 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801945:	85 db                	test   %ebx,%ebx
  801947:	75 0e                	jne    801957 <strtol+0x69>
  801949:	3c 30                	cmp    $0x30,%al
  80194b:	75 05                	jne    801952 <strtol+0x64>
		s++, base = 8;
  80194d:	42                   	inc    %edx
  80194e:	b3 08                	mov    $0x8,%bl
  801950:	eb 05                	jmp    801957 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801952:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80195e:	8a 0a                	mov    (%edx),%cl
  801960:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801963:	80 fb 09             	cmp    $0x9,%bl
  801966:	77 08                	ja     801970 <strtol+0x82>
			dig = *s - '0';
  801968:	0f be c9             	movsbl %cl,%ecx
  80196b:	83 e9 30             	sub    $0x30,%ecx
  80196e:	eb 1e                	jmp    80198e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801970:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801973:	80 fb 19             	cmp    $0x19,%bl
  801976:	77 08                	ja     801980 <strtol+0x92>
			dig = *s - 'a' + 10;
  801978:	0f be c9             	movsbl %cl,%ecx
  80197b:	83 e9 57             	sub    $0x57,%ecx
  80197e:	eb 0e                	jmp    80198e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801980:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801983:	80 fb 19             	cmp    $0x19,%bl
  801986:	77 13                	ja     80199b <strtol+0xad>
			dig = *s - 'A' + 10;
  801988:	0f be c9             	movsbl %cl,%ecx
  80198b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80198e:	39 f1                	cmp    %esi,%ecx
  801990:	7d 0d                	jge    80199f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801992:	42                   	inc    %edx
  801993:	0f af c6             	imul   %esi,%eax
  801996:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801999:	eb c3                	jmp    80195e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80199b:	89 c1                	mov    %eax,%ecx
  80199d:	eb 02                	jmp    8019a1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80199f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019a5:	74 05                	je     8019ac <strtol+0xbe>
		*endptr = (char *) s;
  8019a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019aa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019ac:	85 ff                	test   %edi,%edi
  8019ae:	74 04                	je     8019b4 <strtol+0xc6>
  8019b0:	89 c8                	mov    %ecx,%eax
  8019b2:	f7 d8                	neg    %eax
}
  8019b4:	5b                   	pop    %ebx
  8019b5:	5e                   	pop    %esi
  8019b6:	5f                   	pop    %edi
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    
  8019b9:	00 00                	add    %al,(%eax)
	...

008019bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	74 0e                	je     8019dc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	50                   	push   %eax
  8019d2:	e8 e0 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	eb 10                	jmp    8019ec <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	68 00 00 c0 ee       	push   $0xeec00000
  8019e4:	e8 ce e8 ff ff       	call   8002b7 <sys_ipc_recv>
  8019e9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	75 26                	jne    801a16 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019f0:	85 f6                	test   %esi,%esi
  8019f2:	74 0a                	je     8019fe <ipc_recv+0x42>
  8019f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f9:	8b 40 74             	mov    0x74(%eax),%eax
  8019fc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8019fe:	85 db                	test   %ebx,%ebx
  801a00:	74 0a                	je     801a0c <ipc_recv+0x50>
  801a02:	a1 04 40 80 00       	mov    0x804004,%eax
  801a07:	8b 40 78             	mov    0x78(%eax),%eax
  801a0a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a11:	8b 40 70             	mov    0x70(%eax),%eax
  801a14:	eb 14                	jmp    801a2a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a16:	85 f6                	test   %esi,%esi
  801a18:	74 06                	je     801a20 <ipc_recv+0x64>
  801a1a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a20:	85 db                	test   %ebx,%ebx
  801a22:	74 06                	je     801a2a <ipc_recv+0x6e>
  801a24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a40:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	75 25                	jne    801a6c <ipc_send+0x3b>
  801a47:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a4c:	eb 1e                	jmp    801a6c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a4e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a51:	75 07                	jne    801a5a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a53:	e8 3d e7 ff ff       	call   800195 <sys_yield>
  801a58:	eb 12                	jmp    801a6c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a5a:	50                   	push   %eax
  801a5b:	68 c0 21 80 00       	push   $0x8021c0
  801a60:	6a 43                	push   $0x43
  801a62:	68 d3 21 80 00       	push   $0x8021d3
  801a67:	e8 44 f5 ff ff       	call   800fb0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	57                   	push   %edi
  801a6f:	ff 75 08             	pushl  0x8(%ebp)
  801a72:	e8 1b e8 ff ff       	call   800292 <sys_ipc_try_send>
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	75 d0                	jne    801a4e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	53                   	push   %ebx
  801a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a8d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a93:	74 22                	je     801ab7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a95:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a9a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801aa1:	89 c2                	mov    %eax,%edx
  801aa3:	c1 e2 07             	shl    $0x7,%edx
  801aa6:	29 ca                	sub    %ecx,%edx
  801aa8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aae:	8b 52 50             	mov    0x50(%edx),%edx
  801ab1:	39 da                	cmp    %ebx,%edx
  801ab3:	75 1d                	jne    801ad2 <ipc_find_env+0x4c>
  801ab5:	eb 05                	jmp    801abc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801abc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ac3:	c1 e0 07             	shl    $0x7,%eax
  801ac6:	29 d0                	sub    %edx,%eax
  801ac8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801acd:	8b 40 40             	mov    0x40(%eax),%eax
  801ad0:	eb 0c                	jmp    801ade <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad2:	40                   	inc    %eax
  801ad3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad8:	75 c0                	jne    801a9a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ada:	66 b8 00 00          	mov    $0x0,%ax
}
  801ade:	5b                   	pop    %ebx
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    
  801ae1:	00 00                	add    %al,(%eax)
	...

00801ae4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	c1 ea 16             	shr    $0x16,%edx
  801aef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801af6:	f6 c2 01             	test   $0x1,%dl
  801af9:	74 1e                	je     801b19 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801afb:	c1 e8 0c             	shr    $0xc,%eax
  801afe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b05:	a8 01                	test   $0x1,%al
  801b07:	74 17                	je     801b20 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b09:	c1 e8 0c             	shr    $0xc,%eax
  801b0c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b13:	ef 
  801b14:	0f b7 c0             	movzwl %ax,%eax
  801b17:	eb 0c                	jmp    801b25 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 05                	jmp    801b25 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    
	...

00801b28 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	57                   	push   %edi
  801b2c:	56                   	push   %esi
  801b2d:	83 ec 10             	sub    $0x10,%esp
  801b30:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b33:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b36:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b39:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b3c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b3f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b42:	85 c0                	test   %eax,%eax
  801b44:	75 2e                	jne    801b74 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b46:	39 f1                	cmp    %esi,%ecx
  801b48:	77 5a                	ja     801ba4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b4a:	85 c9                	test   %ecx,%ecx
  801b4c:	75 0b                	jne    801b59 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b53:	31 d2                	xor    %edx,%edx
  801b55:	f7 f1                	div    %ecx
  801b57:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b59:	31 d2                	xor    %edx,%edx
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	f7 f1                	div    %ecx
  801b5f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b61:	89 f8                	mov    %edi,%eax
  801b63:	f7 f1                	div    %ecx
  801b65:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b67:	89 f8                	mov    %edi,%eax
  801b69:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	5e                   	pop    %esi
  801b6f:	5f                   	pop    %edi
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    
  801b72:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b74:	39 f0                	cmp    %esi,%eax
  801b76:	77 1c                	ja     801b94 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b78:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b7b:	83 f7 1f             	xor    $0x1f,%edi
  801b7e:	75 3c                	jne    801bbc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b80:	39 f0                	cmp    %esi,%eax
  801b82:	0f 82 90 00 00 00    	jb     801c18 <__udivdi3+0xf0>
  801b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b8b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b8e:	0f 86 84 00 00 00    	jbe    801c18 <__udivdi3+0xf0>
  801b94:	31 f6                	xor    %esi,%esi
  801b96:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b98:	89 f8                	mov    %edi,%eax
  801b9a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	5e                   	pop    %esi
  801ba0:	5f                   	pop    %edi
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    
  801ba3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba4:	89 f2                	mov    %esi,%edx
  801ba6:	89 f8                	mov    %edi,%eax
  801ba8:	f7 f1                	div    %ecx
  801baa:	89 c7                	mov    %eax,%edi
  801bac:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bae:	89 f8                	mov    %edi,%eax
  801bb0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    
  801bb9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bbc:	89 f9                	mov    %edi,%ecx
  801bbe:	d3 e0                	shl    %cl,%eax
  801bc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bc3:	b8 20 00 00 00       	mov    $0x20,%eax
  801bc8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcd:	88 c1                	mov    %al,%cl
  801bcf:	d3 ea                	shr    %cl,%edx
  801bd1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bd4:	09 ca                	or     %ecx,%edx
  801bd6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bdc:	89 f9                	mov    %edi,%ecx
  801bde:	d3 e2                	shl    %cl,%edx
  801be0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801be3:	89 f2                	mov    %esi,%edx
  801be5:	88 c1                	mov    %al,%cl
  801be7:	d3 ea                	shr    %cl,%edx
  801be9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801bec:	89 f2                	mov    %esi,%edx
  801bee:	89 f9                	mov    %edi,%ecx
  801bf0:	d3 e2                	shl    %cl,%edx
  801bf2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bf5:	88 c1                	mov    %al,%cl
  801bf7:	d3 ee                	shr    %cl,%esi
  801bf9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bfb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bfe:	89 f0                	mov    %esi,%eax
  801c00:	89 ca                	mov    %ecx,%edx
  801c02:	f7 75 ec             	divl   -0x14(%ebp)
  801c05:	89 d1                	mov    %edx,%ecx
  801c07:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c09:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c0c:	39 d1                	cmp    %edx,%ecx
  801c0e:	72 28                	jb     801c38 <__udivdi3+0x110>
  801c10:	74 1a                	je     801c2c <__udivdi3+0x104>
  801c12:	89 f7                	mov    %esi,%edi
  801c14:	31 f6                	xor    %esi,%esi
  801c16:	eb 80                	jmp    801b98 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	5e                   	pop    %esi
  801c27:	5f                   	pop    %edi
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    
  801c2a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2f:	89 f9                	mov    %edi,%ecx
  801c31:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c33:	39 c2                	cmp    %eax,%edx
  801c35:	73 db                	jae    801c12 <__udivdi3+0xea>
  801c37:	90                   	nop
		{
		  q0--;
  801c38:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c3b:	31 f6                	xor    %esi,%esi
  801c3d:	e9 56 ff ff ff       	jmp    801b98 <__udivdi3+0x70>
	...

00801c44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	57                   	push   %edi
  801c48:	56                   	push   %esi
  801c49:	83 ec 20             	sub    $0x20,%esp
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c52:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c61:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c63:	85 ff                	test   %edi,%edi
  801c65:	75 15                	jne    801c7c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c67:	39 f1                	cmp    %esi,%ecx
  801c69:	0f 86 99 00 00 00    	jbe    801d08 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c6f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c71:	89 d0                	mov    %edx,%eax
  801c73:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c75:	83 c4 20             	add    $0x20,%esp
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c7c:	39 f7                	cmp    %esi,%edi
  801c7e:	0f 87 a4 00 00 00    	ja     801d28 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c84:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c87:	83 f0 1f             	xor    $0x1f,%eax
  801c8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c8d:	0f 84 a1 00 00 00    	je     801d34 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c93:	89 f8                	mov    %edi,%eax
  801c95:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c98:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c9a:	bf 20 00 00 00       	mov    $0x20,%edi
  801c9f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ca2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 ea                	shr    %cl,%edx
  801ca9:	09 c2                	or     %eax,%edx
  801cab:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb4:	d3 e0                	shl    %cl,%eax
  801cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cb9:	89 f2                	mov    %esi,%edx
  801cbb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc0:	d3 e0                	shl    %cl,%eax
  801cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc8:	89 f9                	mov    %edi,%ecx
  801cca:	d3 e8                	shr    %cl,%eax
  801ccc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cce:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	f7 75 f0             	divl   -0x10(%ebp)
  801cd5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cd7:	f7 65 f4             	mull   -0xc(%ebp)
  801cda:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cdd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cdf:	39 d6                	cmp    %edx,%esi
  801ce1:	72 71                	jb     801d54 <__umoddi3+0x110>
  801ce3:	74 7f                	je     801d64 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ce5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce8:	29 c8                	sub    %ecx,%eax
  801cea:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801cec:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cef:	d3 e8                	shr    %cl,%eax
  801cf1:	89 f2                	mov    %esi,%edx
  801cf3:	89 f9                	mov    %edi,%ecx
  801cf5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801cf7:	09 d0                	or     %edx,%eax
  801cf9:	89 f2                	mov    %esi,%edx
  801cfb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cfe:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d00:	83 c4 20             	add    $0x20,%esp
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    
  801d07:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d08:	85 c9                	test   %ecx,%ecx
  801d0a:	75 0b                	jne    801d17 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	f7 f1                	div    %ecx
  801d15:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	31 d2                	xor    %edx,%edx
  801d1b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d20:	f7 f1                	div    %ecx
  801d22:	e9 4a ff ff ff       	jmp    801c71 <__umoddi3+0x2d>
  801d27:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d28:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2a:	83 c4 20             	add    $0x20,%esp
  801d2d:	5e                   	pop    %esi
  801d2e:	5f                   	pop    %edi
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    
  801d31:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d34:	39 f7                	cmp    %esi,%edi
  801d36:	72 05                	jb     801d3d <__umoddi3+0xf9>
  801d38:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d3b:	77 0c                	ja     801d49 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d42:	29 c8                	sub    %ecx,%eax
  801d44:	19 fa                	sbb    %edi,%edx
  801d46:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d54:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d57:	89 c1                	mov    %eax,%ecx
  801d59:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d5c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d5f:	eb 84                	jmp    801ce5 <__umoddi3+0xa1>
  801d61:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d64:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d67:	72 eb                	jb     801d54 <__umoddi3+0x110>
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	e9 75 ff ff ff       	jmp    801ce5 <__umoddi3+0xa1>
