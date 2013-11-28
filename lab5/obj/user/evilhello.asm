
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
  8000a2:	e8 87 04 00 00       	call   80052e <close_all>
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
  8000ea:	68 aa 1d 80 00       	push   $0x801daa
  8000ef:	6a 42                	push   $0x42
  8000f1:	68 c7 1d 80 00       	push   $0x801dc7
  8000f6:	e8 dd 0e 00 00       	call   800fd8 <_panic>

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

008002fc <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800302:	6a 00                	push   $0x0
  800304:	ff 75 14             	pushl  0x14(%ebp)
  800307:	ff 75 10             	pushl  0x10(%ebp)
  80030a:	ff 75 0c             	pushl  0xc(%ebp)
  80030d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	b8 0f 00 00 00       	mov    $0xf,%eax
  80031a:	e8 99 fd ff ff       	call   8000b8 <syscall>
  80031f:	c9                   	leave  
  800320:	c3                   	ret    
  800321:	00 00                	add    %al,(%eax)
	...

00800324 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	05 00 00 00 30       	add    $0x30000000,%eax
  80032f:	c1 e8 0c             	shr    $0xc,%eax
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800337:	ff 75 08             	pushl  0x8(%ebp)
  80033a:	e8 e5 ff ff ff       	call   800324 <fd2num>
  80033f:	83 c4 04             	add    $0x4,%esp
  800342:	05 20 00 0d 00       	add    $0xd0020,%eax
  800347:	c1 e0 0c             	shl    $0xc,%eax
}
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	53                   	push   %ebx
  800350:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800353:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800358:	a8 01                	test   $0x1,%al
  80035a:	74 34                	je     800390 <fd_alloc+0x44>
  80035c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800361:	a8 01                	test   $0x1,%al
  800363:	74 32                	je     800397 <fd_alloc+0x4b>
  800365:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80036a:	89 c1                	mov    %eax,%ecx
  80036c:	89 c2                	mov    %eax,%edx
  80036e:	c1 ea 16             	shr    $0x16,%edx
  800371:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800378:	f6 c2 01             	test   $0x1,%dl
  80037b:	74 1f                	je     80039c <fd_alloc+0x50>
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 0c             	shr    $0xc,%edx
  800382:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	75 17                	jne    8003a5 <fd_alloc+0x59>
  80038e:	eb 0c                	jmp    80039c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800390:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800395:	eb 05                	jmp    80039c <fd_alloc+0x50>
  800397:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80039c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	eb 17                	jmp    8003bc <fd_alloc+0x70>
  8003a5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003aa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003af:	75 b9                	jne    80036a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003b7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bc:	5b                   	pop    %ebx
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    

008003bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c5:	83 f8 1f             	cmp    $0x1f,%eax
  8003c8:	77 36                	ja     800400 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ca:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003cf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d2:	89 c2                	mov    %eax,%edx
  8003d4:	c1 ea 16             	shr    $0x16,%edx
  8003d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003de:	f6 c2 01             	test   $0x1,%dl
  8003e1:	74 24                	je     800407 <fd_lookup+0x48>
  8003e3:	89 c2                	mov    %eax,%edx
  8003e5:	c1 ea 0c             	shr    $0xc,%edx
  8003e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ef:	f6 c2 01             	test   $0x1,%dl
  8003f2:	74 1a                	je     80040e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fe:	eb 13                	jmp    800413 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800400:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800405:	eb 0c                	jmp    800413 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040c:	eb 05                	jmp    800413 <fd_lookup+0x54>
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	53                   	push   %ebx
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800422:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800428:	74 0d                	je     800437 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 14                	jmp    800445 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800431:	39 0a                	cmp    %ecx,(%edx)
  800433:	75 10                	jne    800445 <dev_lookup+0x30>
  800435:	eb 05                	jmp    80043c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800437:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80043c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	eb 31                	jmp    800476 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800445:	40                   	inc    %eax
  800446:	8b 14 85 54 1e 80 00 	mov    0x801e54(,%eax,4),%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	75 e0                	jne    800431 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800451:	a1 04 40 80 00       	mov    0x804004,%eax
  800456:	8b 40 48             	mov    0x48(%eax),%eax
  800459:	83 ec 04             	sub    $0x4,%esp
  80045c:	51                   	push   %ecx
  80045d:	50                   	push   %eax
  80045e:	68 d8 1d 80 00       	push   $0x801dd8
  800463:	e8 48 0c 00 00       	call   8010b0 <cprintf>
	*dev = 0;
  800468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	56                   	push   %esi
  80047f:	53                   	push   %ebx
  800480:	83 ec 20             	sub    $0x20,%esp
  800483:	8b 75 08             	mov    0x8(%ebp),%esi
  800486:	8a 45 0c             	mov    0xc(%ebp),%al
  800489:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048c:	56                   	push   %esi
  80048d:	e8 92 fe ff ff       	call   800324 <fd2num>
  800492:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800495:	89 14 24             	mov    %edx,(%esp)
  800498:	50                   	push   %eax
  800499:	e8 21 ff ff ff       	call   8003bf <fd_lookup>
  80049e:	89 c3                	mov    %eax,%ebx
  8004a0:	83 c4 08             	add    $0x8,%esp
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	78 05                	js     8004ac <fd_close+0x31>
	    || fd != fd2)
  8004a7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004aa:	74 0d                	je     8004b9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004ac:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004b0:	75 48                	jne    8004fa <fd_close+0x7f>
  8004b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004b7:	eb 41                	jmp    8004fa <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	ff 36                	pushl  (%esi)
  8004c2:	e8 4e ff ff ff       	call   800415 <dev_lookup>
  8004c7:	89 c3                	mov    %eax,%ebx
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	78 1c                	js     8004ec <fd_close+0x71>
		if (dev->dev_close)
  8004d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d3:	8b 40 10             	mov    0x10(%eax),%eax
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	74 0d                	je     8004e7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004da:	83 ec 0c             	sub    $0xc,%esp
  8004dd:	56                   	push   %esi
  8004de:	ff d0                	call   *%eax
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb 05                	jmp    8004ec <fd_close+0x71>
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	56                   	push   %esi
  8004f0:	6a 00                	push   $0x0
  8004f2:	e8 0f fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  8004f7:	83 c4 10             	add    $0x10,%esp
}
  8004fa:	89 d8                	mov    %ebx,%eax
  8004fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ff:	5b                   	pop    %ebx
  800500:	5e                   	pop    %esi
  800501:	c9                   	leave  
  800502:	c3                   	ret    

00800503 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050c:	50                   	push   %eax
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 aa fe ff ff       	call   8003bf <fd_lookup>
  800515:	83 c4 08             	add    $0x8,%esp
  800518:	85 c0                	test   %eax,%eax
  80051a:	78 10                	js     80052c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	6a 01                	push   $0x1
  800521:	ff 75 f4             	pushl  -0xc(%ebp)
  800524:	e8 52 ff ff ff       	call   80047b <fd_close>
  800529:	83 c4 10             	add    $0x10,%esp
}
  80052c:	c9                   	leave  
  80052d:	c3                   	ret    

0080052e <close_all>:

void
close_all(void)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	53                   	push   %ebx
  800532:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800535:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053a:	83 ec 0c             	sub    $0xc,%esp
  80053d:	53                   	push   %ebx
  80053e:	e8 c0 ff ff ff       	call   800503 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800543:	43                   	inc    %ebx
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	83 fb 20             	cmp    $0x20,%ebx
  80054a:	75 ee                	jne    80053a <close_all+0xc>
		close(i);
}
  80054c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 2c             	sub    $0x2c,%esp
  80055a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800560:	50                   	push   %eax
  800561:	ff 75 08             	pushl  0x8(%ebp)
  800564:	e8 56 fe ff ff       	call   8003bf <fd_lookup>
  800569:	89 c3                	mov    %eax,%ebx
  80056b:	83 c4 08             	add    $0x8,%esp
  80056e:	85 c0                	test   %eax,%eax
  800570:	0f 88 c0 00 00 00    	js     800636 <dup+0xe5>
		return r;
	close(newfdnum);
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	57                   	push   %edi
  80057a:	e8 84 ff ff ff       	call   800503 <close>

	newfd = INDEX2FD(newfdnum);
  80057f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800585:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800588:	83 c4 04             	add    $0x4,%esp
  80058b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058e:	e8 a1 fd ff ff       	call   800334 <fd2data>
  800593:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800595:	89 34 24             	mov    %esi,(%esp)
  800598:	e8 97 fd ff ff       	call   800334 <fd2data>
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a3:	89 d8                	mov    %ebx,%eax
  8005a5:	c1 e8 16             	shr    $0x16,%eax
  8005a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005af:	a8 01                	test   $0x1,%al
  8005b1:	74 37                	je     8005ea <dup+0x99>
  8005b3:	89 d8                	mov    %ebx,%eax
  8005b5:	c1 e8 0c             	shr    $0xc,%eax
  8005b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005bf:	f6 c2 01             	test   $0x1,%dl
  8005c2:	74 26                	je     8005ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d3:	50                   	push   %eax
  8005d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d7:	6a 00                	push   $0x0
  8005d9:	53                   	push   %ebx
  8005da:	6a 00                	push   $0x0
  8005dc:	e8 ff fb ff ff       	call   8001e0 <sys_page_map>
  8005e1:	89 c3                	mov    %eax,%ebx
  8005e3:	83 c4 20             	add    $0x20,%esp
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	78 2d                	js     800617 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ed:	89 c2                	mov    %eax,%edx
  8005ef:	c1 ea 0c             	shr    $0xc,%edx
  8005f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800602:	52                   	push   %edx
  800603:	56                   	push   %esi
  800604:	6a 00                	push   $0x0
  800606:	50                   	push   %eax
  800607:	6a 00                	push   $0x0
  800609:	e8 d2 fb ff ff       	call   8001e0 <sys_page_map>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	79 1d                	jns    800634 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 00                	push   $0x0
  80061d:	e8 e4 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	ff 75 d4             	pushl  -0x2c(%ebp)
  800628:	6a 00                	push   $0x0
  80062a:	e8 d7 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	eb 02                	jmp    800636 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800634:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800636:	89 d8                	mov    %ebx,%eax
  800638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063b:	5b                   	pop    %ebx
  80063c:	5e                   	pop    %esi
  80063d:	5f                   	pop    %edi
  80063e:	c9                   	leave  
  80063f:	c3                   	ret    

