
obj/user/evilhello.debug:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 bf 00 00 00       	call   800105 <sys_cputs>
  800046:	83 c4 10             	add    $0x10,%esp
}
  800049:	c9                   	leave  
  80004a:	c3                   	ret    
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
  8000ea:	68 ca 1d 80 00       	push   $0x801dca
  8000ef:	6a 42                	push   $0x42
  8000f1:	68 e7 1d 80 00       	push   $0x801de7
  8000f6:	e8 d5 0e 00 00       	call   800fd0 <_panic>

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
  80041e:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
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
  800436:	68 f8 1d 80 00       	push   $0x801df8
  80043b:	e8 68 0c 00 00       	call   8010a8 <cprintf>
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
  800666:	68 39 1e 80 00       	push   $0x801e39
  80066b:	e8 38 0a 00 00       	call   8010a8 <cprintf>
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
  80073d:	68 55 1e 80 00       	push   $0x801e55
  800742:	e8 61 09 00 00       	call   8010a8 <cprintf>
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
  8007e8:	68 18 1e 80 00       	push   $0x801e18
  8007ed:	e8 b6 08 00 00       	call   8010a8 <cprintf>
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
  80089f:	e8 8b 01 00 00       	call   800a2f <open>
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
  8008eb:	e8 e9 11 00 00       	call   801ad9 <ipc_find_env>
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
  800906:	e8 79 11 00 00       	call   801a84 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80090b:	83 c4 0c             	add    $0xc,%esp
  80090e:	6a 00                	push   $0x0
  800910:	56                   	push   %esi
  800911:	6a 00                	push   $0x0
  800913:	e8 c4 10 00 00       	call   8019dc <ipc_recv>
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
  800945:	78 39                	js     800980 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	68 84 1e 80 00       	push   $0x801e84
  80094f:	e8 54 07 00 00       	call   8010a8 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800954:	83 c4 08             	add    $0x8,%esp
  800957:	68 00 50 80 00       	push   $0x805000
  80095c:	53                   	push   %ebx
  80095d:	e8 fc 0c 00 00       	call   80165e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800962:	a1 80 50 80 00       	mov    0x805080,%eax
  800967:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80096d:	a1 84 50 80 00       	mov    0x805084,%eax
  800972:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 40 0c             	mov    0xc(%eax),%eax
  800991:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a0:	e8 2f ff ff ff       	call   8008d4 <fsipc>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009ba:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8009ca:	e8 05 ff ff ff       	call   8008d4 <fsipc>
  8009cf:	89 c3                	mov    %eax,%ebx
  8009d1:	85 c0                	test   %eax,%eax
  8009d3:	78 51                	js     800a26 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 19                	jae    8009f2 <devfile_read+0x4b>
  8009d9:	68 8a 1e 80 00       	push   $0x801e8a
  8009de:	68 91 1e 80 00       	push   $0x801e91
  8009e3:	68 80 00 00 00       	push   $0x80
  8009e8:	68 a6 1e 80 00       	push   $0x801ea6
  8009ed:	e8 de 05 00 00       	call   800fd0 <_panic>
	assert(r <= PGSIZE);
  8009f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009f7:	7e 19                	jle    800a12 <devfile_read+0x6b>
  8009f9:	68 b1 1e 80 00       	push   $0x801eb1
  8009fe:	68 91 1e 80 00       	push   $0x801e91
  800a03:	68 81 00 00 00       	push   $0x81
  800a08:	68 a6 1e 80 00       	push   $0x801ea6
  800a0d:	e8 be 05 00 00       	call   800fd0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a12:	83 ec 04             	sub    $0x4,%esp
  800a15:	50                   	push   %eax
  800a16:	68 00 50 80 00       	push   $0x805000
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	e8 fc 0d 00 00       	call   80181f <memmove>
	return r;
  800a23:	83 c4 10             	add    $0x10,%esp
}
  800a26:	89 d8                	mov    %ebx,%eax
  800a28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	83 ec 1c             	sub    $0x1c,%esp
  800a37:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a3a:	56                   	push   %esi
  800a3b:	e8 cc 0b 00 00       	call   80160c <strlen>
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a48:	7f 72                	jg     800abc <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a50:	50                   	push   %eax
  800a51:	e8 ce f8 ff ff       	call   800324 <fd_alloc>
  800a56:	89 c3                	mov    %eax,%ebx
  800a58:	83 c4 10             	add    $0x10,%esp
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	78 62                	js     800ac1 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	56                   	push   %esi
  800a63:	68 00 50 80 00       	push   $0x805000
  800a68:	e8 f1 0b 00 00       	call   80165e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a70:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a78:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7d:	e8 52 fe ff ff       	call   8008d4 <fsipc>
  800a82:	89 c3                	mov    %eax,%ebx
  800a84:	83 c4 10             	add    $0x10,%esp
  800a87:	85 c0                	test   %eax,%eax
  800a89:	79 12                	jns    800a9d <open+0x6e>
		fd_close(fd, 0);
  800a8b:	83 ec 08             	sub    $0x8,%esp
  800a8e:	6a 00                	push   $0x0
  800a90:	ff 75 f4             	pushl  -0xc(%ebp)
  800a93:	e8 bb f9 ff ff       	call   800453 <fd_close>
		return r;
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	eb 24                	jmp    800ac1 <open+0x92>
	}


	cprintf("OPEN\n");
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	68 bd 1e 80 00       	push   $0x801ebd
  800aa5:	e8 fe 05 00 00       	call   8010a8 <cprintf>

	return fd2num(fd);
  800aaa:	83 c4 04             	add    $0x4,%esp
  800aad:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab0:	e8 47 f8 ff ff       	call   8002fc <fd2num>
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	eb 05                	jmp    800ac1 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800abc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    
	...

00800acc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	ff 75 08             	pushl  0x8(%ebp)
  800ada:	e8 2d f8 ff ff       	call   80030c <fd2data>
  800adf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ae1:	83 c4 08             	add    $0x8,%esp
  800ae4:	68 c3 1e 80 00       	push   $0x801ec3
  800ae9:	56                   	push   %esi
  800aea:	e8 6f 0b 00 00       	call   80165e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800aef:	8b 43 04             	mov    0x4(%ebx),%eax
  800af2:	2b 03                	sub    (%ebx),%eax
  800af4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800afa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b01:	00 00 00 
	stat->st_dev = &devpipe;
  800b04:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b0b:	30 80 00 
	return 0;
}
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b24:	53                   	push   %ebx
  800b25:	6a 00                	push   $0x0
  800b27:	e8 da f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b2c:	89 1c 24             	mov    %ebx,(%esp)
  800b2f:	e8 d8 f7 ff ff       	call   80030c <fd2data>
  800b34:	83 c4 08             	add    $0x8,%esp
  800b37:	50                   	push   %eax
  800b38:	6a 00                	push   $0x0
  800b3a:	e8 c7 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 1c             	sub    $0x1c,%esp
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b52:	a1 04 40 80 00       	mov    0x804004,%eax
  800b57:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	57                   	push   %edi
  800b5e:	e8 d1 0f 00 00       	call   801b34 <pageref>
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	83 c4 04             	add    $0x4,%esp
  800b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6b:	e8 c4 0f 00 00       	call   801b34 <pageref>
  800b70:	83 c4 10             	add    $0x10,%esp
  800b73:	39 c6                	cmp    %eax,%esi
  800b75:	0f 94 c0             	sete   %al
  800b78:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b7b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b81:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b84:	39 cb                	cmp    %ecx,%ebx
  800b86:	75 08                	jne    800b90 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b90:	83 f8 01             	cmp    $0x1,%eax
  800b93:	75 bd                	jne    800b52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b95:	8b 42 58             	mov    0x58(%edx),%eax
  800b98:	6a 01                	push   $0x1
  800b9a:	50                   	push   %eax
  800b9b:	53                   	push   %ebx
  800b9c:	68 ca 1e 80 00       	push   $0x801eca
  800ba1:	e8 02 05 00 00       	call   8010a8 <cprintf>
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	eb a7                	jmp    800b52 <_pipeisclosed+0xe>