00800640 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	53                   	push   %ebx
  800644:	83 ec 14             	sub    $0x14,%esp
  800647:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064d:	50                   	push   %eax
  80064e:	53                   	push   %ebx
  80064f:	e8 6b fd ff ff       	call   8003bf <fd_lookup>
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	85 c0                	test   %eax,%eax
  800659:	78 67                	js     8006c2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800661:	50                   	push   %eax
  800662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800665:	ff 30                	pushl  (%eax)
  800667:	e8 a9 fd ff ff       	call   800415 <dev_lookup>
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	85 c0                	test   %eax,%eax
  800671:	78 4f                	js     8006c2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800676:	8b 50 08             	mov    0x8(%eax),%edx
  800679:	83 e2 03             	and    $0x3,%edx
  80067c:	83 fa 01             	cmp    $0x1,%edx
  80067f:	75 21                	jne    8006a2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800681:	a1 04 40 80 00       	mov    0x804004,%eax
  800686:	8b 40 48             	mov    0x48(%eax),%eax
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	53                   	push   %ebx
  80068d:	50                   	push   %eax
  80068e:	68 19 1e 80 00       	push   $0x801e19
  800693:	e8 18 0a 00 00       	call   8010b0 <cprintf>
		return -E_INVAL;
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a0:	eb 20                	jmp    8006c2 <read+0x82>
	}
	if (!dev->dev_read)
  8006a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a5:	8b 52 08             	mov    0x8(%edx),%edx
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	74 11                	je     8006bd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	50                   	push   %eax
  8006b6:	ff d2                	call   *%edx
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 05                	jmp    8006c2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	57                   	push   %edi
  8006cb:	56                   	push   %esi
  8006cc:	53                   	push   %ebx
  8006cd:	83 ec 0c             	sub    $0xc,%esp
  8006d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d6:	85 f6                	test   %esi,%esi
  8006d8:	74 31                	je     80070b <readn+0x44>
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	89 f2                	mov    %esi,%edx
  8006e9:	29 c2                	sub    %eax,%edx
  8006eb:	52                   	push   %edx
  8006ec:	03 45 0c             	add    0xc(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	57                   	push   %edi
  8006f1:	e8 4a ff ff ff       	call   800640 <read>
		if (m < 0)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	78 17                	js     800714 <readn+0x4d>
			return m;
		if (m == 0)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 11                	je     800712 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	01 c3                	add    %eax,%ebx
  800703:	89 d8                	mov    %ebx,%eax
  800705:	39 f3                	cmp    %esi,%ebx
  800707:	72 db                	jb     8006e4 <readn+0x1d>
  800709:	eb 09                	jmp    800714 <readn+0x4d>
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	eb 02                	jmp    800714 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800712:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 14             	sub    $0x14,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	53                   	push   %ebx
  80072b:	e8 8f fc ff ff       	call   8003bf <fd_lookup>
  800730:	83 c4 08             	add    $0x8,%esp
  800733:	85 c0                	test   %eax,%eax
  800735:	78 62                	js     800799 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800741:	ff 30                	pushl  (%eax)
  800743:	e8 cd fc ff ff       	call   800415 <dev_lookup>
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 c0                	test   %eax,%eax
  80074d:	78 4a                	js     800799 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80074f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800752:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800756:	75 21                	jne    800779 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800758:	a1 04 40 80 00       	mov    0x804004,%eax
  80075d:	8b 40 48             	mov    0x48(%eax),%eax
  800760:	83 ec 04             	sub    $0x4,%esp
  800763:	53                   	push   %ebx
  800764:	50                   	push   %eax
  800765:	68 35 1e 80 00       	push   $0x801e35
  80076a:	e8 41 09 00 00       	call   8010b0 <cprintf>
		return -E_INVAL;
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb 20                	jmp    800799 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800779:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077c:	8b 52 0c             	mov    0xc(%edx),%edx
  80077f:	85 d2                	test   %edx,%edx
  800781:	74 11                	je     800794 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	50                   	push   %eax
  80078d:	ff d2                	call   *%edx
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	eb 05                	jmp    800799 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800794:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <seek>:

int
seek(int fdnum, off_t offset)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	e8 0f fc ff ff       	call   8003bf <fd_lookup>
  8007b0:	83 c4 08             	add    $0x8,%esp
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	78 0e                	js     8007c5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 14             	sub    $0x14,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	53                   	push   %ebx
  8007d6:	e8 e4 fb ff ff       	call   8003bf <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 5f                	js     800841 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e8:	50                   	push   %eax
  8007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ec:	ff 30                	pushl  (%eax)
  8007ee:	e8 22 fc ff ff       	call   800415 <dev_lookup>
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 47                	js     800841 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800801:	75 21                	jne    800824 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800803:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800808:	8b 40 48             	mov    0x48(%eax),%eax
  80080b:	83 ec 04             	sub    $0x4,%esp
  80080e:	53                   	push   %ebx
  80080f:	50                   	push   %eax
  800810:	68 f8 1d 80 00       	push   $0x801df8
  800815:	e8 96 08 00 00       	call   8010b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800822:	eb 1d                	jmp    800841 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800824:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800827:	8b 52 18             	mov    0x18(%edx),%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 0e                	je     80083c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	ff 75 0c             	pushl  0xc(%ebp)
  800834:	50                   	push   %eax
  800835:	ff d2                	call   *%edx
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb 05                	jmp    800841 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	83 ec 14             	sub    $0x14,%esp
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800850:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800853:	50                   	push   %eax
  800854:	ff 75 08             	pushl  0x8(%ebp)
  800857:	e8 63 fb ff ff       	call   8003bf <fd_lookup>
  80085c:	83 c4 08             	add    $0x8,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 52                	js     8008b5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800869:	50                   	push   %eax
  80086a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086d:	ff 30                	pushl  (%eax)
  80086f:	e8 a1 fb ff ff       	call   800415 <dev_lookup>
  800874:	83 c4 10             	add    $0x10,%esp
  800877:	85 c0                	test   %eax,%eax
  800879:	78 3a                	js     8008b5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800882:	74 2c                	je     8008b0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800884:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800887:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088e:	00 00 00 
	stat->st_isdir = 0;
  800891:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800898:	00 00 00 
	stat->st_dev = dev;
  80089b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a8:	ff 50 14             	call   *0x14(%eax)
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	eb 05                	jmp    8008b5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	6a 00                	push   $0x0
  8008c4:	ff 75 08             	pushl  0x8(%ebp)
  8008c7:	e8 78 01 00 00       	call   800a44 <open>
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	78 1b                	js     8008f0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	e8 65 ff ff ff       	call   800846 <fstat>
  8008e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e3:	89 1c 24             	mov    %ebx,(%esp)
  8008e6:	e8 18 fc ff ff       	call   800503 <close>
	return r;
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	89 f3                	mov    %esi,%ebx
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    
  8008f9:	00 00                	add    %al,(%eax)
	...

008008fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	89 c3                	mov    %eax,%ebx
  800903:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800905:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090c:	75 12                	jne    800920 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090e:	83 ec 0c             	sub    $0xc,%esp
  800911:	6a 01                	push   $0x1
  800913:	e8 96 11 00 00       	call   801aae <ipc_find_env>
  800918:	a3 00 40 80 00       	mov    %eax,0x804000
  80091d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800920:	6a 07                	push   $0x7
  800922:	68 00 50 80 00       	push   $0x805000
  800927:	53                   	push   %ebx
  800928:	ff 35 00 40 80 00    	pushl  0x804000
  80092e:	e8 26 11 00 00       	call   801a59 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800933:	83 c4 0c             	add    $0xc,%esp
  800936:	6a 00                	push   $0x0
  800938:	56                   	push   %esi
  800939:	6a 00                	push   $0x0
  80093b:	e8 a4 10 00 00       	call   8019e4 <ipc_recv>
}
  800940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	83 ec 04             	sub    $0x4,%esp
  80094e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 40 0c             	mov    0xc(%eax),%eax
  800957:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80095c:	ba 00 00 00 00       	mov    $0x0,%edx
  800961:	b8 05 00 00 00       	mov    $0x5,%eax
  800966:	e8 91 ff ff ff       	call   8008fc <fsipc>
  80096b:	85 c0                	test   %eax,%eax
  80096d:	78 2c                	js     80099b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	68 00 50 80 00       	push   $0x805000
  800977:	53                   	push   %ebx
  800978:	e8 e9 0c 00 00       	call   801666 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80097d:	a1 80 50 80 00       	mov    0x805080,%eax
  800982:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800988:	a1 84 50 80 00       	mov    0x805084,%eax
  80098d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800993:	83 c4 10             	add    $0x10,%esp
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009bb:	e8 3c ff ff ff       	call   8008fc <fsipc>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009db:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8009e5:	e8 12 ff ff ff       	call   8008fc <fsipc>
  8009ea:	89 c3                	mov    %eax,%ebx
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	78 4b                	js     800a3b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009f0:	39 c6                	cmp    %eax,%esi
  8009f2:	73 16                	jae    800a0a <devfile_read+0x48>
  8009f4:	68 64 1e 80 00       	push   $0x801e64
  8009f9:	68 6b 1e 80 00       	push   $0x801e6b
  8009fe:	6a 7d                	push   $0x7d
  800a00:	68 80 1e 80 00       	push   $0x801e80
  800a05:	e8 ce 05 00 00       	call   800fd8 <_panic>
	assert(r <= PGSIZE);
  800a0a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a0f:	7e 16                	jle    800a27 <devfile_read+0x65>
  800a11:	68 8b 1e 80 00       	push   $0x801e8b
  800a16:	68 6b 1e 80 00       	push   $0x801e6b
  800a1b:	6a 7e                	push   $0x7e
  800a1d:	68 80 1e 80 00       	push   $0x801e80
  800a22:	e8 b1 05 00 00       	call   800fd8 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a27:	83 ec 04             	sub    $0x4,%esp
  800a2a:	50                   	push   %eax
  800a2b:	68 00 50 80 00       	push   $0x805000
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	e8 ef 0d 00 00       	call   801827 <memmove>
	return r;
  800a38:	83 c4 10             	add    $0x10,%esp
}
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	83 ec 1c             	sub    $0x1c,%esp
  800a4c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a4f:	56                   	push   %esi
  800a50:	e8 bf 0b 00 00       	call   801614 <strlen>
  800a55:	83 c4 10             	add    $0x10,%esp
  800a58:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a5d:	7f 65                	jg     800ac4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a5f:	83 ec 0c             	sub    $0xc,%esp
  800a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a65:	50                   	push   %eax
  800a66:	e8 e1 f8 ff ff       	call   80034c <fd_alloc>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 55                	js     800ac9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a74:	83 ec 08             	sub    $0x8,%esp
  800a77:	56                   	push   %esi
  800a78:	68 00 50 80 00       	push   $0x805000
  800a7d:	e8 e4 0b 00 00       	call   801666 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	e8 65 fe ff ff       	call   8008fc <fsipc>
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	79 12                	jns    800ab2 <open+0x6e>
		fd_close(fd, 0);
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	6a 00                	push   $0x0
  800aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa8:	e8 ce f9 ff ff       	call   80047b <fd_close>
		return r;
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	eb 17                	jmp    800ac9 <open+0x85>
	}

	return fd2num(fd);
  800ab2:	83 ec 0c             	sub    $0xc,%esp
  800ab5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab8:	e8 67 f8 ff ff       	call   800324 <fd2num>
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	eb 05                	jmp    800ac9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ac4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    
	...

00800ad4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 4d f8 ff ff       	call   800334 <fd2data>
  800ae7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ae9:	83 c4 08             	add    $0x8,%esp
  800aec:	68 97 1e 80 00       	push   $0x801e97
  800af1:	56                   	push   %esi
  800af2:	e8 6f 0b 00 00       	call   801666 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800af7:	8b 43 04             	mov    0x4(%ebx),%eax
  800afa:	2b 03                	sub    (%ebx),%eax
  800afc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b02:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b09:	00 00 00 
	stat->st_dev = &devpipe;
  800b0c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b13:	30 80 00 
	return 0;
}
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b2c:	53                   	push   %ebx
  800b2d:	6a 00                	push   $0x0
  800b2f:	e8 d2 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b34:	89 1c 24             	mov    %ebx,(%esp)
  800b37:	e8 f8 f7 ff ff       	call   800334 <fd2data>
  800b3c:	83 c4 08             	add    $0x8,%esp
  800b3f:	50                   	push   %eax
  800b40:	6a 00                	push   $0x0
  800b42:	e8 bf f6 ff ff       	call   800206 <sys_page_unmap>
}
  800b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 1c             	sub    $0x1c,%esp
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	57                   	push   %edi
  800b66:	e8 a1 0f 00 00       	call   801b0c <pageref>
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	83 c4 04             	add    $0x4,%esp
  800b70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b73:	e8 94 0f 00 00       	call   801b0c <pageref>
  800b78:	83 c4 10             	add    $0x10,%esp
  800b7b:	39 c6                	cmp    %eax,%esi
  800b7d:	0f 94 c0             	sete   %al
  800b80:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b83:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b8c:	39 cb                	cmp    %ecx,%ebx
  800b8e:	75 08                	jne    800b98 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b98:	83 f8 01             	cmp    $0x1,%eax
  800b9b:	75 bd                	jne    800b5a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b9d:	8b 42 58             	mov    0x58(%edx),%eax
  800ba0:	6a 01                	push   $0x1
  800ba2:	50                   	push   %eax
  800ba3:	53                   	push   %ebx
  800ba4:	68 9e 1e 80 00       	push   $0x801e9e
  800ba9:	e8 02 05 00 00       	call   8010b0 <cprintf>
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	eb a7                	jmp    800b5a <_pipeisclosed+0xe>

00800bb3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 28             	sub    $0x28,%esp
  800bbc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bbf:	56                   	push   %esi
  800bc0:	e8 6f f7 ff ff       	call   800334 <fd2data>
  800bc5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bc7:	83 c4 10             	add    $0x10,%esp
  800bca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bce:	75 4a                	jne    800c1a <devpipe_write+0x67>
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd5:	eb 56                	jmp    800c2d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bd7:	89 da                	mov    %ebx,%edx
  800bd9:	89 f0                	mov    %esi,%eax
  800bdb:	e8 6c ff ff ff       	call   800b4c <_pipeisclosed>
  800be0:	85 c0                	test   %eax,%eax
  800be2:	75 4d                	jne    800c31 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800be4:	e8 ac f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800be9:	8b 43 04             	mov    0x4(%ebx),%eax
  800bec:	8b 13                	mov    (%ebx),%edx
  800bee:	83 c2 20             	add    $0x20,%edx
  800bf1:	39 d0                	cmp    %edx,%eax
  800bf3:	73 e2                	jae    800bd7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bfd:	79 05                	jns    800c04 <devpipe_write+0x51>
  800bff:	4a                   	dec    %edx
  800c00:	83 ca e0             	or     $0xffffffe0,%edx
  800c03:	42                   	inc    %edx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c0a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c0e:	40                   	inc    %eax
  800c0f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c12:	47                   	inc    %edi
  800c13:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c16:	77 07                	ja     800c1f <devpipe_write+0x6c>
  800c18:	eb 13                	jmp    800c2d <devpipe_write+0x7a>
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c1f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c22:	8b 13                	mov    (%ebx),%edx
  800c24:	83 c2 20             	add    $0x20,%edx
  800c27:	39 d0                	cmp    %edx,%eax
  800c29:	73 ac                	jae    800bd7 <devpipe_write+0x24>
  800c2b:	eb c8                	jmp    800bf5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	eb 05                	jmp    800c36 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 18             	sub    $0x18,%esp
  800c47:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c4a:	57                   	push   %edi
  800c4b:	e8 e4 f6 ff ff       	call   800334 <fd2data>
  800c50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c59:	75 44                	jne    800c9f <devpipe_read+0x61>
  800c5b:	be 00 00 00 00       	mov    $0x0,%esi
  800c60:	eb 4f                	jmp    800cb1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c62:	89 f0                	mov    %esi,%eax
  800c64:	eb 54                	jmp    800cba <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c66:	89 da                	mov    %ebx,%edx
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	e8 dd fe ff ff       	call   800b4c <_pipeisclosed>
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	75 42                	jne    800cb5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c73:	e8 1d f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c78:	8b 03                	mov    (%ebx),%eax
  800c7a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c7d:	74 e7                	je     800c66 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c7f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c84:	79 05                	jns    800c8b <devpipe_read+0x4d>
  800c86:	48                   	dec    %eax
  800c87:	83 c8 e0             	or     $0xffffffe0,%eax
  800c8a:	40                   	inc    %eax
  800c8b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c92:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c95:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c97:	46                   	inc    %esi
  800c98:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c9b:	77 07                	ja     800ca4 <devpipe_read+0x66>
  800c9d:	eb 12                	jmp    800cb1 <devpipe_read+0x73>
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ca4:	8b 03                	mov    (%ebx),%eax
  800ca6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca9:	75 d4                	jne    800c7f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cab:	85 f6                	test   %esi,%esi
  800cad:	75 b3                	jne    800c62 <devpipe_read+0x24>
  800caf:	eb b5                	jmp    800c66 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cb1:	89 f0                	mov    %esi,%eax
  800cb3:	eb 05                	jmp    800cba <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 28             	sub    $0x28,%esp
  800ccb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cd1:	50                   	push   %eax
  800cd2:	e8 75 f6 ff ff       	call   80034c <fd_alloc>
  800cd7:	89 c3                	mov    %eax,%ebx
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	0f 88 24 01 00 00    	js     800e08 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ce4:	83 ec 04             	sub    $0x4,%esp
  800ce7:	68 07 04 00 00       	push   $0x407
  800cec:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cef:	6a 00                	push   $0x0
  800cf1:	e8 c6 f4 ff ff       	call   8001bc <sys_page_alloc>
  800cf6:	89 c3                	mov    %eax,%ebx
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	0f 88 05 01 00 00    	js     800e08 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d09:	50                   	push   %eax
  800d0a:	e8 3d f6 ff ff       	call   80034c <fd_alloc>
  800d0f:	89 c3                	mov    %eax,%ebx
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	85 c0                	test   %eax,%eax
  800d16:	0f 88 dc 00 00 00    	js     800df8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1c:	83 ec 04             	sub    $0x4,%esp
  800d1f:	68 07 04 00 00       	push   $0x407
  800d24:	ff 75 e0             	pushl  -0x20(%ebp)
  800d27:	6a 00                	push   $0x0
  800d29:	e8 8e f4 ff ff       	call   8001bc <sys_page_alloc>
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	0f 88 bd 00 00 00    	js     800df8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d41:	e8 ee f5 ff ff       	call   800334 <fd2data>
  800d46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d48:	83 c4 0c             	add    $0xc,%esp
  800d4b:	68 07 04 00 00       	push   $0x407
  800d50:	50                   	push   %eax
  800d51:	6a 00                	push   $0x0
  800d53:	e8 64 f4 ff ff       	call   8001bc <sys_page_alloc>
  800d58:	89 c3                	mov    %eax,%ebx
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	0f 88 83 00 00 00    	js     800de8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	ff 75 e0             	pushl  -0x20(%ebp)
  800d6b:	e8 c4 f5 ff ff       	call   800334 <fd2data>
  800d70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d77:	50                   	push   %eax
  800d78:	6a 00                	push   $0x0
  800d7a:	56                   	push   %esi
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 5e f4 ff ff       	call   8001e0 <sys_page_map>
  800d82:	89 c3                	mov    %eax,%ebx
  800d84:	83 c4 20             	add    $0x20,%esp
  800d87:	85 c0                	test   %eax,%eax
  800d89:	78 4f                	js     800dda <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800da0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800da9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dbb:	e8 64 f5 ff ff       	call   800324 <fd2num>
  800dc0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dc2:	83 c4 04             	add    $0x4,%esp
  800dc5:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc8:	e8 57 f5 ff ff       	call   800324 <fd2num>
  800dcd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	eb 2e                	jmp    800e08 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	56                   	push   %esi
  800dde:	6a 00                	push   $0x0
  800de0:	e8 21 f4 ff ff       	call   800206 <sys_page_unmap>
  800de5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dee:	6a 00                	push   $0x0
  800df0:	e8 11 f4 ff ff       	call   800206 <sys_page_unmap>
  800df5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dfe:	6a 00                	push   $0x0
  800e00:	e8 01 f4 ff ff       	call   800206 <sys_page_unmap>
  800e05:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1b:	50                   	push   %eax
  800e1c:	ff 75 08             	pushl  0x8(%ebp)
  800e1f:	e8 9b f5 ff ff       	call   8003bf <fd_lookup>
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	78 18                	js     800e43 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e31:	e8 fe f4 ff ff       	call   800334 <fd2data>
	return _pipeisclosed(fd, p);
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3b:	e8 0c fd ff ff       	call   800b4c <_pipeisclosed>
  800e40:	83 c4 10             	add    $0x10,%esp
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    
  800e45:	00 00                	add    %al,(%eax)
	...