00800bab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 28             	sub    $0x28,%esp
  800bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bb7:	56                   	push   %esi
  800bb8:	e8 4f f7 ff ff       	call   80030c <fd2data>
  800bbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bbf:	83 c4 10             	add    $0x10,%esp
  800bc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc6:	75 4a                	jne    800c12 <devpipe_write+0x67>
  800bc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcd:	eb 56                	jmp    800c25 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bcf:	89 da                	mov    %ebx,%edx
  800bd1:	89 f0                	mov    %esi,%eax
  800bd3:	e8 6c ff ff ff       	call   800b44 <_pipeisclosed>
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	75 4d                	jne    800c29 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bdc:	e8 b4 f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800be1:	8b 43 04             	mov    0x4(%ebx),%eax
  800be4:	8b 13                	mov    (%ebx),%edx
  800be6:	83 c2 20             	add    $0x20,%edx
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	73 e2                	jae    800bcf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bf5:	79 05                	jns    800bfc <devpipe_write+0x51>
  800bf7:	4a                   	dec    %edx
  800bf8:	83 ca e0             	or     $0xffffffe0,%edx
  800bfb:	42                   	inc    %edx
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c06:	40                   	inc    %eax
  800c07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c0a:	47                   	inc    %edi
  800c0b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c0e:	77 07                	ja     800c17 <devpipe_write+0x6c>
  800c10:	eb 13                	jmp    800c25 <devpipe_write+0x7a>
  800c12:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c17:	8b 43 04             	mov    0x4(%ebx),%eax
  800c1a:	8b 13                	mov    (%ebx),%edx
  800c1c:	83 c2 20             	add    $0x20,%edx
  800c1f:	39 d0                	cmp    %edx,%eax
  800c21:	73 ac                	jae    800bcf <devpipe_write+0x24>
  800c23:	eb c8                	jmp    800bed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	eb 05                	jmp    800c2e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 18             	sub    $0x18,%esp
  800c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c42:	57                   	push   %edi
  800c43:	e8 c4 f6 ff ff       	call   80030c <fd2data>
  800c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c51:	75 44                	jne    800c97 <devpipe_read+0x61>
  800c53:	be 00 00 00 00       	mov    $0x0,%esi
  800c58:	eb 4f                	jmp    800ca9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c5a:	89 f0                	mov    %esi,%eax
  800c5c:	eb 54                	jmp    800cb2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c5e:	89 da                	mov    %ebx,%edx
  800c60:	89 f8                	mov    %edi,%eax
  800c62:	e8 dd fe ff ff       	call   800b44 <_pipeisclosed>
  800c67:	85 c0                	test   %eax,%eax
  800c69:	75 42                	jne    800cad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c6b:	e8 25 f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c70:	8b 03                	mov    (%ebx),%eax
  800c72:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c75:	74 e7                	je     800c5e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c77:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c7c:	79 05                	jns    800c83 <devpipe_read+0x4d>
  800c7e:	48                   	dec    %eax
  800c7f:	83 c8 e0             	or     $0xffffffe0,%eax
  800c82:	40                   	inc    %eax
  800c83:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c8d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8f:	46                   	inc    %esi
  800c90:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c93:	77 07                	ja     800c9c <devpipe_read+0x66>
  800c95:	eb 12                	jmp    800ca9 <devpipe_read+0x73>
  800c97:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c9c:	8b 03                	mov    (%ebx),%eax
  800c9e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca1:	75 d4                	jne    800c77 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca3:	85 f6                	test   %esi,%esi
  800ca5:	75 b3                	jne    800c5a <devpipe_read+0x24>
  800ca7:	eb b5                	jmp    800c5e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	eb 05                	jmp    800cb2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 28             	sub    $0x28,%esp
  800cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc9:	50                   	push   %eax
  800cca:	e8 55 f6 ff ff       	call   800324 <fd_alloc>
  800ccf:	89 c3                	mov    %eax,%ebx
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	0f 88 24 01 00 00    	js     800e00 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cdc:	83 ec 04             	sub    $0x4,%esp
  800cdf:	68 07 04 00 00       	push   $0x407
  800ce4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ce7:	6a 00                	push   $0x0
  800ce9:	e8 ce f4 ff ff       	call   8001bc <sys_page_alloc>
  800cee:	89 c3                	mov    %eax,%ebx
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	0f 88 05 01 00 00    	js     800e00 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d01:	50                   	push   %eax
  800d02:	e8 1d f6 ff ff       	call   800324 <fd_alloc>
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	0f 88 dc 00 00 00    	js     800df0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d14:	83 ec 04             	sub    $0x4,%esp
  800d17:	68 07 04 00 00       	push   $0x407
  800d1c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d1f:	6a 00                	push   $0x0
  800d21:	e8 96 f4 ff ff       	call   8001bc <sys_page_alloc>
  800d26:	89 c3                	mov    %eax,%ebx
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	0f 88 bd 00 00 00    	js     800df0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d39:	e8 ce f5 ff ff       	call   80030c <fd2data>
  800d3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d40:	83 c4 0c             	add    $0xc,%esp
  800d43:	68 07 04 00 00       	push   $0x407
  800d48:	50                   	push   %eax
  800d49:	6a 00                	push   $0x0
  800d4b:	e8 6c f4 ff ff       	call   8001bc <sys_page_alloc>
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	0f 88 83 00 00 00    	js     800de0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	ff 75 e0             	pushl  -0x20(%ebp)
  800d63:	e8 a4 f5 ff ff       	call   80030c <fd2data>
  800d68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d6f:	50                   	push   %eax
  800d70:	6a 00                	push   $0x0
  800d72:	56                   	push   %esi
  800d73:	6a 00                	push   $0x0
  800d75:	e8 66 f4 ff ff       	call   8001e0 <sys_page_map>
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 4f                	js     800dd2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800db3:	e8 44 f5 ff ff       	call   8002fc <fd2num>
  800db8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dba:	83 c4 04             	add    $0x4,%esp
  800dbd:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc0:	e8 37 f5 ff ff       	call   8002fc <fd2num>
  800dc5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd0:	eb 2e                	jmp    800e00 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dd2:	83 ec 08             	sub    $0x8,%esp
  800dd5:	56                   	push   %esi
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 29 f4 ff ff       	call   800206 <sys_page_unmap>
  800ddd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800de0:	83 ec 08             	sub    $0x8,%esp
  800de3:	ff 75 e0             	pushl  -0x20(%ebp)
  800de6:	6a 00                	push   $0x0
  800de8:	e8 19 f4 ff ff       	call   800206 <sys_page_unmap>
  800ded:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800df6:	6a 00                	push   $0x0
  800df8:	e8 09 f4 ff ff       	call   800206 <sys_page_unmap>
  800dfd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e13:	50                   	push   %eax
  800e14:	ff 75 08             	pushl  0x8(%ebp)
  800e17:	e8 7b f5 ff ff       	call   800397 <fd_lookup>
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 18                	js     800e3b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	e8 de f4 ff ff       	call   80030c <fd2data>
	return _pipeisclosed(fd, p);
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e33:	e8 0c fd ff ff       	call   800b44 <_pipeisclosed>
  800e38:	83 c4 10             	add    $0x10,%esp
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    
  800e3d:	00 00                	add    %al,(%eax)
	...

00800e40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e50:	68 e2 1e 80 00       	push   $0x801ee2
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	e8 01 08 00 00       	call   80165e <strcpy>
	return 0;
}
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e74:	74 45                	je     800ebb <devcons_write+0x57>
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e89:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e8b:	83 fb 7f             	cmp    $0x7f,%ebx
  800e8e:	76 05                	jbe    800e95 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e90:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	53                   	push   %ebx
  800e99:	03 45 0c             	add    0xc(%ebp),%eax
  800e9c:	50                   	push   %eax
  800e9d:	57                   	push   %edi
  800e9e:	e8 7c 09 00 00       	call   80181f <memmove>
		sys_cputs(buf, m);
  800ea3:	83 c4 08             	add    $0x8,%esp
  800ea6:	53                   	push   %ebx
  800ea7:	57                   	push   %edi
  800ea8:	e8 58 f2 ff ff       	call   800105 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ead:	01 de                	add    %ebx,%esi
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eb7:	72 cd                	jb     800e86 <devcons_write+0x22>
  800eb9:	eb 05                	jmp    800ec0 <devcons_write+0x5c>
  800ebb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ec0:	89 f0                	mov    %esi,%eax
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ed0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed4:	75 07                	jne    800edd <devcons_read+0x13>
  800ed6:	eb 25                	jmp    800efd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ed8:	e8 b8 f2 ff ff       	call   800195 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800edd:	e8 49 f2 ff ff       	call   80012b <sys_cgetc>
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	74 f2                	je     800ed8 <devcons_read+0xe>
  800ee6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 1d                	js     800f09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800eec:	83 f8 04             	cmp    $0x4,%eax
  800eef:	74 13                	je     800f04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	88 10                	mov    %dl,(%eax)
	return 1;
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	eb 0c                	jmp    800f09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	eb 05                	jmp    800f09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
  800f14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f17:	6a 01                	push   $0x1
  800f19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f1c:	50                   	push   %eax
  800f1d:	e8 e3 f1 ff ff       	call   800105 <sys_cputs>
  800f22:	83 c4 10             	add    $0x10,%esp
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <getchar>:

int
getchar(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f2d:	6a 01                	push   $0x1
  800f2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	6a 00                	push   $0x0
  800f35:	e8 de f6 ff ff       	call   800618 <read>
	if (r < 0)
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 0f                	js     800f50 <getchar+0x29>
		return r;
	if (r < 1)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 06                	jle    800f4b <getchar+0x24>
		return -E_EOF;
	return c;
  800f45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f49:	eb 05                	jmp    800f50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	ff 75 08             	pushl  0x8(%ebp)
  800f5f:	e8 33 f4 ff ff       	call   800397 <fd_lookup>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 11                	js     800f7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f74:	39 10                	cmp    %edx,(%eax)
  800f76:	0f 94 c0             	sete   %al
  800f79:	0f b6 c0             	movzbl %al,%eax
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <opencons>:

int
opencons(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	e8 97 f3 ff ff       	call   800324 <fd_alloc>
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 3a                	js     800fce <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 07 04 00 00       	push   $0x407
  800f9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 16 f2 ff ff       	call   8001bc <sys_page_alloc>
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 21                	js     800fce <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	50                   	push   %eax
  800fc6:	e8 31 f3 ff ff       	call   8002fc <fd2num>
  800fcb:	83 c4 10             	add    $0x10,%esp
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fde:	e8 8e f1 ff ff       	call   800171 <sys_getenvid>
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	ff 75 0c             	pushl  0xc(%ebp)
  800fe9:	ff 75 08             	pushl  0x8(%ebp)
  800fec:	53                   	push   %ebx
  800fed:	50                   	push   %eax
  800fee:	68 f0 1e 80 00       	push   $0x801ef0
  800ff3:	e8 b0 00 00 00       	call   8010a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff8:	83 c4 18             	add    $0x18,%esp
  800ffb:	56                   	push   %esi
  800ffc:	ff 75 10             	pushl  0x10(%ebp)
  800fff:	e8 53 00 00 00       	call   801057 <vcprintf>
	cprintf("\n");
  801004:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  80100b:	e8 98 00 00 00       	call   8010a8 <cprintf>
  801010:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801013:	cc                   	int3   
  801014:	eb fd                	jmp    801013 <_panic+0x43>
	...

00801018 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	53                   	push   %ebx
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801022:	8b 03                	mov    (%ebx),%eax
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80102b:	40                   	inc    %eax
  80102c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80102e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801033:	75 1a                	jne    80104f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	68 ff 00 00 00       	push   $0xff
  80103d:	8d 43 08             	lea    0x8(%ebx),%eax
  801040:	50                   	push   %eax
  801041:	e8 bf f0 ff ff       	call   800105 <sys_cputs>
		b->idx = 0;
  801046:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80104c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80104f:	ff 43 04             	incl   0x4(%ebx)
}
  801052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801060:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801067:	00 00 00 
	b.cnt = 0;
  80106a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801071:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801074:	ff 75 0c             	pushl  0xc(%ebp)
  801077:	ff 75 08             	pushl  0x8(%ebp)
  80107a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	68 18 10 80 00       	push   $0x801018
  801086:	e8 82 01 00 00       	call   80120d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801094:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	e8 65 f0 ff ff       	call   800105 <sys_cputs>

	return b.cnt;
}
  8010a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010b1:	50                   	push   %eax
  8010b2:	ff 75 08             	pushl  0x8(%ebp)
  8010b5:	e8 9d ff ff ff       	call   801057 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 2c             	sub    $0x2c,%esp
  8010c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c8:	89 d6                	mov    %edx,%esi
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010dc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010e9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010ec:	72 0c                	jb     8010fa <printnum+0x3e>
  8010ee:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010f1:	76 07                	jbe    8010fa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010f3:	4b                   	dec    %ebx
  8010f4:	85 db                	test   %ebx,%ebx
  8010f6:	7f 31                	jg     801129 <printnum+0x6d>
  8010f8:	eb 3f                	jmp    801139 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	57                   	push   %edi
  8010fe:	4b                   	dec    %ebx
  8010ff:	53                   	push   %ebx
  801100:	50                   	push   %eax
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	ff 75 d4             	pushl  -0x2c(%ebp)
  801107:	ff 75 d0             	pushl  -0x30(%ebp)
  80110a:	ff 75 dc             	pushl  -0x24(%ebp)
  80110d:	ff 75 d8             	pushl  -0x28(%ebp)
  801110:	e8 63 0a 00 00       	call   801b78 <__udivdi3>
  801115:	83 c4 18             	add    $0x18,%esp
  801118:	52                   	push   %edx
  801119:	50                   	push   %eax
  80111a:	89 f2                	mov    %esi,%edx
  80111c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111f:	e8 98 ff ff ff       	call   8010bc <printnum>
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	eb 10                	jmp    801139 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	56                   	push   %esi
  80112d:	57                   	push   %edi
  80112e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801131:	4b                   	dec    %ebx
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 db                	test   %ebx,%ebx
  801137:	7f f0                	jg     801129 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	56                   	push   %esi
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	ff 75 d4             	pushl  -0x2c(%ebp)
  801143:	ff 75 d0             	pushl  -0x30(%ebp)
  801146:	ff 75 dc             	pushl  -0x24(%ebp)
  801149:	ff 75 d8             	pushl  -0x28(%ebp)
  80114c:	e8 43 0b 00 00       	call   801c94 <__umoddi3>
  801151:	83 c4 14             	add    $0x14,%esp
  801154:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  80115b:	50                   	push   %eax
  80115c:	ff 55 e4             	call   *-0x1c(%ebp)
  80115f:	83 c4 10             	add    $0x10,%esp
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80116d:	83 fa 01             	cmp    $0x1,%edx
  801170:	7e 0e                	jle    801180 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801172:	8b 10                	mov    (%eax),%edx
  801174:	8d 4a 08             	lea    0x8(%edx),%ecx
  801177:	89 08                	mov    %ecx,(%eax)
  801179:	8b 02                	mov    (%edx),%eax
  80117b:	8b 52 04             	mov    0x4(%edx),%edx
  80117e:	eb 22                	jmp    8011a2 <getuint+0x38>
	else if (lflag)
  801180:	85 d2                	test   %edx,%edx
  801182:	74 10                	je     801194 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801184:	8b 10                	mov    (%eax),%edx
  801186:	8d 4a 04             	lea    0x4(%edx),%ecx
  801189:	89 08                	mov    %ecx,(%eax)
  80118b:	8b 02                	mov    (%edx),%eax
  80118d:	ba 00 00 00 00       	mov    $0x0,%edx
  801192:	eb 0e                	jmp    8011a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801194:	8b 10                	mov    (%eax),%edx
  801196:	8d 4a 04             	lea    0x4(%edx),%ecx
  801199:	89 08                	mov    %ecx,(%eax)
  80119b:	8b 02                	mov    (%edx),%eax
  80119d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a7:	83 fa 01             	cmp    $0x1,%edx
  8011aa:	7e 0e                	jle    8011ba <getint+0x16>
		return va_arg(*ap, long long);
  8011ac:	8b 10                	mov    (%eax),%edx
  8011ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b1:	89 08                	mov    %ecx,(%eax)
  8011b3:	8b 02                	mov    (%edx),%eax
  8011b5:	8b 52 04             	mov    0x4(%edx),%edx
  8011b8:	eb 1a                	jmp    8011d4 <getint+0x30>
	else if (lflag)
  8011ba:	85 d2                	test   %edx,%edx
  8011bc:	74 0c                	je     8011ca <getint+0x26>
		return va_arg(*ap, long);
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c3:	89 08                	mov    %ecx,(%eax)
  8011c5:	8b 02                	mov    (%edx),%eax
  8011c7:	99                   	cltd   
  8011c8:	eb 0a                	jmp    8011d4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011ca:	8b 10                	mov    (%eax),%edx
  8011cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cf:	89 08                	mov    %ecx,(%eax)
  8011d1:	8b 02                	mov    (%edx),%eax
  8011d3:	99                   	cltd   
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011dc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011df:	8b 10                	mov    (%eax),%edx
  8011e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e4:	73 08                	jae    8011ee <sprintputch+0x18>
		*b->buf++ = ch;
  8011e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e9:	88 0a                	mov    %cl,(%edx)
  8011eb:	42                   	inc    %edx
  8011ec:	89 10                	mov    %edx,(%eax)
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 05 00 00 00       	call   80120d <vprintfmt>
	va_end(ap);
  801208:	83 c4 10             	add    $0x10,%esp
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
  801216:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801219:	8b 75 10             	mov    0x10(%ebp),%esi
  80121c:	eb 13                	jmp    801231 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 84 6d 03 00 00    	je     801593 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	57                   	push   %edi
  80122a:	50                   	push   %eax
  80122b:	ff 55 08             	call   *0x8(%ebp)
  80122e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801231:	0f b6 06             	movzbl (%esi),%eax
  801234:	46                   	inc    %esi
  801235:	83 f8 25             	cmp    $0x25,%eax
  801238:	75 e4                	jne    80121e <vprintfmt+0x11>
  80123a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80123e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801245:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80124c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801253:	b9 00 00 00 00       	mov    $0x0,%ecx
  801258:	eb 28                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80125c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801260:	eb 20                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801264:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801268:	eb 18                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80126c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801273:	eb 0d                	jmp    801282 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801275:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801282:	8a 06                	mov    (%esi),%al
  801284:	0f b6 d0             	movzbl %al,%edx
  801287:	8d 5e 01             	lea    0x1(%esi),%ebx
  80128a:	83 e8 23             	sub    $0x23,%eax
  80128d:	3c 55                	cmp    $0x55,%al
  80128f:	0f 87 e0 02 00 00    	ja     801575 <vprintfmt+0x368>
  801295:	0f b6 c0             	movzbl %al,%eax
  801298:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129f:	83 ea 30             	sub    $0x30,%edx
  8012a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012a5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012a8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012ab:	83 fa 09             	cmp    $0x9,%edx
  8012ae:	77 44                	ja     8012f4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	89 de                	mov    %ebx,%esi
  8012b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012b9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012bd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012c3:	83 fb 09             	cmp    $0x9,%ebx
  8012c6:	76 ed                	jbe    8012b5 <vprintfmt+0xa8>
  8012c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012cb:	eb 29                	jmp    8012f6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d0:	8d 50 04             	lea    0x4(%eax),%edx
  8012d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d6:	8b 00                	mov    (%eax),%eax
  8012d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012dd:	eb 17                	jmp    8012f6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e3:	78 85                	js     80126a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e5:	89 de                	mov    %ebx,%esi
  8012e7:	eb 99                	jmp    801282 <vprintfmt+0x75>
  8012e9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012f2:	eb 8e                	jmp    801282 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012fa:	79 86                	jns    801282 <vprintfmt+0x75>
  8012fc:	e9 74 ff ff ff       	jmp    801275 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801301:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801302:	89 de                	mov    %ebx,%esi
  801304:	e9 79 ff ff ff       	jmp    801282 <vprintfmt+0x75>
  801309:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80130c:	8b 45 14             	mov    0x14(%ebp),%eax
  80130f:	8d 50 04             	lea    0x4(%eax),%edx
  801312:	89 55 14             	mov    %edx,0x14(%ebp)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	57                   	push   %edi
  801319:	ff 30                	pushl  (%eax)
  80131b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80131e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801324:	e9 08 ff ff ff       	jmp    801231 <vprintfmt+0x24>
  801329:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	8d 50 04             	lea    0x4(%eax),%edx
  801332:	89 55 14             	mov    %edx,0x14(%ebp)
  801335:	8b 00                	mov    (%eax),%eax
  801337:	85 c0                	test   %eax,%eax
  801339:	79 02                	jns    80133d <vprintfmt+0x130>
  80133b:	f7 d8                	neg    %eax
  80133d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133f:	83 f8 0f             	cmp    $0xf,%eax
  801342:	7f 0b                	jg     80134f <vprintfmt+0x142>
  801344:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	75 1a                	jne    801369 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80134f:	52                   	push   %edx
  801350:	68 2b 1f 80 00       	push   $0x801f2b
  801355:	57                   	push   %edi
  801356:	ff 75 08             	pushl  0x8(%ebp)
  801359:	e8 92 fe ff ff       	call   8011f0 <printfmt>
  80135e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801364:	e9 c8 fe ff ff       	jmp    801231 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801369:	50                   	push   %eax
  80136a:	68 a3 1e 80 00       	push   $0x801ea3
  80136f:	57                   	push   %edi
  801370:	ff 75 08             	pushl  0x8(%ebp)
  801373:	e8 78 fe ff ff       	call   8011f0 <printfmt>
  801378:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80137e:	e9 ae fe ff ff       	jmp    801231 <vprintfmt+0x24>
  801383:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801386:	89 de                	mov    %ebx,%esi
  801388:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80138b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138e:	8b 45 14             	mov    0x14(%ebp),%eax
  801391:	8d 50 04             	lea    0x4(%eax),%edx
  801394:	89 55 14             	mov    %edx,0x14(%ebp)
  801397:	8b 00                	mov    (%eax),%eax
  801399:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	75 07                	jne    8013a7 <vprintfmt+0x19a>
				p = "(null)";
  8013a0:	c7 45 d0 24 1f 80 00 	movl   $0x801f24,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013a7:	85 db                	test   %ebx,%ebx
  8013a9:	7e 42                	jle    8013ed <vprintfmt+0x1e0>
  8013ab:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013af:	74 3c                	je     8013ed <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	51                   	push   %ecx
  8013b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b8:	e8 6f 02 00 00       	call   80162c <strnlen>
  8013bd:	29 c3                	sub    %eax,%ebx
  8013bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 db                	test   %ebx,%ebx
  8013c7:	7e 24                	jle    8013ed <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013c9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013cd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013d0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	57                   	push   %edi
  8013d7:	53                   	push   %ebx
  8013d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	4e                   	dec    %esi
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 f6                	test   %esi,%esi
  8013e1:	7f f0                	jg     8013d3 <vprintfmt+0x1c6>
  8013e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013f0:	0f be 02             	movsbl (%edx),%eax
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	75 47                	jne    80143e <vprintfmt+0x231>
  8013f7:	eb 37                	jmp    801430 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013fd:	74 16                	je     801415 <vprintfmt+0x208>
  8013ff:	8d 50 e0             	lea    -0x20(%eax),%edx
  801402:	83 fa 5e             	cmp    $0x5e,%edx
  801405:	76 0e                	jbe    801415 <vprintfmt+0x208>
					putch('?', putdat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	57                   	push   %edi
  80140b:	6a 3f                	push   $0x3f
  80140d:	ff 55 08             	call   *0x8(%ebp)
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 0b                	jmp    801420 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	57                   	push   %edi
  801419:	50                   	push   %eax
  80141a:	ff 55 08             	call   *0x8(%ebp)
  80141d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801420:	ff 4d e4             	decl   -0x1c(%ebp)
  801423:	0f be 03             	movsbl (%ebx),%eax
  801426:	85 c0                	test   %eax,%eax
  801428:	74 03                	je     80142d <vprintfmt+0x220>
  80142a:	43                   	inc    %ebx
  80142b:	eb 1b                	jmp    801448 <vprintfmt+0x23b>
  80142d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801430:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801434:	7f 1e                	jg     801454 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801436:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801439:	e9 f3 fd ff ff       	jmp    801231 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801441:	43                   	inc    %ebx
  801442:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801445:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801448:	85 f6                	test   %esi,%esi
  80144a:	78 ad                	js     8013f9 <vprintfmt+0x1ec>
  80144c:	4e                   	dec    %esi
  80144d:	79 aa                	jns    8013f9 <vprintfmt+0x1ec>
  80144f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801452:	eb dc                	jmp    801430 <vprintfmt+0x223>
  801454:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	57                   	push   %edi
  80145b:	6a 20                	push   $0x20
  80145d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801460:	4b                   	dec    %ebx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 db                	test   %ebx,%ebx
  801466:	7f ef                	jg     801457 <vprintfmt+0x24a>
  801468:	e9 c4 fd ff ff       	jmp    801231 <vprintfmt+0x24>
  80146d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801470:	89 ca                	mov    %ecx,%edx
  801472:	8d 45 14             	lea    0x14(%ebp),%eax
  801475:	e8 2a fd ff ff       	call   8011a4 <getint>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80147e:	85 d2                	test   %edx,%edx
  801480:	78 0a                	js     80148c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801482:	b8 0a 00 00 00       	mov    $0xa,%eax
  801487:	e9 b0 00 00 00       	jmp    80153c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	57                   	push   %edi
  801490:	6a 2d                	push   $0x2d
  801492:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801495:	f7 db                	neg    %ebx
  801497:	83 d6 00             	adc    $0x0,%esi
  80149a:	f7 de                	neg    %esi
  80149c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80149f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014a4:	e9 93 00 00 00       	jmp    80153c <vprintfmt+0x32f>
  8014a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014ac:	89 ca                	mov    %ecx,%edx
  8014ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b1:	e8 b4 fc ff ff       	call   80116a <getuint>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	89 d6                	mov    %edx,%esi
			base = 10;
  8014ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014bf:	eb 7b                	jmp    80153c <vprintfmt+0x32f>
  8014c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014c4:	89 ca                	mov    %ecx,%edx
  8014c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c9:	e8 d6 fc ff ff       	call   8011a4 <getint>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	78 07                	js     8014dd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014db:	eb 5f                	jmp    80153c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	57                   	push   %edi
  8014e1:	6a 2d                	push   $0x2d
  8014e3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014e6:	f7 db                	neg    %ebx
  8014e8:	83 d6 00             	adc    $0x0,%esi
  8014eb:	f7 de                	neg    %esi
  8014ed:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f5:	eb 45                	jmp    80153c <vprintfmt+0x32f>
  8014f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	57                   	push   %edi
  8014fe:	6a 30                	push   $0x30
  801500:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	57                   	push   %edi
  801507:	6a 78                	push   $0x78
  801509:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	8d 50 04             	lea    0x4(%eax),%edx
  801512:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801515:	8b 18                	mov    (%eax),%ebx
  801517:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80151c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80151f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801524:	eb 16                	jmp    80153c <vprintfmt+0x32f>
  801526:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801529:	89 ca                	mov    %ecx,%edx
  80152b:	8d 45 14             	lea    0x14(%ebp),%eax
  80152e:	e8 37 fc ff ff       	call   80116a <getuint>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	89 d6                	mov    %edx,%esi
			base = 16;
  801537:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801543:	52                   	push   %edx
  801544:	ff 75 e4             	pushl  -0x1c(%ebp)
  801547:	50                   	push   %eax
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	89 fa                	mov    %edi,%edx
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	e8 68 fb ff ff       	call   8010bc <printnum>
			break;
  801554:	83 c4 20             	add    $0x20,%esp
  801557:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80155a:	e9 d2 fc ff ff       	jmp    801231 <vprintfmt+0x24>
  80155f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	57                   	push   %edi
  801566:	52                   	push   %edx
  801567:	ff 55 08             	call   *0x8(%ebp)
			break;
  80156a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801570:	e9 bc fc ff ff       	jmp    801231 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	57                   	push   %edi
  801579:	6a 25                	push   $0x25
  80157b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 02                	jmp    801585 <vprintfmt+0x378>
  801583:	89 c6                	mov    %eax,%esi
  801585:	8d 46 ff             	lea    -0x1(%esi),%eax
  801588:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80158c:	75 f5                	jne    801583 <vprintfmt+0x376>
  80158e:	e9 9e fc ff ff       	jmp    801231 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	83 ec 18             	sub    $0x18,%esp
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 26                	je     8015e2 <vsnprintf+0x47>
  8015bc:	85 d2                	test   %edx,%edx
  8015be:	7e 29                	jle    8015e9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015c0:	ff 75 14             	pushl  0x14(%ebp)
  8015c3:	ff 75 10             	pushl  0x10(%ebp)
  8015c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	68 d6 11 80 00       	push   $0x8011d6
  8015cf:	e8 39 fc ff ff       	call   80120d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb 0c                	jmp    8015ee <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e7:	eb 05                	jmp    8015ee <vsnprintf+0x53>
  8015e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 10             	pushl  0x10(%ebp)
  8015fd:	ff 75 0c             	pushl  0xc(%ebp)
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 93 ff ff ff       	call   80159b <vsnprintf>
	va_end(ap);

	return rc;
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    
	...

0080160c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801612:	80 3a 00             	cmpb   $0x0,(%edx)
  801615:	74 0e                	je     801625 <strlen+0x19>
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80161c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80161d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801621:	75 f9                	jne    80161c <strlen+0x10>
  801623:	eb 05                	jmp    80162a <strlen+0x1e>
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801635:	85 d2                	test   %edx,%edx
  801637:	74 17                	je     801650 <strnlen+0x24>
  801639:	80 39 00             	cmpb   $0x0,(%ecx)
  80163c:	74 19                	je     801657 <strnlen+0x2b>
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801643:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801644:	39 d0                	cmp    %edx,%eax
  801646:	74 14                	je     80165c <strnlen+0x30>
  801648:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80164c:	75 f5                	jne    801643 <strnlen+0x17>
  80164e:	eb 0c                	jmp    80165c <strnlen+0x30>
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
  801655:	eb 05                	jmp    80165c <strnlen+0x30>
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801668:	ba 00 00 00 00       	mov    $0x0,%edx
  80166d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801670:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801673:	42                   	inc    %edx
  801674:	84 c9                	test   %cl,%cl
  801676:	75 f5                	jne    80166d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801678:	5b                   	pop    %ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801682:	53                   	push   %ebx
  801683:	e8 84 ff ff ff       	call   80160c <strlen>
  801688:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801691:	50                   	push   %eax
  801692:	e8 c7 ff ff ff       	call   80165e <strcpy>
	return dst;
}
  801697:	89 d8                	mov    %ebx,%eax
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ac:	85 f6                	test   %esi,%esi
  8016ae:	74 15                	je     8016c5 <strncpy+0x27>
  8016b0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016b5:	8a 1a                	mov    (%edx),%bl
  8016b7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ba:	80 3a 01             	cmpb   $0x1,(%edx)
  8016bd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c0:	41                   	inc    %ecx
  8016c1:	39 ce                	cmp    %ecx,%esi
  8016c3:	77 f0                	ja     8016b5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	57                   	push   %edi
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016d8:	85 f6                	test   %esi,%esi
  8016da:	74 32                	je     80170e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016dc:	83 fe 01             	cmp    $0x1,%esi
  8016df:	74 22                	je     801703 <strlcpy+0x3a>
  8016e1:	8a 0b                	mov    (%ebx),%cl
  8016e3:	84 c9                	test   %cl,%cl
  8016e5:	74 20                	je     801707 <strlcpy+0x3e>
  8016e7:	89 f8                	mov    %edi,%eax
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016ee:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f1:	88 08                	mov    %cl,(%eax)
  8016f3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f4:	39 f2                	cmp    %esi,%edx
  8016f6:	74 11                	je     801709 <strlcpy+0x40>
  8016f8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016fc:	42                   	inc    %edx
  8016fd:	84 c9                	test   %cl,%cl
  8016ff:	75 f0                	jne    8016f1 <strlcpy+0x28>
  801701:	eb 06                	jmp    801709 <strlcpy+0x40>
  801703:	89 f8                	mov    %edi,%eax
  801705:	eb 02                	jmp    801709 <strlcpy+0x40>
  801707:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801709:	c6 00 00             	movb   $0x0,(%eax)
  80170c:	eb 02                	jmp    801710 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80170e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801710:	29 f8                	sub    %edi,%eax
}
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801720:	8a 01                	mov    (%ecx),%al
  801722:	84 c0                	test   %al,%al
  801724:	74 10                	je     801736 <strcmp+0x1f>
  801726:	3a 02                	cmp    (%edx),%al
  801728:	75 0c                	jne    801736 <strcmp+0x1f>
		p++, q++;
  80172a:	41                   	inc    %ecx
  80172b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80172c:	8a 01                	mov    (%ecx),%al
  80172e:	84 c0                	test   %al,%al
  801730:	74 04                	je     801736 <strcmp+0x1f>
  801732:	3a 02                	cmp    (%edx),%al
  801734:	74 f4                	je     80172a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801736:	0f b6 c0             	movzbl %al,%eax
  801739:	0f b6 12             	movzbl (%edx),%edx
  80173c:	29 d0                	sub    %edx,%eax
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	8b 55 08             	mov    0x8(%ebp),%edx
  801747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80174d:	85 c0                	test   %eax,%eax
  80174f:	74 1b                	je     80176c <strncmp+0x2c>
  801751:	8a 1a                	mov    (%edx),%bl
  801753:	84 db                	test   %bl,%bl
  801755:	74 24                	je     80177b <strncmp+0x3b>
  801757:	3a 19                	cmp    (%ecx),%bl
  801759:	75 20                	jne    80177b <strncmp+0x3b>
  80175b:	48                   	dec    %eax
  80175c:	74 15                	je     801773 <strncmp+0x33>
		n--, p++, q++;
  80175e:	42                   	inc    %edx
  80175f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801760:	8a 1a                	mov    (%edx),%bl
  801762:	84 db                	test   %bl,%bl
  801764:	74 15                	je     80177b <strncmp+0x3b>
  801766:	3a 19                	cmp    (%ecx),%bl
  801768:	74 f1                	je     80175b <strncmp+0x1b>
  80176a:	eb 0f                	jmp    80177b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
  801771:	eb 05                	jmp    801778 <strncmp+0x38>
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801778:	5b                   	pop    %ebx
  801779:	c9                   	leave  
  80177a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80177b:	0f b6 02             	movzbl (%edx),%eax
  80177e:	0f b6 11             	movzbl (%ecx),%edx
  801781:	29 d0                	sub    %edx,%eax
  801783:	eb f3                	jmp    801778 <strncmp+0x38>