00800e48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e58:	68 b6 1e 80 00       	push   $0x801eb6
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	e8 01 08 00 00       	call   801666 <strcpy>
	return 0;
}
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7c:	74 45                	je     800ec3 <devcons_write+0x57>
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e91:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e93:	83 fb 7f             	cmp    $0x7f,%ebx
  800e96:	76 05                	jbe    800e9d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e98:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e9d:	83 ec 04             	sub    $0x4,%esp
  800ea0:	53                   	push   %ebx
  800ea1:	03 45 0c             	add    0xc(%ebp),%eax
  800ea4:	50                   	push   %eax
  800ea5:	57                   	push   %edi
  800ea6:	e8 7c 09 00 00       	call   801827 <memmove>
		sys_cputs(buf, m);
  800eab:	83 c4 08             	add    $0x8,%esp
  800eae:	53                   	push   %ebx
  800eaf:	57                   	push   %edi
  800eb0:	e8 50 f2 ff ff       	call   800105 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb5:	01 de                	add    %ebx,%esi
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ebf:	72 cd                	jb     800e8e <devcons_write+0x22>
  800ec1:	eb 05                	jmp    800ec8 <devcons_write+0x5c>
  800ec3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ec8:	89 f0                	mov    %esi,%eax
  800eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ed8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800edc:	75 07                	jne    800ee5 <devcons_read+0x13>
  800ede:	eb 25                	jmp    800f05 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ee0:	e8 b0 f2 ff ff       	call   800195 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ee5:	e8 41 f2 ff ff       	call   80012b <sys_cgetc>
  800eea:	85 c0                	test   %eax,%eax
  800eec:	74 f2                	je     800ee0 <devcons_read+0xe>
  800eee:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 1d                	js     800f11 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ef4:	83 f8 04             	cmp    $0x4,%eax
  800ef7:	74 13                	je     800f0c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efc:	88 10                	mov    %dl,(%eax)
	return 1;
  800efe:	b8 01 00 00 00       	mov    $0x1,%eax
  800f03:	eb 0c                	jmp    800f11 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	eb 05                	jmp    800f11 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    

00800f13 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f1f:	6a 01                	push   $0x1
  800f21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	e8 db f1 ff ff       	call   800105 <sys_cputs>
  800f2a:	83 c4 10             	add    $0x10,%esp
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <getchar>:

int
getchar(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f35:	6a 01                	push   $0x1
  800f37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f3a:	50                   	push   %eax
  800f3b:	6a 00                	push   $0x0
  800f3d:	e8 fe f6 ff ff       	call   800640 <read>
	if (r < 0)
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 0f                	js     800f58 <getchar+0x29>
		return r;
	if (r < 1)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	7e 06                	jle    800f53 <getchar+0x24>
		return -E_EOF;
	return c;
  800f4d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f51:	eb 05                	jmp    800f58 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f53:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	ff 75 08             	pushl  0x8(%ebp)
  800f67:	e8 53 f4 ff ff       	call   8003bf <fd_lookup>
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 11                	js     800f84 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f7c:	39 10                	cmp    %edx,(%eax)
  800f7e:	0f 94 c0             	sete   %al
  800f81:	0f b6 c0             	movzbl %al,%eax
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <opencons>:

int
opencons(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	e8 b7 f3 ff ff       	call   80034c <fd_alloc>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 3a                	js     800fd6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 07 04 00 00       	push   $0x407
  800fa4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 0e f2 ff ff       	call   8001bc <sys_page_alloc>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 21                	js     800fd6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fb5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	50                   	push   %eax
  800fce:	e8 51 f3 ff ff       	call   800324 <fd2num>
  800fd3:	83 c4 10             	add    $0x10,%esp
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fdd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fe0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fe6:	e8 86 f1 ff ff       	call   800171 <sys_getenvid>
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	ff 75 0c             	pushl  0xc(%ebp)
  800ff1:	ff 75 08             	pushl  0x8(%ebp)
  800ff4:	53                   	push   %ebx
  800ff5:	50                   	push   %eax
  800ff6:	68 c4 1e 80 00       	push   $0x801ec4
  800ffb:	e8 b0 00 00 00       	call   8010b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801000:	83 c4 18             	add    $0x18,%esp
  801003:	56                   	push   %esi
  801004:	ff 75 10             	pushl  0x10(%ebp)
  801007:	e8 53 00 00 00       	call   80105f <vcprintf>
	cprintf("\n");
  80100c:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801013:	e8 98 00 00 00       	call   8010b0 <cprintf>
  801018:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80101b:	cc                   	int3   
  80101c:	eb fd                	jmp    80101b <_panic+0x43>
	...

00801020 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	53                   	push   %ebx
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80102a:	8b 03                	mov    (%ebx),%eax
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801033:	40                   	inc    %eax
  801034:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801036:	3d ff 00 00 00       	cmp    $0xff,%eax
  80103b:	75 1a                	jne    801057 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	68 ff 00 00 00       	push   $0xff
  801045:	8d 43 08             	lea    0x8(%ebx),%eax
  801048:	50                   	push   %eax
  801049:	e8 b7 f0 ff ff       	call   800105 <sys_cputs>
		b->idx = 0;
  80104e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801054:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801057:	ff 43 04             	incl   0x4(%ebx)
}
  80105a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801068:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80106f:	00 00 00 
	b.cnt = 0;
  801072:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801079:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80107c:	ff 75 0c             	pushl  0xc(%ebp)
  80107f:	ff 75 08             	pushl  0x8(%ebp)
  801082:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	68 20 10 80 00       	push   $0x801020
  80108e:	e8 82 01 00 00       	call   801215 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801093:	83 c4 08             	add    $0x8,%esp
  801096:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80109c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010a2:	50                   	push   %eax
  8010a3:	e8 5d f0 ff ff       	call   800105 <sys_cputs>

	return b.cnt;
}
  8010a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010b9:	50                   	push   %eax
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	e8 9d ff ff ff       	call   80105f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 2c             	sub    $0x2c,%esp
  8010cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d0:	89 d6                	mov    %edx,%esi
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010de:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010e4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010f1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010f4:	72 0c                	jb     801102 <printnum+0x3e>
  8010f6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010f9:	76 07                	jbe    801102 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010fb:	4b                   	dec    %ebx
  8010fc:	85 db                	test   %ebx,%ebx
  8010fe:	7f 31                	jg     801131 <printnum+0x6d>
  801100:	eb 3f                	jmp    801141 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	57                   	push   %edi
  801106:	4b                   	dec    %ebx
  801107:	53                   	push   %ebx
  801108:	50                   	push   %eax
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110f:	ff 75 d0             	pushl  -0x30(%ebp)
  801112:	ff 75 dc             	pushl  -0x24(%ebp)
  801115:	ff 75 d8             	pushl  -0x28(%ebp)
  801118:	e8 33 0a 00 00       	call   801b50 <__udivdi3>
  80111d:	83 c4 18             	add    $0x18,%esp
  801120:	52                   	push   %edx
  801121:	50                   	push   %eax
  801122:	89 f2                	mov    %esi,%edx
  801124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801127:	e8 98 ff ff ff       	call   8010c4 <printnum>
  80112c:	83 c4 20             	add    $0x20,%esp
  80112f:	eb 10                	jmp    801141 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	56                   	push   %esi
  801135:	57                   	push   %edi
  801136:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801139:	4b                   	dec    %ebx
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 db                	test   %ebx,%ebx
  80113f:	7f f0                	jg     801131 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	56                   	push   %esi
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114b:	ff 75 d0             	pushl  -0x30(%ebp)
  80114e:	ff 75 dc             	pushl  -0x24(%ebp)
  801151:	ff 75 d8             	pushl  -0x28(%ebp)
  801154:	e8 13 0b 00 00       	call   801c6c <__umoddi3>
  801159:	83 c4 14             	add    $0x14,%esp
  80115c:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  801163:	50                   	push   %eax
  801164:	ff 55 e4             	call   *-0x1c(%ebp)
  801167:	83 c4 10             	add    $0x10,%esp
}
  80116a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	c9                   	leave  
  801171:	c3                   	ret    

00801172 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801175:	83 fa 01             	cmp    $0x1,%edx
  801178:	7e 0e                	jle    801188 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80117a:	8b 10                	mov    (%eax),%edx
  80117c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80117f:	89 08                	mov    %ecx,(%eax)
  801181:	8b 02                	mov    (%edx),%eax
  801183:	8b 52 04             	mov    0x4(%edx),%edx
  801186:	eb 22                	jmp    8011aa <getuint+0x38>
	else if (lflag)
  801188:	85 d2                	test   %edx,%edx
  80118a:	74 10                	je     80119c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80118c:	8b 10                	mov    (%eax),%edx
  80118e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801191:	89 08                	mov    %ecx,(%eax)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	ba 00 00 00 00       	mov    $0x0,%edx
  80119a:	eb 0e                	jmp    8011aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80119c:	8b 10                	mov    (%eax),%edx
  80119e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a1:	89 08                	mov    %ecx,(%eax)
  8011a3:	8b 02                	mov    (%edx),%eax
  8011a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011af:	83 fa 01             	cmp    $0x1,%edx
  8011b2:	7e 0e                	jle    8011c2 <getint+0x16>
		return va_arg(*ap, long long);
  8011b4:	8b 10                	mov    (%eax),%edx
  8011b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b9:	89 08                	mov    %ecx,(%eax)
  8011bb:	8b 02                	mov    (%edx),%eax
  8011bd:	8b 52 04             	mov    0x4(%edx),%edx
  8011c0:	eb 1a                	jmp    8011dc <getint+0x30>
	else if (lflag)
  8011c2:	85 d2                	test   %edx,%edx
  8011c4:	74 0c                	je     8011d2 <getint+0x26>
		return va_arg(*ap, long);
  8011c6:	8b 10                	mov    (%eax),%edx
  8011c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cb:	89 08                	mov    %ecx,(%eax)
  8011cd:	8b 02                	mov    (%edx),%eax
  8011cf:	99                   	cltd   
  8011d0:	eb 0a                	jmp    8011dc <getint+0x30>
	else
		return va_arg(*ap, int);
  8011d2:	8b 10                	mov    (%eax),%edx
  8011d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d7:	89 08                	mov    %ecx,(%eax)
  8011d9:	8b 02                	mov    (%edx),%eax
  8011db:	99                   	cltd   
}
  8011dc:	c9                   	leave  
  8011dd:	c3                   	ret    

008011de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011e7:	8b 10                	mov    (%eax),%edx
  8011e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ec:	73 08                	jae    8011f6 <sprintputch+0x18>
		*b->buf++ = ch;
  8011ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f1:	88 0a                	mov    %cl,(%edx)
  8011f3:	42                   	inc    %edx
  8011f4:	89 10                	mov    %edx,(%eax)
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801201:	50                   	push   %eax
  801202:	ff 75 10             	pushl  0x10(%ebp)
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 05 00 00 00       	call   801215 <vprintfmt>
	va_end(ap);
  801210:	83 c4 10             	add    $0x10,%esp
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 2c             	sub    $0x2c,%esp
  80121e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801221:	8b 75 10             	mov    0x10(%ebp),%esi
  801224:	eb 13                	jmp    801239 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801226:	85 c0                	test   %eax,%eax
  801228:	0f 84 6d 03 00 00    	je     80159b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	57                   	push   %edi
  801232:	50                   	push   %eax
  801233:	ff 55 08             	call   *0x8(%ebp)
  801236:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801239:	0f b6 06             	movzbl (%esi),%eax
  80123c:	46                   	inc    %esi
  80123d:	83 f8 25             	cmp    $0x25,%eax
  801240:	75 e4                	jne    801226 <vprintfmt+0x11>
  801242:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801246:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80124d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801254:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80125b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801260:	eb 28                	jmp    80128a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801262:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801264:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801268:	eb 20                	jmp    80128a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80126c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801270:	eb 18                	jmp    80128a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801272:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801274:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80127b:	eb 0d                	jmp    80128a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80127d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801280:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801283:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128a:	8a 06                	mov    (%esi),%al
  80128c:	0f b6 d0             	movzbl %al,%edx
  80128f:	8d 5e 01             	lea    0x1(%esi),%ebx
  801292:	83 e8 23             	sub    $0x23,%eax
  801295:	3c 55                	cmp    $0x55,%al
  801297:	0f 87 e0 02 00 00    	ja     80157d <vprintfmt+0x368>
  80129d:	0f b6 c0             	movzbl %al,%eax
  8012a0:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a7:	83 ea 30             	sub    $0x30,%edx
  8012aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012ad:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012b0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012b3:	83 fa 09             	cmp    $0x9,%edx
  8012b6:	77 44                	ja     8012fc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b8:	89 de                	mov    %ebx,%esi
  8012ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012be:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012c1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012c5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012cb:	83 fb 09             	cmp    $0x9,%ebx
  8012ce:	76 ed                	jbe    8012bd <vprintfmt+0xa8>
  8012d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012d3:	eb 29                	jmp    8012fe <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d8:	8d 50 04             	lea    0x4(%eax),%edx
  8012db:	89 55 14             	mov    %edx,0x14(%ebp)
  8012de:	8b 00                	mov    (%eax),%eax
  8012e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012e5:	eb 17                	jmp    8012fe <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012eb:	78 85                	js     801272 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ed:	89 de                	mov    %ebx,%esi
  8012ef:	eb 99                	jmp    80128a <vprintfmt+0x75>
  8012f1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012fa:	eb 8e                	jmp    80128a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801302:	79 86                	jns    80128a <vprintfmt+0x75>
  801304:	e9 74 ff ff ff       	jmp    80127d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801309:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130a:	89 de                	mov    %ebx,%esi
  80130c:	e9 79 ff ff ff       	jmp    80128a <vprintfmt+0x75>
  801311:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801314:	8b 45 14             	mov    0x14(%ebp),%eax
  801317:	8d 50 04             	lea    0x4(%eax),%edx
  80131a:	89 55 14             	mov    %edx,0x14(%ebp)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	57                   	push   %edi
  801321:	ff 30                	pushl  (%eax)
  801323:	ff 55 08             	call   *0x8(%ebp)
			break;
  801326:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801329:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80132c:	e9 08 ff ff ff       	jmp    801239 <vprintfmt+0x24>
  801331:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801334:	8b 45 14             	mov    0x14(%ebp),%eax
  801337:	8d 50 04             	lea    0x4(%eax),%edx
  80133a:	89 55 14             	mov    %edx,0x14(%ebp)
  80133d:	8b 00                	mov    (%eax),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	79 02                	jns    801345 <vprintfmt+0x130>
  801343:	f7 d8                	neg    %eax
  801345:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801347:	83 f8 0f             	cmp    $0xf,%eax
  80134a:	7f 0b                	jg     801357 <vprintfmt+0x142>
  80134c:	8b 04 85 80 21 80 00 	mov    0x802180(,%eax,4),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	75 1a                	jne    801371 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801357:	52                   	push   %edx
  801358:	68 ff 1e 80 00       	push   $0x801eff
  80135d:	57                   	push   %edi
  80135e:	ff 75 08             	pushl  0x8(%ebp)
  801361:	e8 92 fe ff ff       	call   8011f8 <printfmt>
  801366:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801369:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136c:	e9 c8 fe ff ff       	jmp    801239 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801371:	50                   	push   %eax
  801372:	68 7d 1e 80 00       	push   $0x801e7d
  801377:	57                   	push   %edi
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 78 fe ff ff       	call   8011f8 <printfmt>
  801380:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801386:	e9 ae fe ff ff       	jmp    801239 <vprintfmt+0x24>
  80138b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80138e:	89 de                	mov    %ebx,%esi
  801390:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801393:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	8d 50 04             	lea    0x4(%eax),%edx
  80139c:	89 55 14             	mov    %edx,0x14(%ebp)
  80139f:	8b 00                	mov    (%eax),%eax
  8013a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	75 07                	jne    8013af <vprintfmt+0x19a>
				p = "(null)";
  8013a8:	c7 45 d0 f8 1e 80 00 	movl   $0x801ef8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013af:	85 db                	test   %ebx,%ebx
  8013b1:	7e 42                	jle    8013f5 <vprintfmt+0x1e0>
  8013b3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013b7:	74 3c                	je     8013f5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	51                   	push   %ecx
  8013bd:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c0:	e8 6f 02 00 00       	call   801634 <strnlen>
  8013c5:	29 c3                	sub    %eax,%ebx
  8013c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 db                	test   %ebx,%ebx
  8013cf:	7e 24                	jle    8013f5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013d1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013d5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	57                   	push   %edi
  8013df:	53                   	push   %ebx
  8013e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e3:	4e                   	dec    %esi
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 f6                	test   %esi,%esi
  8013e9:	7f f0                	jg     8013db <vprintfmt+0x1c6>
  8013eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013f8:	0f be 02             	movsbl (%edx),%eax
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	75 47                	jne    801446 <vprintfmt+0x231>
  8013ff:	eb 37                	jmp    801438 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801401:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801405:	74 16                	je     80141d <vprintfmt+0x208>
  801407:	8d 50 e0             	lea    -0x20(%eax),%edx
  80140a:	83 fa 5e             	cmp    $0x5e,%edx
  80140d:	76 0e                	jbe    80141d <vprintfmt+0x208>
					putch('?', putdat);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	57                   	push   %edi
  801413:	6a 3f                	push   $0x3f
  801415:	ff 55 08             	call   *0x8(%ebp)
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	eb 0b                	jmp    801428 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	57                   	push   %edi
  801421:	50                   	push   %eax
  801422:	ff 55 08             	call   *0x8(%ebp)
  801425:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801428:	ff 4d e4             	decl   -0x1c(%ebp)
  80142b:	0f be 03             	movsbl (%ebx),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 03                	je     801435 <vprintfmt+0x220>
  801432:	43                   	inc    %ebx
  801433:	eb 1b                	jmp    801450 <vprintfmt+0x23b>
  801435:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801438:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80143c:	7f 1e                	jg     80145c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801441:	e9 f3 fd ff ff       	jmp    801239 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801446:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801449:	43                   	inc    %ebx
  80144a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80144d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801450:	85 f6                	test   %esi,%esi
  801452:	78 ad                	js     801401 <vprintfmt+0x1ec>
  801454:	4e                   	dec    %esi
  801455:	79 aa                	jns    801401 <vprintfmt+0x1ec>
  801457:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80145a:	eb dc                	jmp    801438 <vprintfmt+0x223>
  80145c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	57                   	push   %edi
  801463:	6a 20                	push   $0x20
  801465:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801468:	4b                   	dec    %ebx
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 db                	test   %ebx,%ebx
  80146e:	7f ef                	jg     80145f <vprintfmt+0x24a>
  801470:	e9 c4 fd ff ff       	jmp    801239 <vprintfmt+0x24>
  801475:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801478:	89 ca                	mov    %ecx,%edx
  80147a:	8d 45 14             	lea    0x14(%ebp),%eax
  80147d:	e8 2a fd ff ff       	call   8011ac <getint>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  801486:	85 d2                	test   %edx,%edx
  801488:	78 0a                	js     801494 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80148a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80148f:	e9 b0 00 00 00       	jmp    801544 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	57                   	push   %edi
  801498:	6a 2d                	push   $0x2d
  80149a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80149d:	f7 db                	neg    %ebx
  80149f:	83 d6 00             	adc    $0x0,%esi
  8014a2:	f7 de                	neg    %esi
  8014a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ac:	e9 93 00 00 00       	jmp    801544 <vprintfmt+0x32f>
  8014b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014b4:	89 ca                	mov    %ecx,%edx
  8014b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b9:	e8 b4 fc ff ff       	call   801172 <getuint>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 d6                	mov    %edx,%esi
			base = 10;
  8014c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014c7:	eb 7b                	jmp    801544 <vprintfmt+0x32f>
  8014c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014cc:	89 ca                	mov    %ecx,%edx
  8014ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d1:	e8 d6 fc ff ff       	call   8011ac <getint>
  8014d6:	89 c3                	mov    %eax,%ebx
  8014d8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014da:	85 d2                	test   %edx,%edx
  8014dc:	78 07                	js     8014e5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014de:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e3:	eb 5f                	jmp    801544 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	57                   	push   %edi
  8014e9:	6a 2d                	push   $0x2d
  8014eb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014ee:	f7 db                	neg    %ebx
  8014f0:	83 d6 00             	adc    $0x0,%esi
  8014f3:	f7 de                	neg    %esi
  8014f5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8014fd:	eb 45                	jmp    801544 <vprintfmt+0x32f>
  8014ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	57                   	push   %edi
  801506:	6a 30                	push   $0x30
  801508:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80150b:	83 c4 08             	add    $0x8,%esp
  80150e:	57                   	push   %edi
  80150f:	6a 78                	push   $0x78
  801511:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801514:	8b 45 14             	mov    0x14(%ebp),%eax
  801517:	8d 50 04             	lea    0x4(%eax),%edx
  80151a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80151d:	8b 18                	mov    (%eax),%ebx
  80151f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801524:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801527:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80152c:	eb 16                	jmp    801544 <vprintfmt+0x32f>
  80152e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801531:	89 ca                	mov    %ecx,%edx
  801533:	8d 45 14             	lea    0x14(%ebp),%eax
  801536:	e8 37 fc ff ff       	call   801172 <getuint>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	89 d6                	mov    %edx,%esi
			base = 16;
  80153f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80154b:	52                   	push   %edx
  80154c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154f:	50                   	push   %eax
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	89 fa                	mov    %edi,%edx
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	e8 68 fb ff ff       	call   8010c4 <printnum>
			break;
  80155c:	83 c4 20             	add    $0x20,%esp
  80155f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801562:	e9 d2 fc ff ff       	jmp    801239 <vprintfmt+0x24>
  801567:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	57                   	push   %edi
  80156e:	52                   	push   %edx
  80156f:	ff 55 08             	call   *0x8(%ebp)
			break;
  801572:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801575:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801578:	e9 bc fc ff ff       	jmp    801239 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	57                   	push   %edi
  801581:	6a 25                	push   $0x25
  801583:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	eb 02                	jmp    80158d <vprintfmt+0x378>
  80158b:	89 c6                	mov    %eax,%esi
  80158d:	8d 46 ff             	lea    -0x1(%esi),%eax
  801590:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801594:	75 f5                	jne    80158b <vprintfmt+0x376>
  801596:	e9 9e fc ff ff       	jmp    801239 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80159b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5f                   	pop    %edi
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 18             	sub    $0x18,%esp
  8015a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	74 26                	je     8015ea <vsnprintf+0x47>
  8015c4:	85 d2                	test   %edx,%edx
  8015c6:	7e 29                	jle    8015f1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015c8:	ff 75 14             	pushl  0x14(%ebp)
  8015cb:	ff 75 10             	pushl  0x10(%ebp)
  8015ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	68 de 11 80 00       	push   $0x8011de
  8015d7:	e8 39 fc ff ff       	call   801215 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	eb 0c                	jmp    8015f6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ef:	eb 05                	jmp    8015f6 <vsnprintf+0x53>
  8015f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801601:	50                   	push   %eax
  801602:	ff 75 10             	pushl  0x10(%ebp)
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 93 ff ff ff       	call   8015a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801610:	c9                   	leave  
  801611:	c3                   	ret    
	...