00801785 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80178e:	8a 10                	mov    (%eax),%dl
  801790:	84 d2                	test   %dl,%dl
  801792:	74 18                	je     8017ac <strchr+0x27>
		if (*s == c)
  801794:	38 ca                	cmp    %cl,%dl
  801796:	75 06                	jne    80179e <strchr+0x19>
  801798:	eb 17                	jmp    8017b1 <strchr+0x2c>
  80179a:	38 ca                	cmp    %cl,%dl
  80179c:	74 13                	je     8017b1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80179e:	40                   	inc    %eax
  80179f:	8a 10                	mov    (%eax),%dl
  8017a1:	84 d2                	test   %dl,%dl
  8017a3:	75 f5                	jne    80179a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017aa:	eb 05                	jmp    8017b1 <strchr+0x2c>
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017bc:	8a 10                	mov    (%eax),%dl
  8017be:	84 d2                	test   %dl,%dl
  8017c0:	74 11                	je     8017d3 <strfind+0x20>
		if (*s == c)
  8017c2:	38 ca                	cmp    %cl,%dl
  8017c4:	75 06                	jne    8017cc <strfind+0x19>
  8017c6:	eb 0b                	jmp    8017d3 <strfind+0x20>
  8017c8:	38 ca                	cmp    %cl,%dl
  8017ca:	74 07                	je     8017d3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017cc:	40                   	inc    %eax
  8017cd:	8a 10                	mov    (%eax),%dl
  8017cf:	84 d2                	test   %dl,%dl
  8017d1:	75 f5                	jne    8017c8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	57                   	push   %edi
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e4:	85 c9                	test   %ecx,%ecx
  8017e6:	74 30                	je     801818 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ee:	75 25                	jne    801815 <memset+0x40>
  8017f0:	f6 c1 03             	test   $0x3,%cl
  8017f3:	75 20                	jne    801815 <memset+0x40>
		c &= 0xFF;
  8017f5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f8:	89 d3                	mov    %edx,%ebx
  8017fa:	c1 e3 08             	shl    $0x8,%ebx
  8017fd:	89 d6                	mov    %edx,%esi
  8017ff:	c1 e6 18             	shl    $0x18,%esi
  801802:	89 d0                	mov    %edx,%eax
  801804:	c1 e0 10             	shl    $0x10,%eax
  801807:	09 f0                	or     %esi,%eax
  801809:	09 d0                	or     %edx,%eax
  80180b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80180d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801810:	fc                   	cld    
  801811:	f3 ab                	rep stos %eax,%es:(%edi)
  801813:	eb 03                	jmp    801818 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801815:	fc                   	cld    
  801816:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801818:	89 f8                	mov    %edi,%eax
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	57                   	push   %edi
  801823:	56                   	push   %esi
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80182d:	39 c6                	cmp    %eax,%esi
  80182f:	73 34                	jae    801865 <memmove+0x46>
  801831:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801834:	39 d0                	cmp    %edx,%eax
  801836:	73 2d                	jae    801865 <memmove+0x46>
		s += n;
		d += n;
  801838:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183b:	f6 c2 03             	test   $0x3,%dl
  80183e:	75 1b                	jne    80185b <memmove+0x3c>
  801840:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801846:	75 13                	jne    80185b <memmove+0x3c>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	75 0e                	jne    80185b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80184d:	83 ef 04             	sub    $0x4,%edi
  801850:	8d 72 fc             	lea    -0x4(%edx),%esi
  801853:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801856:	fd                   	std    
  801857:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801859:	eb 07                	jmp    801862 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80185b:	4f                   	dec    %edi
  80185c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185f:	fd                   	std    
  801860:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801862:	fc                   	cld    
  801863:	eb 20                	jmp    801885 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801865:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186b:	75 13                	jne    801880 <memmove+0x61>
  80186d:	a8 03                	test   $0x3,%al
  80186f:	75 0f                	jne    801880 <memmove+0x61>
  801871:	f6 c1 03             	test   $0x3,%cl
  801874:	75 0a                	jne    801880 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801876:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801879:	89 c7                	mov    %eax,%edi
  80187b:	fc                   	cld    
  80187c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187e:	eb 05                	jmp    801885 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801880:	89 c7                	mov    %eax,%edi
  801882:	fc                   	cld    
  801883:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801885:	5e                   	pop    %esi
  801886:	5f                   	pop    %edi
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80188c:	ff 75 10             	pushl  0x10(%ebp)
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 85 ff ff ff       	call   80181f <memmove>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ab:	85 ff                	test   %edi,%edi
  8018ad:	74 32                	je     8018e1 <memcmp+0x45>
		if (*s1 != *s2)
  8018af:	8a 03                	mov    (%ebx),%al
  8018b1:	8a 0e                	mov    (%esi),%cl
  8018b3:	38 c8                	cmp    %cl,%al
  8018b5:	74 19                	je     8018d0 <memcmp+0x34>
  8018b7:	eb 0d                	jmp    8018c6 <memcmp+0x2a>
  8018b9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018bd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018c1:	42                   	inc    %edx
  8018c2:	38 c8                	cmp    %cl,%al
  8018c4:	74 10                	je     8018d6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018c6:	0f b6 c0             	movzbl %al,%eax
  8018c9:	0f b6 c9             	movzbl %cl,%ecx
  8018cc:	29 c8                	sub    %ecx,%eax
  8018ce:	eb 16                	jmp    8018e6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d0:	4f                   	dec    %edi
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	39 fa                	cmp    %edi,%edx
  8018d8:	75 df                	jne    8018b9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018da:	b8 00 00 00 00       	mov    $0x0,%eax
  8018df:	eb 05                	jmp    8018e6 <memcmp+0x4a>
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f6:	39 d0                	cmp    %edx,%eax
  8018f8:	73 12                	jae    80190c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018fd:	38 08                	cmp    %cl,(%eax)
  8018ff:	75 06                	jne    801907 <memfind+0x1c>
  801901:	eb 09                	jmp    80190c <memfind+0x21>
  801903:	38 08                	cmp    %cl,(%eax)
  801905:	74 05                	je     80190c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801907:	40                   	inc    %eax
  801908:	39 c2                	cmp    %eax,%edx
  80190a:	77 f7                	ja     801903 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 55 08             	mov    0x8(%ebp),%edx
  801917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191a:	eb 01                	jmp    80191d <strtol+0xf>
		s++;
  80191c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191d:	8a 02                	mov    (%edx),%al
  80191f:	3c 20                	cmp    $0x20,%al
  801921:	74 f9                	je     80191c <strtol+0xe>
  801923:	3c 09                	cmp    $0x9,%al
  801925:	74 f5                	je     80191c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801927:	3c 2b                	cmp    $0x2b,%al
  801929:	75 08                	jne    801933 <strtol+0x25>
		s++;
  80192b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80192c:	bf 00 00 00 00       	mov    $0x0,%edi
  801931:	eb 13                	jmp    801946 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801933:	3c 2d                	cmp    $0x2d,%al
  801935:	75 0a                	jne    801941 <strtol+0x33>
		s++, neg = 1;
  801937:	8d 52 01             	lea    0x1(%edx),%edx
  80193a:	bf 01 00 00 00       	mov    $0x1,%edi
  80193f:	eb 05                	jmp    801946 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801941:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801946:	85 db                	test   %ebx,%ebx
  801948:	74 05                	je     80194f <strtol+0x41>
  80194a:	83 fb 10             	cmp    $0x10,%ebx
  80194d:	75 28                	jne    801977 <strtol+0x69>
  80194f:	8a 02                	mov    (%edx),%al
  801951:	3c 30                	cmp    $0x30,%al
  801953:	75 10                	jne    801965 <strtol+0x57>
  801955:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801959:	75 0a                	jne    801965 <strtol+0x57>
		s += 2, base = 16;
  80195b:	83 c2 02             	add    $0x2,%edx
  80195e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801963:	eb 12                	jmp    801977 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801965:	85 db                	test   %ebx,%ebx
  801967:	75 0e                	jne    801977 <strtol+0x69>
  801969:	3c 30                	cmp    $0x30,%al
  80196b:	75 05                	jne    801972 <strtol+0x64>
		s++, base = 8;
  80196d:	42                   	inc    %edx
  80196e:	b3 08                	mov    $0x8,%bl
  801970:	eb 05                	jmp    801977 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801972:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80197e:	8a 0a                	mov    (%edx),%cl
  801980:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801983:	80 fb 09             	cmp    $0x9,%bl
  801986:	77 08                	ja     801990 <strtol+0x82>
			dig = *s - '0';
  801988:	0f be c9             	movsbl %cl,%ecx
  80198b:	83 e9 30             	sub    $0x30,%ecx
  80198e:	eb 1e                	jmp    8019ae <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801990:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801993:	80 fb 19             	cmp    $0x19,%bl
  801996:	77 08                	ja     8019a0 <strtol+0x92>
			dig = *s - 'a' + 10;
  801998:	0f be c9             	movsbl %cl,%ecx
  80199b:	83 e9 57             	sub    $0x57,%ecx
  80199e:	eb 0e                	jmp    8019ae <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019a0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019a3:	80 fb 19             	cmp    $0x19,%bl
  8019a6:	77 13                	ja     8019bb <strtol+0xad>
			dig = *s - 'A' + 10;
  8019a8:	0f be c9             	movsbl %cl,%ecx
  8019ab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ae:	39 f1                	cmp    %esi,%ecx
  8019b0:	7d 0d                	jge    8019bf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019b2:	42                   	inc    %edx
  8019b3:	0f af c6             	imul   %esi,%eax
  8019b6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019b9:	eb c3                	jmp    80197e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019bb:	89 c1                	mov    %eax,%ecx
  8019bd:	eb 02                	jmp    8019c1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019bf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c5:	74 05                	je     8019cc <strtol+0xbe>
		*endptr = (char *) s;
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ca:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019cc:	85 ff                	test   %edi,%edi
  8019ce:	74 04                	je     8019d4 <strtol+0xc6>
  8019d0:	89 c8                	mov    %ecx,%eax
  8019d2:	f7 d8                	neg    %eax
}
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5f                   	pop    %edi
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    
  8019d9:	00 00                	add    %al,(%eax)
	...