00801614 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80161a:	80 3a 00             	cmpb   $0x0,(%edx)
  80161d:	74 0e                	je     80162d <strlen+0x19>
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801624:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801625:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801629:	75 f9                	jne    801624 <strlen+0x10>
  80162b:	eb 05                	jmp    801632 <strlen+0x1e>
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80163d:	85 d2                	test   %edx,%edx
  80163f:	74 17                	je     801658 <strnlen+0x24>
  801641:	80 39 00             	cmpb   $0x0,(%ecx)
  801644:	74 19                	je     80165f <strnlen+0x2b>
  801646:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80164b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80164c:	39 d0                	cmp    %edx,%eax
  80164e:	74 14                	je     801664 <strnlen+0x30>
  801650:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801654:	75 f5                	jne    80164b <strnlen+0x17>
  801656:	eb 0c                	jmp    801664 <strnlen+0x30>
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
  80165d:	eb 05                	jmp    801664 <strnlen+0x30>
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801678:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80167b:	42                   	inc    %edx
  80167c:	84 c9                	test   %cl,%cl
  80167e:	75 f5                	jne    801675 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801680:	5b                   	pop    %ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80168a:	53                   	push   %ebx
  80168b:	e8 84 ff ff ff       	call   801614 <strlen>
  801690:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801699:	50                   	push   %eax
  80169a:	e8 c7 ff ff ff       	call   801666 <strcpy>
	return dst;
}
  80169f:	89 d8                	mov    %ebx,%eax
  8016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b4:	85 f6                	test   %esi,%esi
  8016b6:	74 15                	je     8016cd <strncpy+0x27>
  8016b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016bd:	8a 1a                	mov    (%edx),%bl
  8016bf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016c2:	80 3a 01             	cmpb   $0x1,(%edx)
  8016c5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c8:	41                   	inc    %ecx
  8016c9:	39 ce                	cmp    %ecx,%esi
  8016cb:	77 f0                	ja     8016bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	57                   	push   %edi
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e0:	85 f6                	test   %esi,%esi
  8016e2:	74 32                	je     801716 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016e4:	83 fe 01             	cmp    $0x1,%esi
  8016e7:	74 22                	je     80170b <strlcpy+0x3a>
  8016e9:	8a 0b                	mov    (%ebx),%cl
  8016eb:	84 c9                	test   %cl,%cl
  8016ed:	74 20                	je     80170f <strlcpy+0x3e>
  8016ef:	89 f8                	mov    %edi,%eax
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016f6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f9:	88 08                	mov    %cl,(%eax)
  8016fb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016fc:	39 f2                	cmp    %esi,%edx
  8016fe:	74 11                	je     801711 <strlcpy+0x40>
  801700:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801704:	42                   	inc    %edx
  801705:	84 c9                	test   %cl,%cl
  801707:	75 f0                	jne    8016f9 <strlcpy+0x28>
  801709:	eb 06                	jmp    801711 <strlcpy+0x40>
  80170b:	89 f8                	mov    %edi,%eax
  80170d:	eb 02                	jmp    801711 <strlcpy+0x40>
  80170f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801711:	c6 00 00             	movb   $0x0,(%eax)
  801714:	eb 02                	jmp    801718 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801716:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801718:	29 f8                	sub    %edi,%eax
}
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5f                   	pop    %edi
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801725:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801728:	8a 01                	mov    (%ecx),%al
  80172a:	84 c0                	test   %al,%al
  80172c:	74 10                	je     80173e <strcmp+0x1f>
  80172e:	3a 02                	cmp    (%edx),%al
  801730:	75 0c                	jne    80173e <strcmp+0x1f>
		p++, q++;
  801732:	41                   	inc    %ecx
  801733:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801734:	8a 01                	mov    (%ecx),%al
  801736:	84 c0                	test   %al,%al
  801738:	74 04                	je     80173e <strcmp+0x1f>
  80173a:	3a 02                	cmp    (%edx),%al
  80173c:	74 f4                	je     801732 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80173e:	0f b6 c0             	movzbl %al,%eax
  801741:	0f b6 12             	movzbl (%edx),%edx
  801744:	29 d0                	sub    %edx,%eax
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	8b 55 08             	mov    0x8(%ebp),%edx
  80174f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801752:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801755:	85 c0                	test   %eax,%eax
  801757:	74 1b                	je     801774 <strncmp+0x2c>
  801759:	8a 1a                	mov    (%edx),%bl
  80175b:	84 db                	test   %bl,%bl
  80175d:	74 24                	je     801783 <strncmp+0x3b>
  80175f:	3a 19                	cmp    (%ecx),%bl
  801761:	75 20                	jne    801783 <strncmp+0x3b>
  801763:	48                   	dec    %eax
  801764:	74 15                	je     80177b <strncmp+0x33>
		n--, p++, q++;
  801766:	42                   	inc    %edx
  801767:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801768:	8a 1a                	mov    (%edx),%bl
  80176a:	84 db                	test   %bl,%bl
  80176c:	74 15                	je     801783 <strncmp+0x3b>
  80176e:	3a 19                	cmp    (%ecx),%bl
  801770:	74 f1                	je     801763 <strncmp+0x1b>
  801772:	eb 0f                	jmp    801783 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
  801779:	eb 05                	jmp    801780 <strncmp+0x38>
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801780:	5b                   	pop    %ebx
  801781:	c9                   	leave  
  801782:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801783:	0f b6 02             	movzbl (%edx),%eax
  801786:	0f b6 11             	movzbl (%ecx),%edx
  801789:	29 d0                	sub    %edx,%eax
  80178b:	eb f3                	jmp    801780 <strncmp+0x38>