008019dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	57                   	push   %edi
  8019f1:	68 20 22 80 00       	push   $0x802220
  8019f6:	e8 ad f6 ff ff       	call   8010a8 <cprintf>
	int r;
	if (pg != NULL) {
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	85 db                	test   %ebx,%ebx
  801a00:	74 28                	je     801a2a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	68 30 22 80 00       	push   $0x802230
  801a0a:	e8 99 f6 ff ff       	call   8010a8 <cprintf>
		r = sys_ipc_recv(pg);
  801a0f:	89 1c 24             	mov    %ebx,(%esp)
  801a12:	e8 a0 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  801a17:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801a19:	c7 04 24 84 1e 80 00 	movl   $0x801e84,(%esp)
  801a20:	e8 83 f6 ff ff       	call   8010a8 <cprintf>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb 12                	jmp    801a3c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	68 00 00 c0 ee       	push   $0xeec00000
  801a32:	e8 80 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a3c:	85 db                	test   %ebx,%ebx
  801a3e:	75 26                	jne    801a66 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a40:	85 ff                	test   %edi,%edi
  801a42:	74 0a                	je     801a4e <ipc_recv+0x72>
  801a44:	a1 04 40 80 00       	mov    0x804004,%eax
  801a49:	8b 40 74             	mov    0x74(%eax),%eax
  801a4c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a4e:	85 f6                	test   %esi,%esi
  801a50:	74 0a                	je     801a5c <ipc_recv+0x80>
  801a52:	a1 04 40 80 00       	mov    0x804004,%eax
  801a57:	8b 40 78             	mov    0x78(%eax),%eax
  801a5a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801a5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a61:	8b 58 70             	mov    0x70(%eax),%ebx
  801a64:	eb 14                	jmp    801a7a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a66:	85 ff                	test   %edi,%edi
  801a68:	74 06                	je     801a70 <ipc_recv+0x94>
  801a6a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801a70:	85 f6                	test   %esi,%esi
  801a72:	74 06                	je     801a7a <ipc_recv+0x9e>
  801a74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801a7a:	89 d8                	mov    %ebx,%eax
  801a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	57                   	push   %edi
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a93:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a96:	85 db                	test   %ebx,%ebx
  801a98:	75 25                	jne    801abf <ipc_send+0x3b>
  801a9a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a9f:	eb 1e                	jmp    801abf <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aa1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa4:	75 07                	jne    801aad <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aa6:	e8 ea e6 ff ff       	call   800195 <sys_yield>
  801aab:	eb 12                	jmp    801abf <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801aad:	50                   	push   %eax
  801aae:	68 37 22 80 00       	push   $0x802237
  801ab3:	6a 45                	push   $0x45
  801ab5:	68 4a 22 80 00       	push   $0x80224a
  801aba:	e8 11 f5 ff ff       	call   800fd0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	57                   	push   %edi
  801ac2:	ff 75 08             	pushl  0x8(%ebp)
  801ac5:	e8 c8 e7 ff ff       	call   800292 <sys_ipc_try_send>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	75 d0                	jne    801aa1 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5f                   	pop    %edi
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	53                   	push   %ebx
  801add:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ae0:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ae6:	74 22                	je     801b0a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801aed:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801af4:	89 c2                	mov    %eax,%edx
  801af6:	c1 e2 07             	shl    $0x7,%edx
  801af9:	29 ca                	sub    %ecx,%edx
  801afb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b01:	8b 52 50             	mov    0x50(%edx),%edx
  801b04:	39 da                	cmp    %ebx,%edx
  801b06:	75 1d                	jne    801b25 <ipc_find_env+0x4c>
  801b08:	eb 05                	jmp    801b0f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b16:	c1 e0 07             	shl    $0x7,%eax
  801b19:	29 d0                	sub    %edx,%eax
  801b1b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b20:	8b 40 40             	mov    0x40(%eax),%eax
  801b23:	eb 0c                	jmp    801b31 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b25:	40                   	inc    %eax
  801b26:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2b:	75 c0                	jne    801aed <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b2d:	66 b8 00 00          	mov    $0x0,%ax
}
  801b31:	5b                   	pop    %ebx
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	c1 ea 16             	shr    $0x16,%edx
  801b3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 1e                	je     801b69 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b4b:	c1 e8 0c             	shr    $0xc,%eax
  801b4e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b55:	a8 01                	test   $0x1,%al
  801b57:	74 17                	je     801b70 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b59:	c1 e8 0c             	shr    $0xc,%eax
  801b5c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b63:	ef 
  801b64:	0f b7 c0             	movzwl %ax,%eax
  801b67:	eb 0c                	jmp    801b75 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	eb 05                	jmp    801b75 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    
	...

00801b78 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	83 ec 10             	sub    $0x10,%esp
  801b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b86:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b8f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b92:	85 c0                	test   %eax,%eax
  801b94:	75 2e                	jne    801bc4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b96:	39 f1                	cmp    %esi,%ecx
  801b98:	77 5a                	ja     801bf4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b9a:	85 c9                	test   %ecx,%ecx
  801b9c:	75 0b                	jne    801ba9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba3:	31 d2                	xor    %edx,%edx
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ba9:	31 d2                	xor    %edx,%edx
  801bab:	89 f0                	mov    %esi,%eax
  801bad:	f7 f1                	div    %ecx
  801baf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bb1:	89 f8                	mov    %edi,%eax
  801bb3:	f7 f1                	div    %ecx
  801bb5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb7:	89 f8                	mov    %edi,%eax
  801bb9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    
  801bc2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bc4:	39 f0                	cmp    %esi,%eax
  801bc6:	77 1c                	ja     801be4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bc8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bcb:	83 f7 1f             	xor    $0x1f,%edi
  801bce:	75 3c                	jne    801c0c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bd0:	39 f0                	cmp    %esi,%eax
  801bd2:	0f 82 90 00 00 00    	jb     801c68 <__udivdi3+0xf0>
  801bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bde:	0f 86 84 00 00 00    	jbe    801c68 <__udivdi3+0xf0>
  801be4:	31 f6                	xor    %esi,%esi
  801be6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be8:	89 f8                	mov    %edi,%eax
  801bea:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    
  801bf3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bf4:	89 f2                	mov    %esi,%edx
  801bf6:	89 f8                	mov    %edi,%eax
  801bf8:	f7 f1                	div    %ecx
  801bfa:	89 c7                	mov    %eax,%edi
  801bfc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bfe:	89 f8                	mov    %edi,%eax
  801c00:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    
  801c09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c0c:	89 f9                	mov    %edi,%ecx
  801c0e:	d3 e0                	shl    %cl,%eax
  801c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c13:	b8 20 00 00 00       	mov    $0x20,%eax
  801c18:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1d:	88 c1                	mov    %al,%cl
  801c1f:	d3 ea                	shr    %cl,%edx
  801c21:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c24:	09 ca                	or     %ecx,%edx
  801c26:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2c:	89 f9                	mov    %edi,%ecx
  801c2e:	d3 e2                	shl    %cl,%edx
  801c30:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c33:	89 f2                	mov    %esi,%edx
  801c35:	88 c1                	mov    %al,%cl
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	89 f9                	mov    %edi,%ecx
  801c40:	d3 e2                	shl    %cl,%edx
  801c42:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c45:	88 c1                	mov    %al,%cl
  801c47:	d3 ee                	shr    %cl,%esi
  801c49:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c4b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c4e:	89 f0                	mov    %esi,%eax
  801c50:	89 ca                	mov    %ecx,%edx
  801c52:	f7 75 ec             	divl   -0x14(%ebp)
  801c55:	89 d1                	mov    %edx,%ecx
  801c57:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c59:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c5c:	39 d1                	cmp    %edx,%ecx
  801c5e:	72 28                	jb     801c88 <__udivdi3+0x110>
  801c60:	74 1a                	je     801c7c <__udivdi3+0x104>
  801c62:	89 f7                	mov    %esi,%edi
  801c64:	31 f6                	xor    %esi,%esi
  801c66:	eb 80                	jmp    801be8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c68:	31 f6                	xor    %esi,%esi
  801c6a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    
  801c7a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7f:	89 f9                	mov    %edi,%ecx
  801c81:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c83:	39 c2                	cmp    %eax,%edx
  801c85:	73 db                	jae    801c62 <__udivdi3+0xea>
  801c87:	90                   	nop
		{
		  q0--;
  801c88:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c8b:	31 f6                	xor    %esi,%esi
  801c8d:	e9 56 ff ff ff       	jmp    801be8 <__udivdi3+0x70>
	...

00801c94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	57                   	push   %edi
  801c98:	56                   	push   %esi
  801c99:	83 ec 20             	sub    $0x20,%esp
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ca2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ca8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cab:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cb1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cb3:	85 ff                	test   %edi,%edi
  801cb5:	75 15                	jne    801ccc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cb7:	39 f1                	cmp    %esi,%ecx
  801cb9:	0f 86 99 00 00 00    	jbe    801d58 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cbf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cc1:	89 d0                	mov    %edx,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc5:	83 c4 20             	add    $0x20,%esp
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ccc:	39 f7                	cmp    %esi,%edi
  801cce:	0f 87 a4 00 00 00    	ja     801d78 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cd7:	83 f0 1f             	xor    $0x1f,%eax
  801cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cdd:	0f 84 a1 00 00 00    	je     801d84 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce3:	89 f8                	mov    %edi,%eax
  801ce5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cea:	bf 20 00 00 00       	mov    $0x20,%edi
  801cef:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 ea                	shr    %cl,%edx
  801cf9:	09 c2                	or     %eax,%edx
  801cfb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d04:	d3 e0                	shl    %cl,%eax
  801d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d09:	89 f2                	mov    %esi,%edx
  801d0b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d10:	d3 e0                	shl    %cl,%eax
  801d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d18:	89 f9                	mov    %edi,%ecx
  801d1a:	d3 e8                	shr    %cl,%eax
  801d1c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d1e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	f7 75 f0             	divl   -0x10(%ebp)
  801d25:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d27:	f7 65 f4             	mull   -0xc(%ebp)
  801d2a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d2d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d2f:	39 d6                	cmp    %edx,%esi
  801d31:	72 71                	jb     801da4 <__umoddi3+0x110>
  801d33:	74 7f                	je     801db4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d38:	29 c8                	sub    %ecx,%eax
  801d3a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d3c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3f:	d3 e8                	shr    %cl,%eax
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d47:	09 d0                	or     %edx,%eax
  801d49:	89 f2                	mov    %esi,%edx
  801d4b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
  801d57:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d58:	85 c9                	test   %ecx,%ecx
  801d5a:	75 0b                	jne    801d67 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f1                	div    %ecx
  801d65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	31 d2                	xor    %edx,%edx
  801d6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d70:	f7 f1                	div    %ecx
  801d72:	e9 4a ff ff ff       	jmp    801cc1 <__umoddi3+0x2d>
  801d77:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d7a:	83 c4 20             	add    $0x20,%esp
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    
  801d81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d84:	39 f7                	cmp    %esi,%edi
  801d86:	72 05                	jb     801d8d <__umoddi3+0xf9>
  801d88:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d8b:	77 0c                	ja     801d99 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	29 c8                	sub    %ecx,%eax
  801d94:	19 fa                	sbb    %edi,%edx
  801d96:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d9c:	83 c4 20             	add    $0x20,%esp
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    
  801da3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801da4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dac:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801daf:	eb 84                	jmp    801d35 <__umoddi3+0xa1>
  801db1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801db7:	72 eb                	jb     801da4 <__umoddi3+0x110>
  801db9:	89 f2                	mov    %esi,%edx
  801dbb:	e9 75 ff ff ff       	jmp    801d35 <__umoddi3+0xa1>