0080178d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801796:	8a 10                	mov    (%eax),%dl
  801798:	84 d2                	test   %dl,%dl
  80179a:	74 18                	je     8017b4 <strchr+0x27>
		if (*s == c)
  80179c:	38 ca                	cmp    %cl,%dl
  80179e:	75 06                	jne    8017a6 <strchr+0x19>
  8017a0:	eb 17                	jmp    8017b9 <strchr+0x2c>
  8017a2:	38 ca                	cmp    %cl,%dl
  8017a4:	74 13                	je     8017b9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017a6:	40                   	inc    %eax
  8017a7:	8a 10                	mov    (%eax),%dl
  8017a9:	84 d2                	test   %dl,%dl
  8017ab:	75 f5                	jne    8017a2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b2:	eb 05                	jmp    8017b9 <strchr+0x2c>
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017c4:	8a 10                	mov    (%eax),%dl
  8017c6:	84 d2                	test   %dl,%dl
  8017c8:	74 11                	je     8017db <strfind+0x20>
		if (*s == c)
  8017ca:	38 ca                	cmp    %cl,%dl
  8017cc:	75 06                	jne    8017d4 <strfind+0x19>
  8017ce:	eb 0b                	jmp    8017db <strfind+0x20>
  8017d0:	38 ca                	cmp    %cl,%dl
  8017d2:	74 07                	je     8017db <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017d4:	40                   	inc    %eax
  8017d5:	8a 10                	mov    (%eax),%dl
  8017d7:	84 d2                	test   %dl,%dl
  8017d9:	75 f5                	jne    8017d0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	57                   	push   %edi
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017ec:	85 c9                	test   %ecx,%ecx
  8017ee:	74 30                	je     801820 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017f6:	75 25                	jne    80181d <memset+0x40>
  8017f8:	f6 c1 03             	test   $0x3,%cl
  8017fb:	75 20                	jne    80181d <memset+0x40>
		c &= 0xFF;
  8017fd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801800:	89 d3                	mov    %edx,%ebx
  801802:	c1 e3 08             	shl    $0x8,%ebx
  801805:	89 d6                	mov    %edx,%esi
  801807:	c1 e6 18             	shl    $0x18,%esi
  80180a:	89 d0                	mov    %edx,%eax
  80180c:	c1 e0 10             	shl    $0x10,%eax
  80180f:	09 f0                	or     %esi,%eax
  801811:	09 d0                	or     %edx,%eax
  801813:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801815:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801818:	fc                   	cld    
  801819:	f3 ab                	rep stos %eax,%es:(%edi)
  80181b:	eb 03                	jmp    801820 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80181d:	fc                   	cld    
  80181e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801820:	89 f8                	mov    %edi,%eax
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	57                   	push   %edi
  80182b:	56                   	push   %esi
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801835:	39 c6                	cmp    %eax,%esi
  801837:	73 34                	jae    80186d <memmove+0x46>
  801839:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80183c:	39 d0                	cmp    %edx,%eax
  80183e:	73 2d                	jae    80186d <memmove+0x46>
		s += n;
		d += n;
  801840:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801843:	f6 c2 03             	test   $0x3,%dl
  801846:	75 1b                	jne    801863 <memmove+0x3c>
  801848:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184e:	75 13                	jne    801863 <memmove+0x3c>
  801850:	f6 c1 03             	test   $0x3,%cl
  801853:	75 0e                	jne    801863 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801855:	83 ef 04             	sub    $0x4,%edi
  801858:	8d 72 fc             	lea    -0x4(%edx),%esi
  80185b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80185e:	fd                   	std    
  80185f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801861:	eb 07                	jmp    80186a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801863:	4f                   	dec    %edi
  801864:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801867:	fd                   	std    
  801868:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80186a:	fc                   	cld    
  80186b:	eb 20                	jmp    80188d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801873:	75 13                	jne    801888 <memmove+0x61>
  801875:	a8 03                	test   $0x3,%al
  801877:	75 0f                	jne    801888 <memmove+0x61>
  801879:	f6 c1 03             	test   $0x3,%cl
  80187c:	75 0a                	jne    801888 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80187e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801881:	89 c7                	mov    %eax,%edi
  801883:	fc                   	cld    
  801884:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801886:	eb 05                	jmp    80188d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801888:	89 c7                	mov    %eax,%edi
  80188a:	fc                   	cld    
  80188b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80188d:	5e                   	pop    %esi
  80188e:	5f                   	pop    %edi
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801894:	ff 75 10             	pushl  0x10(%ebp)
  801897:	ff 75 0c             	pushl  0xc(%ebp)
  80189a:	ff 75 08             	pushl  0x8(%ebp)
  80189d:	e8 85 ff ff ff       	call   801827 <memmove>
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	57                   	push   %edi
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b3:	85 ff                	test   %edi,%edi
  8018b5:	74 32                	je     8018e9 <memcmp+0x45>
		if (*s1 != *s2)
  8018b7:	8a 03                	mov    (%ebx),%al
  8018b9:	8a 0e                	mov    (%esi),%cl
  8018bb:	38 c8                	cmp    %cl,%al
  8018bd:	74 19                	je     8018d8 <memcmp+0x34>
  8018bf:	eb 0d                	jmp    8018ce <memcmp+0x2a>
  8018c1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018c5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018c9:	42                   	inc    %edx
  8018ca:	38 c8                	cmp    %cl,%al
  8018cc:	74 10                	je     8018de <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018ce:	0f b6 c0             	movzbl %al,%eax
  8018d1:	0f b6 c9             	movzbl %cl,%ecx
  8018d4:	29 c8                	sub    %ecx,%eax
  8018d6:	eb 16                	jmp    8018ee <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d8:	4f                   	dec    %edi
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	39 fa                	cmp    %edi,%edx
  8018e0:	75 df                	jne    8018c1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e7:	eb 05                	jmp    8018ee <memcmp+0x4a>
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018fe:	39 d0                	cmp    %edx,%eax
  801900:	73 12                	jae    801914 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801902:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801905:	38 08                	cmp    %cl,(%eax)
  801907:	75 06                	jne    80190f <memfind+0x1c>
  801909:	eb 09                	jmp    801914 <memfind+0x21>
  80190b:	38 08                	cmp    %cl,(%eax)
  80190d:	74 05                	je     801914 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190f:	40                   	inc    %eax
  801910:	39 c2                	cmp    %eax,%edx
  801912:	77 f7                	ja     80190b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 55 08             	mov    0x8(%ebp),%edx
  80191f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801922:	eb 01                	jmp    801925 <strtol+0xf>
		s++;
  801924:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801925:	8a 02                	mov    (%edx),%al
  801927:	3c 20                	cmp    $0x20,%al
  801929:	74 f9                	je     801924 <strtol+0xe>
  80192b:	3c 09                	cmp    $0x9,%al
  80192d:	74 f5                	je     801924 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80192f:	3c 2b                	cmp    $0x2b,%al
  801931:	75 08                	jne    80193b <strtol+0x25>
		s++;
  801933:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801934:	bf 00 00 00 00       	mov    $0x0,%edi
  801939:	eb 13                	jmp    80194e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80193b:	3c 2d                	cmp    $0x2d,%al
  80193d:	75 0a                	jne    801949 <strtol+0x33>
		s++, neg = 1;
  80193f:	8d 52 01             	lea    0x1(%edx),%edx
  801942:	bf 01 00 00 00       	mov    $0x1,%edi
  801947:	eb 05                	jmp    80194e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801949:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80194e:	85 db                	test   %ebx,%ebx
  801950:	74 05                	je     801957 <strtol+0x41>
  801952:	83 fb 10             	cmp    $0x10,%ebx
  801955:	75 28                	jne    80197f <strtol+0x69>
  801957:	8a 02                	mov    (%edx),%al
  801959:	3c 30                	cmp    $0x30,%al
  80195b:	75 10                	jne    80196d <strtol+0x57>
  80195d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801961:	75 0a                	jne    80196d <strtol+0x57>
		s += 2, base = 16;
  801963:	83 c2 02             	add    $0x2,%edx
  801966:	bb 10 00 00 00       	mov    $0x10,%ebx
  80196b:	eb 12                	jmp    80197f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80196d:	85 db                	test   %ebx,%ebx
  80196f:	75 0e                	jne    80197f <strtol+0x69>
  801971:	3c 30                	cmp    $0x30,%al
  801973:	75 05                	jne    80197a <strtol+0x64>
		s++, base = 8;
  801975:	42                   	inc    %edx
  801976:	b3 08                	mov    $0x8,%bl
  801978:	eb 05                	jmp    80197f <strtol+0x69>
	else if (base == 0)
		base = 10;
  80197a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801986:	8a 0a                	mov    (%edx),%cl
  801988:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80198b:	80 fb 09             	cmp    $0x9,%bl
  80198e:	77 08                	ja     801998 <strtol+0x82>
			dig = *s - '0';
  801990:	0f be c9             	movsbl %cl,%ecx
  801993:	83 e9 30             	sub    $0x30,%ecx
  801996:	eb 1e                	jmp    8019b6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801998:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80199b:	80 fb 19             	cmp    $0x19,%bl
  80199e:	77 08                	ja     8019a8 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019a0:	0f be c9             	movsbl %cl,%ecx
  8019a3:	83 e9 57             	sub    $0x57,%ecx
  8019a6:	eb 0e                	jmp    8019b6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019a8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019ab:	80 fb 19             	cmp    $0x19,%bl
  8019ae:	77 13                	ja     8019c3 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019b0:	0f be c9             	movsbl %cl,%ecx
  8019b3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019b6:	39 f1                	cmp    %esi,%ecx
  8019b8:	7d 0d                	jge    8019c7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019ba:	42                   	inc    %edx
  8019bb:	0f af c6             	imul   %esi,%eax
  8019be:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019c1:	eb c3                	jmp    801986 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019c3:	89 c1                	mov    %eax,%ecx
  8019c5:	eb 02                	jmp    8019c9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019c7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019cd:	74 05                	je     8019d4 <strtol+0xbe>
		*endptr = (char *) s;
  8019cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019d2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019d4:	85 ff                	test   %edi,%edi
  8019d6:	74 04                	je     8019dc <strtol+0xc6>
  8019d8:	89 c8                	mov    %ecx,%eax
  8019da:	f7 d8                	neg    %eax
}
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    
  8019e1:	00 00                	add    %al,(%eax)
	...

008019e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	74 0e                	je     801a04 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	50                   	push   %eax
  8019fa:	e8 b8 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	eb 10                	jmp    801a14 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	68 00 00 c0 ee       	push   $0xeec00000
  801a0c:	e8 a6 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  801a11:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a14:	85 c0                	test   %eax,%eax
  801a16:	75 26                	jne    801a3e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a18:	85 f6                	test   %esi,%esi
  801a1a:	74 0a                	je     801a26 <ipc_recv+0x42>
  801a1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a21:	8b 40 74             	mov    0x74(%eax),%eax
  801a24:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a26:	85 db                	test   %ebx,%ebx
  801a28:	74 0a                	je     801a34 <ipc_recv+0x50>
  801a2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2f:	8b 40 78             	mov    0x78(%eax),%eax
  801a32:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a34:	a1 04 40 80 00       	mov    0x804004,%eax
  801a39:	8b 40 70             	mov    0x70(%eax),%eax
  801a3c:	eb 14                	jmp    801a52 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 06                	je     801a48 <ipc_recv+0x64>
  801a42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a48:	85 db                	test   %ebx,%ebx
  801a4a:	74 06                	je     801a52 <ipc_recv+0x6e>
  801a4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	57                   	push   %edi
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a68:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a6b:	85 db                	test   %ebx,%ebx
  801a6d:	75 25                	jne    801a94 <ipc_send+0x3b>
  801a6f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a74:	eb 1e                	jmp    801a94 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a79:	75 07                	jne    801a82 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a7b:	e8 15 e7 ff ff       	call   800195 <sys_yield>
  801a80:	eb 12                	jmp    801a94 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a82:	50                   	push   %eax
  801a83:	68 e0 21 80 00       	push   $0x8021e0
  801a88:	6a 43                	push   $0x43
  801a8a:	68 f3 21 80 00       	push   $0x8021f3
  801a8f:	e8 44 f5 ff ff       	call   800fd8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	57                   	push   %edi
  801a97:	ff 75 08             	pushl  0x8(%ebp)
  801a9a:	e8 f3 e7 ff ff       	call   800292 <sys_ipc_try_send>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	75 d0                	jne    801a76 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ab5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801abb:	74 22                	je     801adf <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801abd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ac2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	c1 e2 07             	shl    $0x7,%edx
  801ace:	29 ca                	sub    %ecx,%edx
  801ad0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad6:	8b 52 50             	mov    0x50(%edx),%edx
  801ad9:	39 da                	cmp    %ebx,%edx
  801adb:	75 1d                	jne    801afa <ipc_find_env+0x4c>
  801add:	eb 05                	jmp    801ae4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ae4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801aeb:	c1 e0 07             	shl    $0x7,%eax
  801aee:	29 d0                	sub    %edx,%eax
  801af0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801af5:	8b 40 40             	mov    0x40(%eax),%eax
  801af8:	eb 0c                	jmp    801b06 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	40                   	inc    %eax
  801afb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b00:	75 c0                	jne    801ac2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b02:	66 b8 00 00          	mov    $0x0,%ax
}
  801b06:	5b                   	pop    %ebx
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    
  801b09:	00 00                	add    %al,(%eax)
	...

00801b0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	c1 ea 16             	shr    $0x16,%edx
  801b17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b1e:	f6 c2 01             	test   $0x1,%dl
  801b21:	74 1e                	je     801b41 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b23:	c1 e8 0c             	shr    $0xc,%eax
  801b26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b2d:	a8 01                	test   $0x1,%al
  801b2f:	74 17                	je     801b48 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b31:	c1 e8 0c             	shr    $0xc,%eax
  801b34:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b3b:	ef 
  801b3c:	0f b7 c0             	movzwl %ax,%eax
  801b3f:	eb 0c                	jmp    801b4d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
  801b46:	eb 05                	jmp    801b4d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    
	...

00801b50 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	83 ec 10             	sub    $0x10,%esp
  801b58:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b5e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b64:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b67:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	75 2e                	jne    801b9c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b6e:	39 f1                	cmp    %esi,%ecx
  801b70:	77 5a                	ja     801bcc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b72:	85 c9                	test   %ecx,%ecx
  801b74:	75 0b                	jne    801b81 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b76:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7b:	31 d2                	xor    %edx,%edx
  801b7d:	f7 f1                	div    %ecx
  801b7f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b81:	31 d2                	xor    %edx,%edx
  801b83:	89 f0                	mov    %esi,%eax
  801b85:	f7 f1                	div    %ecx
  801b87:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b89:	89 f8                	mov    %edi,%eax
  801b8b:	f7 f1                	div    %ecx
  801b8d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b8f:	89 f8                	mov    %edi,%eax
  801b91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    
  801b9a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b9c:	39 f0                	cmp    %esi,%eax
  801b9e:	77 1c                	ja     801bbc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ba0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ba3:	83 f7 1f             	xor    $0x1f,%edi
  801ba6:	75 3c                	jne    801be4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba8:	39 f0                	cmp    %esi,%eax
  801baa:	0f 82 90 00 00 00    	jb     801c40 <__udivdi3+0xf0>
  801bb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bb3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bb6:	0f 86 84 00 00 00    	jbe    801c40 <__udivdi3+0xf0>
  801bbc:	31 f6                	xor    %esi,%esi
  801bbe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc0:	89 f8                	mov    %edi,%eax
  801bc2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    
  801bcb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bcc:	89 f2                	mov    %esi,%edx
  801bce:	89 f8                	mov    %edi,%eax
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 c7                	mov    %eax,%edi
  801bd4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd6:	89 f8                	mov    %edi,%eax
  801bd8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	c9                   	leave  
  801be0:	c3                   	ret    
  801be1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801be4:	89 f9                	mov    %edi,%ecx
  801be6:	d3 e0                	shl    %cl,%eax
  801be8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801beb:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf5:	88 c1                	mov    %al,%cl
  801bf7:	d3 ea                	shr    %cl,%edx
  801bf9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bfc:	09 ca                	or     %ecx,%edx
  801bfe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c04:	89 f9                	mov    %edi,%ecx
  801c06:	d3 e2                	shl    %cl,%edx
  801c08:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	88 c1                	mov    %al,%cl
  801c0f:	d3 ea                	shr    %cl,%edx
  801c11:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c14:	89 f2                	mov    %esi,%edx
  801c16:	89 f9                	mov    %edi,%ecx
  801c18:	d3 e2                	shl    %cl,%edx
  801c1a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c1d:	88 c1                	mov    %al,%cl
  801c1f:	d3 ee                	shr    %cl,%esi
  801c21:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c23:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c26:	89 f0                	mov    %esi,%eax
  801c28:	89 ca                	mov    %ecx,%edx
  801c2a:	f7 75 ec             	divl   -0x14(%ebp)
  801c2d:	89 d1                	mov    %edx,%ecx
  801c2f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c31:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c34:	39 d1                	cmp    %edx,%ecx
  801c36:	72 28                	jb     801c60 <__udivdi3+0x110>
  801c38:	74 1a                	je     801c54 <__udivdi3+0x104>
  801c3a:	89 f7                	mov    %esi,%edi
  801c3c:	31 f6                	xor    %esi,%esi
  801c3e:	eb 80                	jmp    801bc0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c40:	31 f6                	xor    %esi,%esi
  801c42:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c47:	89 f8                	mov    %edi,%eax
  801c49:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    
  801c52:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c57:	89 f9                	mov    %edi,%ecx
  801c59:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c5b:	39 c2                	cmp    %eax,%edx
  801c5d:	73 db                	jae    801c3a <__udivdi3+0xea>
  801c5f:	90                   	nop
		{
		  q0--;
  801c60:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c63:	31 f6                	xor    %esi,%esi
  801c65:	e9 56 ff ff ff       	jmp    801bc0 <__udivdi3+0x70>
	...

00801c6c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	57                   	push   %edi
  801c70:	56                   	push   %esi
  801c71:	83 ec 20             	sub    $0x20,%esp
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c83:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c89:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	75 15                	jne    801ca4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c8f:	39 f1                	cmp    %esi,%ecx
  801c91:	0f 86 99 00 00 00    	jbe    801d30 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c97:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c99:	89 d0                	mov    %edx,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c9d:	83 c4 20             	add    $0x20,%esp
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ca4:	39 f7                	cmp    %esi,%edi
  801ca6:	0f 87 a4 00 00 00    	ja     801d50 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801caf:	83 f0 1f             	xor    $0x1f,%eax
  801cb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cb5:	0f 84 a1 00 00 00    	je     801d5c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cbb:	89 f8                	mov    %edi,%eax
  801cbd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cc0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cc2:	bf 20 00 00 00       	mov    $0x20,%edi
  801cc7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ccd:	89 f9                	mov    %edi,%ecx
  801ccf:	d3 ea                	shr    %cl,%edx
  801cd1:	09 c2                	or     %eax,%edx
  801cd3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cdc:	d3 e0                	shl    %cl,%eax
  801cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ce1:	89 f2                	mov    %esi,%edx
  801ce3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ce8:	d3 e0                	shl    %cl,%eax
  801cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	d3 e8                	shr    %cl,%eax
  801cf4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cf6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cf8:	89 f2                	mov    %esi,%edx
  801cfa:	f7 75 f0             	divl   -0x10(%ebp)
  801cfd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cff:	f7 65 f4             	mull   -0xc(%ebp)
  801d02:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d05:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d07:	39 d6                	cmp    %edx,%esi
  801d09:	72 71                	jb     801d7c <__umoddi3+0x110>
  801d0b:	74 7f                	je     801d8c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d10:	29 c8                	sub    %ecx,%eax
  801d12:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d14:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d17:	d3 e8                	shr    %cl,%eax
  801d19:	89 f2                	mov    %esi,%edx
  801d1b:	89 f9                	mov    %edi,%ecx
  801d1d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d1f:	09 d0                	or     %edx,%eax
  801d21:	89 f2                	mov    %esi,%edx
  801d23:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d26:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d28:	83 c4 20             	add    $0x20,%esp
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d30:	85 c9                	test   %ecx,%ecx
  801d32:	75 0b                	jne    801d3f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d34:	b8 01 00 00 00       	mov    $0x1,%eax
  801d39:	31 d2                	xor    %edx,%edx
  801d3b:	f7 f1                	div    %ecx
  801d3d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d3f:	89 f0                	mov    %esi,%eax
  801d41:	31 d2                	xor    %edx,%edx
  801d43:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d48:	f7 f1                	div    %ecx
  801d4a:	e9 4a ff ff ff       	jmp    801c99 <__umoddi3+0x2d>
  801d4f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d52:	83 c4 20             	add    $0x20,%esp
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    
  801d59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d5c:	39 f7                	cmp    %esi,%edi
  801d5e:	72 05                	jb     801d65 <__umoddi3+0xf9>
  801d60:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d63:	77 0c                	ja     801d71 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6a:	29 c8                	sub    %ecx,%eax
  801d6c:	19 fa                	sbb    %edi,%edx
  801d6e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d7c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d7f:	89 c1                	mov    %eax,%ecx
  801d81:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d84:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d87:	eb 84                	jmp    801d0d <__umoddi3+0xa1>
  801d89:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d8f:	72 eb                	jb     801d7c <__umoddi3+0x110>
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	e9 75 ff ff ff       	jmp    801d0d <__umoddi3+0xa1>
