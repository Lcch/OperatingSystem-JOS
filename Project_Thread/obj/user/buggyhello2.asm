
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 30 80 00    	pushl  0x803000
  800045:	e8 bb 00 00 00       	call   800105 <sys_cputs>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005b:	e8 11 01 00 00       	call   800171 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 07             	shl    $0x7,%edx
  80006a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 f6                	test   %esi,%esi
  800078:	7e 07                	jle    800081 <libmain+0x31>
		binaryname = argv[0];
  80007a:	8b 03                	mov    (%ebx),%eax
  80007c:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	53                   	push   %ebx
  800085:	56                   	push   %esi
  800086:	e8 a9 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0c 00 00 00       	call   80009c <exit>
  800090:	83 c4 10             	add    $0x10,%esp
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	c9                   	leave  
  800099:	c3                   	ret    
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
  8000a2:	e8 cb 04 00 00       	call   800572 <close_all>
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
  8000ea:	68 f8 1d 80 00       	push   $0x801df8
  8000ef:	6a 42                	push   $0x42
  8000f1:	68 15 1e 80 00       	push   $0x801e15
  8000f6:	e8 21 0f 00 00       	call   80101c <_panic>

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
} 
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800327:	6a 00                	push   $0x0
  800329:	6a 00                	push   $0x0
  80032b:	6a 00                	push   $0x0
  80032d:	6a 00                	push   $0x0
  80032f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	b8 11 00 00 00       	mov    $0x11,%eax
  80033c:	e8 77 fd ff ff       	call   8000b8 <syscall>
}
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800349:	6a 00                	push   $0x0
  80034b:	6a 00                	push   $0x0
  80034d:	6a 00                	push   $0x0
  80034f:	6a 00                	push   $0x0
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	b8 10 00 00 00       	mov    $0x10,%eax
  800360:	e8 53 fd ff ff       	call   8000b8 <syscall>
  800365:	c9                   	leave  
  800366:	c3                   	ret    
	...

00800368 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	05 00 00 00 30       	add    $0x30000000,%eax
  800373:	c1 e8 0c             	shr    $0xc,%eax
}
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 e5 ff ff ff       	call   800368 <fd2num>
  800383:	83 c4 04             	add    $0x4,%esp
  800386:	05 20 00 0d 00       	add    $0xd0020,%eax
  80038b:	c1 e0 0c             	shl    $0xc,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80039c:	a8 01                	test   $0x1,%al
  80039e:	74 34                	je     8003d4 <fd_alloc+0x44>
  8003a0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003a5:	a8 01                	test   $0x1,%al
  8003a7:	74 32                	je     8003db <fd_alloc+0x4b>
  8003a9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003ae:	89 c1                	mov    %eax,%ecx
  8003b0:	89 c2                	mov    %eax,%edx
  8003b2:	c1 ea 16             	shr    $0x16,%edx
  8003b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003bc:	f6 c2 01             	test   $0x1,%dl
  8003bf:	74 1f                	je     8003e0 <fd_alloc+0x50>
  8003c1:	89 c2                	mov    %eax,%edx
  8003c3:	c1 ea 0c             	shr    $0xc,%edx
  8003c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003cd:	f6 c2 01             	test   $0x1,%dl
  8003d0:	75 17                	jne    8003e9 <fd_alloc+0x59>
  8003d2:	eb 0c                	jmp    8003e0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003d4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003d9:	eb 05                	jmp    8003e0 <fd_alloc+0x50>
  8003db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003e0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e7:	eb 17                	jmp    800400 <fd_alloc+0x70>
  8003e9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f3:	75 b9                	jne    8003ae <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800400:	5b                   	pop    %ebx
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800409:	83 f8 1f             	cmp    $0x1f,%eax
  80040c:	77 36                	ja     800444 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80040e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800413:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800416:	89 c2                	mov    %eax,%edx
  800418:	c1 ea 16             	shr    $0x16,%edx
  80041b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800422:	f6 c2 01             	test   $0x1,%dl
  800425:	74 24                	je     80044b <fd_lookup+0x48>
  800427:	89 c2                	mov    %eax,%edx
  800429:	c1 ea 0c             	shr    $0xc,%edx
  80042c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800433:	f6 c2 01             	test   $0x1,%dl
  800436:	74 1a                	je     800452 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800438:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043b:	89 02                	mov    %eax,(%edx)
	return 0;
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	eb 13                	jmp    800457 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800449:	eb 0c                	jmp    800457 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800450:	eb 05                	jmp    800457 <fd_lookup+0x54>
  800452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800457:	c9                   	leave  
  800458:	c3                   	ret    

00800459 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	53                   	push   %ebx
  80045d:	83 ec 04             	sub    $0x4,%esp
  800460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  80046c:	74 0d                	je     80047b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	eb 14                	jmp    800489 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800475:	39 0a                	cmp    %ecx,(%edx)
  800477:	75 10                	jne    800489 <dev_lookup+0x30>
  800479:	eb 05                	jmp    800480 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047b:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800480:	89 13                	mov    %edx,(%ebx)
			return 0;
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	eb 31                	jmp    8004ba <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800489:	40                   	inc    %eax
  80048a:	8b 14 85 a0 1e 80 00 	mov    0x801ea0(,%eax,4),%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	75 e0                	jne    800475 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800495:	a1 04 40 80 00       	mov    0x804004,%eax
  80049a:	8b 40 48             	mov    0x48(%eax),%eax
  80049d:	83 ec 04             	sub    $0x4,%esp
  8004a0:	51                   	push   %ecx
  8004a1:	50                   	push   %eax
  8004a2:	68 24 1e 80 00       	push   $0x801e24
  8004a7:	e8 48 0c 00 00       	call   8010f4 <cprintf>
	*dev = 0;
  8004ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bd:	c9                   	leave  
  8004be:	c3                   	ret    

008004bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 20             	sub    $0x20,%esp
  8004c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ca:	8a 45 0c             	mov    0xc(%ebp),%al
  8004cd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d0:	56                   	push   %esi
  8004d1:	e8 92 fe ff ff       	call   800368 <fd2num>
  8004d6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004d9:	89 14 24             	mov    %edx,(%esp)
  8004dc:	50                   	push   %eax
  8004dd:	e8 21 ff ff ff       	call   800403 <fd_lookup>
  8004e2:	89 c3                	mov    %eax,%ebx
  8004e4:	83 c4 08             	add    $0x8,%esp
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	78 05                	js     8004f0 <fd_close+0x31>
	    || fd != fd2)
  8004eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ee:	74 0d                	je     8004fd <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004f0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004f4:	75 48                	jne    80053e <fd_close+0x7f>
  8004f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fb:	eb 41                	jmp    80053e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	ff 36                	pushl  (%esi)
  800506:	e8 4e ff ff ff       	call   800459 <dev_lookup>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1c                	js     800530 <fd_close+0x71>
		if (dev->dev_close)
  800514:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800517:	8b 40 10             	mov    0x10(%eax),%eax
  80051a:	85 c0                	test   %eax,%eax
  80051c:	74 0d                	je     80052b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	56                   	push   %esi
  800522:	ff d0                	call   *%eax
  800524:	89 c3                	mov    %eax,%ebx
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	eb 05                	jmp    800530 <fd_close+0x71>
		else
			r = 0;
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	6a 00                	push   $0x0
  800536:	e8 cb fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  80053b:	83 c4 10             	add    $0x10,%esp
}
  80053e:	89 d8                	mov    %ebx,%eax
  800540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800543:	5b                   	pop    %ebx
  800544:	5e                   	pop    %esi
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 aa fe ff ff       	call   800403 <fd_lookup>
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	78 10                	js     800570 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	6a 01                	push   $0x1
  800565:	ff 75 f4             	pushl  -0xc(%ebp)
  800568:	e8 52 ff ff ff       	call   8004bf <fd_close>
  80056d:	83 c4 10             	add    $0x10,%esp
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    

00800572 <close_all>:

void
close_all(void)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	53                   	push   %ebx
  800576:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800579:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	53                   	push   %ebx
  800582:	e8 c0 ff ff ff       	call   800547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	43                   	inc    %ebx
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	83 fb 20             	cmp    $0x20,%ebx
  80058e:	75 ee                	jne    80057e <close_all+0xc>
		close(i);
}
  800590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	57                   	push   %edi
  800599:	56                   	push   %esi
  80059a:	53                   	push   %ebx
  80059b:	83 ec 2c             	sub    $0x2c,%esp
  80059e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a4:	50                   	push   %eax
  8005a5:	ff 75 08             	pushl  0x8(%ebp)
  8005a8:	e8 56 fe ff ff       	call   800403 <fd_lookup>
  8005ad:	89 c3                	mov    %eax,%ebx
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	0f 88 c0 00 00 00    	js     80067a <dup+0xe5>
		return r;
	close(newfdnum);
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	57                   	push   %edi
  8005be:	e8 84 ff ff ff       	call   800547 <close>

	newfd = INDEX2FD(newfdnum);
  8005c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005cc:	83 c4 04             	add    $0x4,%esp
  8005cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d2:	e8 a1 fd ff ff       	call   800378 <fd2data>
  8005d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005d9:	89 34 24             	mov    %esi,(%esp)
  8005dc:	e8 97 fd ff ff       	call   800378 <fd2data>
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e7:	89 d8                	mov    %ebx,%eax
  8005e9:	c1 e8 16             	shr    $0x16,%eax
  8005ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f3:	a8 01                	test   $0x1,%al
  8005f5:	74 37                	je     80062e <dup+0x99>
  8005f7:	89 d8                	mov    %ebx,%eax
  8005f9:	c1 e8 0c             	shr    $0xc,%eax
  8005fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800603:	f6 c2 01             	test   $0x1,%dl
  800606:	74 26                	je     80062e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800608:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	25 07 0e 00 00       	and    $0xe07,%eax
  800617:	50                   	push   %eax
  800618:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061b:	6a 00                	push   $0x0
  80061d:	53                   	push   %ebx
  80061e:	6a 00                	push   $0x0
  800620:	e8 bb fb ff ff       	call   8001e0 <sys_page_map>
  800625:	89 c3                	mov    %eax,%ebx
  800627:	83 c4 20             	add    $0x20,%esp
  80062a:	85 c0                	test   %eax,%eax
  80062c:	78 2d                	js     80065b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800631:	89 c2                	mov    %eax,%edx
  800633:	c1 ea 0c             	shr    $0xc,%edx
  800636:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800646:	52                   	push   %edx
  800647:	56                   	push   %esi
  800648:	6a 00                	push   $0x0
  80064a:	50                   	push   %eax
  80064b:	6a 00                	push   $0x0
  80064d:	e8 8e fb ff ff       	call   8001e0 <sys_page_map>
  800652:	89 c3                	mov    %eax,%ebx
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	85 c0                	test   %eax,%eax
  800659:	79 1d                	jns    800678 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	56                   	push   %esi
  80065f:	6a 00                	push   $0x0
  800661:	e8 a0 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066c:	6a 00                	push   $0x0
  80066e:	e8 93 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb 02                	jmp    80067a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800678:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80067a:	89 d8                	mov    %ebx,%eax
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	c9                   	leave  
  800683:	c3                   	ret    

00800684 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	53                   	push   %ebx
  800688:	83 ec 14             	sub    $0x14,%esp
  80068b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	53                   	push   %ebx
  800693:	e8 6b fd ff ff       	call   800403 <fd_lookup>
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 67                	js     800706 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a9:	ff 30                	pushl  (%eax)
  8006ab:	e8 a9 fd ff ff       	call   800459 <dev_lookup>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	78 4f                	js     800706 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ba:	8b 50 08             	mov    0x8(%eax),%edx
  8006bd:	83 e2 03             	and    $0x3,%edx
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	75 21                	jne    8006e6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ca:	8b 40 48             	mov    0x48(%eax),%eax
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	50                   	push   %eax
  8006d2:	68 65 1e 80 00       	push   $0x801e65
  8006d7:	e8 18 0a 00 00       	call   8010f4 <cprintf>
		return -E_INVAL;
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e4:	eb 20                	jmp    800706 <read+0x82>
	}
	if (!dev->dev_read)
  8006e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e9:	8b 52 08             	mov    0x8(%edx),%edx
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	74 11                	je     800701 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	50                   	push   %eax
  8006fa:	ff d2                	call   *%edx
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 05                	jmp    800706 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800701:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	57                   	push   %edi
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	8b 7d 08             	mov    0x8(%ebp),%edi
  800717:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071a:	85 f6                	test   %esi,%esi
  80071c:	74 31                	je     80074f <readn+0x44>
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800728:	83 ec 04             	sub    $0x4,%esp
  80072b:	89 f2                	mov    %esi,%edx
  80072d:	29 c2                	sub    %eax,%edx
  80072f:	52                   	push   %edx
  800730:	03 45 0c             	add    0xc(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	57                   	push   %edi
  800735:	e8 4a ff ff ff       	call   800684 <read>
		if (m < 0)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 17                	js     800758 <readn+0x4d>
			return m;
		if (m == 0)
  800741:	85 c0                	test   %eax,%eax
  800743:	74 11                	je     800756 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800745:	01 c3                	add    %eax,%ebx
  800747:	89 d8                	mov    %ebx,%eax
  800749:	39 f3                	cmp    %esi,%ebx
  80074b:	72 db                	jb     800728 <readn+0x1d>
  80074d:	eb 09                	jmp    800758 <readn+0x4d>
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 02                	jmp    800758 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800756:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800758:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075b:	5b                   	pop    %ebx
  80075c:	5e                   	pop    %esi
  80075d:	5f                   	pop    %edi
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	83 ec 14             	sub    $0x14,%esp
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80076a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	53                   	push   %ebx
  80076f:	e8 8f fc ff ff       	call   800403 <fd_lookup>
  800774:	83 c4 08             	add    $0x8,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 62                	js     8007dd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800785:	ff 30                	pushl  (%eax)
  800787:	e8 cd fc ff ff       	call   800459 <dev_lookup>
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	85 c0                	test   %eax,%eax
  800791:	78 4a                	js     8007dd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80079a:	75 21                	jne    8007bd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80079c:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a1:	8b 40 48             	mov    0x48(%eax),%eax
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	50                   	push   %eax
  8007a9:	68 81 1e 80 00       	push   $0x801e81
  8007ae:	e8 41 09 00 00       	call   8010f4 <cprintf>
		return -E_INVAL;
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bb:	eb 20                	jmp    8007dd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 11                	je     8007d8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c7:	83 ec 04             	sub    $0x4,%esp
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	50                   	push   %eax
  8007d1:	ff d2                	call   *%edx
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	eb 05                	jmp    8007dd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 0f fc ff ff       	call   800403 <fd_lookup>
  8007f4:	83 c4 08             	add    $0x8,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 0e                	js     800809 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	83 ec 14             	sub    $0x14,%esp
  800812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800815:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	53                   	push   %ebx
  80081a:	e8 e4 fb ff ff       	call   800403 <fd_lookup>
  80081f:	83 c4 08             	add    $0x8,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 5f                	js     800885 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082c:	50                   	push   %eax
  80082d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800830:	ff 30                	pushl  (%eax)
  800832:	e8 22 fc ff ff       	call   800459 <dev_lookup>
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 47                	js     800885 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800841:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800845:	75 21                	jne    800868 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800847:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80084c:	8b 40 48             	mov    0x48(%eax),%eax
  80084f:	83 ec 04             	sub    $0x4,%esp
  800852:	53                   	push   %ebx
  800853:	50                   	push   %eax
  800854:	68 44 1e 80 00       	push   $0x801e44
  800859:	e8 96 08 00 00       	call   8010f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800866:	eb 1d                	jmp    800885 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80086b:	8b 52 18             	mov    0x18(%edx),%edx
  80086e:	85 d2                	test   %edx,%edx
  800870:	74 0e                	je     800880 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	50                   	push   %eax
  800879:	ff d2                	call   *%edx
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	eb 05                	jmp    800885 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800880:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 14             	sub    $0x14,%esp
  800891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800894:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 63 fb ff ff       	call   800403 <fd_lookup>
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	78 52                	js     8008f9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b1:	ff 30                	pushl  (%eax)
  8008b3:	e8 a1 fb ff ff       	call   800459 <dev_lookup>
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	78 3a                	js     8008f9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c6:	74 2c                	je     8008f4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008cb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d2:	00 00 00 
	stat->st_isdir = 0;
  8008d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008dc:	00 00 00 
	stat->st_dev = dev;
  8008df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ec:	ff 50 14             	call   *0x14(%eax)
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb 05                	jmp    8008f9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	6a 00                	push   $0x0
  800908:	ff 75 08             	pushl  0x8(%ebp)
  80090b:	e8 78 01 00 00       	call   800a88 <open>
  800910:	89 c3                	mov    %eax,%ebx
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	85 c0                	test   %eax,%eax
  800917:	78 1b                	js     800934 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	50                   	push   %eax
  800920:	e8 65 ff ff ff       	call   80088a <fstat>
  800925:	89 c6                	mov    %eax,%esi
	close(fd);
  800927:	89 1c 24             	mov    %ebx,(%esp)
  80092a:	e8 18 fc ff ff       	call   800547 <close>
	return r;
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	89 f3                	mov    %esi,%ebx
}
  800934:	89 d8                	mov    %ebx,%eax
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    
  80093d:	00 00                	add    %al,(%eax)
	...

00800940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	89 c3                	mov    %eax,%ebx
  800947:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800949:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800950:	75 12                	jne    800964 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 96 11 00 00       	call   801af2 <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800964:	6a 07                	push   $0x7
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	53                   	push   %ebx
  80096c:	ff 35 00 40 80 00    	pushl  0x804000
  800972:	e8 26 11 00 00       	call   801a9d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800977:	83 c4 0c             	add    $0xc,%esp
  80097a:	6a 00                	push   $0x0
  80097c:	56                   	push   %esi
  80097d:	6a 00                	push   $0x0
  80097f:	e8 a4 10 00 00       	call   801a28 <ipc_recv>
}
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	83 ec 04             	sub    $0x4,%esp
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 40 0c             	mov    0xc(%eax),%eax
  80099b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8009a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009aa:	e8 91 ff ff ff       	call   800940 <fsipc>
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	78 2c                	js     8009df <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	68 00 50 80 00       	push   $0x805000
  8009bb:	53                   	push   %ebx
  8009bc:	e8 e9 0c 00 00       	call   8016aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cc:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d7:	83 c4 10             	add    $0x10,%esp
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ff:	e8 3c ff ff ff       	call   800940 <fsipc>
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 40 0c             	mov    0xc(%eax),%eax
  800a14:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a19:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a24:	b8 03 00 00 00       	mov    $0x3,%eax
  800a29:	e8 12 ff ff ff       	call   800940 <fsipc>
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	85 c0                	test   %eax,%eax
  800a32:	78 4b                	js     800a7f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 16                	jae    800a4e <devfile_read+0x48>
  800a38:	68 b0 1e 80 00       	push   $0x801eb0
  800a3d:	68 b7 1e 80 00       	push   $0x801eb7
  800a42:	6a 7d                	push   $0x7d
  800a44:	68 cc 1e 80 00       	push   $0x801ecc
  800a49:	e8 ce 05 00 00       	call   80101c <_panic>
	assert(r <= PGSIZE);
  800a4e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a53:	7e 16                	jle    800a6b <devfile_read+0x65>
  800a55:	68 d7 1e 80 00       	push   $0x801ed7
  800a5a:	68 b7 1e 80 00       	push   $0x801eb7
  800a5f:	6a 7e                	push   $0x7e
  800a61:	68 cc 1e 80 00       	push   $0x801ecc
  800a66:	e8 b1 05 00 00       	call   80101c <_panic>
	memmove(buf, &fsipcbuf, r);
  800a6b:	83 ec 04             	sub    $0x4,%esp
  800a6e:	50                   	push   %eax
  800a6f:	68 00 50 80 00       	push   $0x805000
  800a74:	ff 75 0c             	pushl  0xc(%ebp)
  800a77:	e8 ef 0d 00 00       	call   80186b <memmove>
	return r;
  800a7c:	83 c4 10             	add    $0x10,%esp
}
  800a7f:	89 d8                	mov    %ebx,%eax
  800a81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	83 ec 1c             	sub    $0x1c,%esp
  800a90:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a93:	56                   	push   %esi
  800a94:	e8 bf 0b 00 00       	call   801658 <strlen>
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa1:	7f 65                	jg     800b08 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa3:	83 ec 0c             	sub    $0xc,%esp
  800aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa9:	50                   	push   %eax
  800aaa:	e8 e1 f8 ff ff       	call   800390 <fd_alloc>
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	78 55                	js     800b0d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	56                   	push   %esi
  800abc:	68 00 50 80 00       	push   $0x805000
  800ac1:	e8 e4 0b 00 00       	call   8016aa <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	e8 65 fe ff ff       	call   800940 <fsipc>
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	79 12                	jns    800af6 <open+0x6e>
		fd_close(fd, 0);
  800ae4:	83 ec 08             	sub    $0x8,%esp
  800ae7:	6a 00                	push   $0x0
  800ae9:	ff 75 f4             	pushl  -0xc(%ebp)
  800aec:	e8 ce f9 ff ff       	call   8004bf <fd_close>
		return r;
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	eb 17                	jmp    800b0d <open+0x85>
	}

	return fd2num(fd);
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	ff 75 f4             	pushl  -0xc(%ebp)
  800afc:	e8 67 f8 ff ff       	call   800368 <fd2num>
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 05                	jmp    800b0d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b08:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b0d:	89 d8                	mov    %ebx,%eax
  800b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    
	...

00800b18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	ff 75 08             	pushl  0x8(%ebp)
  800b26:	e8 4d f8 ff ff       	call   800378 <fd2data>
  800b2b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b2d:	83 c4 08             	add    $0x8,%esp
  800b30:	68 e3 1e 80 00       	push   $0x801ee3
  800b35:	56                   	push   %esi
  800b36:	e8 6f 0b 00 00       	call   8016aa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b3b:	8b 43 04             	mov    0x4(%ebx),%eax
  800b3e:	2b 03                	sub    (%ebx),%eax
  800b40:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b46:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b4d:	00 00 00 
	stat->st_dev = &devpipe;
  800b50:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800b57:	30 80 00 
	return 0;
}
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b70:	53                   	push   %ebx
  800b71:	6a 00                	push   $0x0
  800b73:	e8 8e f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b78:	89 1c 24             	mov    %ebx,(%esp)
  800b7b:	e8 f8 f7 ff ff       	call   800378 <fd2data>
  800b80:	83 c4 08             	add    $0x8,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 00                	push   $0x0
  800b86:	e8 7b f6 ff ff       	call   800206 <sys_page_unmap>
}
  800b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 1c             	sub    $0x1c,%esp
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b9e:	a1 04 40 80 00       	mov    0x804004,%eax
  800ba3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	57                   	push   %edi
  800baa:	e8 91 0f 00 00       	call   801b40 <pageref>
  800baf:	89 c6                	mov    %eax,%esi
  800bb1:	83 c4 04             	add    $0x4,%esp
  800bb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bb7:	e8 84 0f 00 00       	call   801b40 <pageref>
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	39 c6                	cmp    %eax,%esi
  800bc1:	0f 94 c0             	sete   %al
  800bc4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bc7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bcd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd0:	39 cb                	cmp    %ecx,%ebx
  800bd2:	75 08                	jne    800bdc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bdc:	83 f8 01             	cmp    $0x1,%eax
  800bdf:	75 bd                	jne    800b9e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be1:	8b 42 58             	mov    0x58(%edx),%eax
  800be4:	6a 01                	push   $0x1
  800be6:	50                   	push   %eax
  800be7:	53                   	push   %ebx
  800be8:	68 ea 1e 80 00       	push   $0x801eea
  800bed:	e8 02 05 00 00       	call   8010f4 <cprintf>
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	eb a7                	jmp    800b9e <_pipeisclosed+0xe>

00800bf7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 28             	sub    $0x28,%esp
  800c00:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c03:	56                   	push   %esi
  800c04:	e8 6f f7 ff ff       	call   800378 <fd2data>
  800c09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c0b:	83 c4 10             	add    $0x10,%esp
  800c0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c12:	75 4a                	jne    800c5e <devpipe_write+0x67>
  800c14:	bf 00 00 00 00       	mov    $0x0,%edi
  800c19:	eb 56                	jmp    800c71 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c1b:	89 da                	mov    %ebx,%edx
  800c1d:	89 f0                	mov    %esi,%eax
  800c1f:	e8 6c ff ff ff       	call   800b90 <_pipeisclosed>
  800c24:	85 c0                	test   %eax,%eax
  800c26:	75 4d                	jne    800c75 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c28:	e8 68 f5 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c2d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c30:	8b 13                	mov    (%ebx),%edx
  800c32:	83 c2 20             	add    $0x20,%edx
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 e2                	jae    800c1b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c41:	79 05                	jns    800c48 <devpipe_write+0x51>
  800c43:	4a                   	dec    %edx
  800c44:	83 ca e0             	or     $0xffffffe0,%edx
  800c47:	42                   	inc    %edx
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c52:	40                   	inc    %eax
  800c53:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c56:	47                   	inc    %edi
  800c57:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c5a:	77 07                	ja     800c63 <devpipe_write+0x6c>
  800c5c:	eb 13                	jmp    800c71 <devpipe_write+0x7a>
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c63:	8b 43 04             	mov    0x4(%ebx),%eax
  800c66:	8b 13                	mov    (%ebx),%edx
  800c68:	83 c2 20             	add    $0x20,%edx
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	73 ac                	jae    800c1b <devpipe_write+0x24>
  800c6f:	eb c8                	jmp    800c39 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c71:	89 f8                	mov    %edi,%eax
  800c73:	eb 05                	jmp    800c7a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 18             	sub    $0x18,%esp
  800c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c8e:	57                   	push   %edi
  800c8f:	e8 e4 f6 ff ff       	call   800378 <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c9d:	75 44                	jne    800ce3 <devpipe_read+0x61>
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	eb 4f                	jmp    800cf5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800ca6:	89 f0                	mov    %esi,%eax
  800ca8:	eb 54                	jmp    800cfe <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800caa:	89 da                	mov    %ebx,%edx
  800cac:	89 f8                	mov    %edi,%eax
  800cae:	e8 dd fe ff ff       	call   800b90 <_pipeisclosed>
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	75 42                	jne    800cf9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cb7:	e8 d9 f4 ff ff       	call   800195 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cbc:	8b 03                	mov    (%ebx),%eax
  800cbe:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc1:	74 e7                	je     800caa <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cc8:	79 05                	jns    800ccf <devpipe_read+0x4d>
  800cca:	48                   	dec    %eax
  800ccb:	83 c8 e0             	or     $0xffffffe0,%eax
  800cce:	40                   	inc    %eax
  800ccf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cd9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdb:	46                   	inc    %esi
  800cdc:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cdf:	77 07                	ja     800ce8 <devpipe_read+0x66>
  800ce1:	eb 12                	jmp    800cf5 <devpipe_read+0x73>
  800ce3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800ce8:	8b 03                	mov    (%ebx),%eax
  800cea:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ced:	75 d4                	jne    800cc3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cef:	85 f6                	test   %esi,%esi
  800cf1:	75 b3                	jne    800ca6 <devpipe_read+0x24>
  800cf3:	eb b5                	jmp    800caa <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf5:	89 f0                	mov    %esi,%eax
  800cf7:	eb 05                	jmp    800cfe <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 28             	sub    $0x28,%esp
  800d0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d15:	50                   	push   %eax
  800d16:	e8 75 f6 ff ff       	call   800390 <fd_alloc>
  800d1b:	89 c3                	mov    %eax,%ebx
  800d1d:	83 c4 10             	add    $0x10,%esp
  800d20:	85 c0                	test   %eax,%eax
  800d22:	0f 88 24 01 00 00    	js     800e4c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d28:	83 ec 04             	sub    $0x4,%esp
  800d2b:	68 07 04 00 00       	push   $0x407
  800d30:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d33:	6a 00                	push   $0x0
  800d35:	e8 82 f4 ff ff       	call   8001bc <sys_page_alloc>
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	0f 88 05 01 00 00    	js     800e4c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d4d:	50                   	push   %eax
  800d4e:	e8 3d f6 ff ff       	call   800390 <fd_alloc>
  800d53:	89 c3                	mov    %eax,%ebx
  800d55:	83 c4 10             	add    $0x10,%esp
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	0f 88 dc 00 00 00    	js     800e3c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 07 04 00 00       	push   $0x407
  800d68:	ff 75 e0             	pushl  -0x20(%ebp)
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 4a f4 ff ff       	call   8001bc <sys_page_alloc>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 bd 00 00 00    	js     800e3c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d85:	e8 ee f5 ff ff       	call   800378 <fd2data>
  800d8a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8c:	83 c4 0c             	add    $0xc,%esp
  800d8f:	68 07 04 00 00       	push   $0x407
  800d94:	50                   	push   %eax
  800d95:	6a 00                	push   $0x0
  800d97:	e8 20 f4 ff ff       	call   8001bc <sys_page_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 83 00 00 00    	js     800e2c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	ff 75 e0             	pushl  -0x20(%ebp)
  800daf:	e8 c4 f5 ff ff       	call   800378 <fd2data>
  800db4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dbb:	50                   	push   %eax
  800dbc:	6a 00                	push   $0x0
  800dbe:	56                   	push   %esi
  800dbf:	6a 00                	push   $0x0
  800dc1:	e8 1a f4 ff ff       	call   8001e0 <sys_page_map>
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	83 c4 20             	add    $0x20,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	78 4f                	js     800e1e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dcf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ddd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800dea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ded:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800def:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800df2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dff:	e8 64 f5 ff ff       	call   800368 <fd2num>
  800e04:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800e06:	83 c4 04             	add    $0x4,%esp
  800e09:	ff 75 e0             	pushl  -0x20(%ebp)
  800e0c:	e8 57 f5 ff ff       	call   800368 <fd2num>
  800e11:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	eb 2e                	jmp    800e4c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	56                   	push   %esi
  800e22:	6a 00                	push   $0x0
  800e24:	e8 dd f3 ff ff       	call   800206 <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	ff 75 e0             	pushl  -0x20(%ebp)
  800e32:	6a 00                	push   $0x0
  800e34:	e8 cd f3 ff ff       	call   800206 <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e42:	6a 00                	push   $0x0
  800e44:	e8 bd f3 ff ff       	call   800206 <sys_page_unmap>
  800e49:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5f:	50                   	push   %eax
  800e60:	ff 75 08             	pushl  0x8(%ebp)
  800e63:	e8 9b f5 ff ff       	call   800403 <fd_lookup>
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	78 18                	js     800e87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	ff 75 f4             	pushl  -0xc(%ebp)
  800e75:	e8 fe f4 ff ff       	call   800378 <fd2data>
	return _pipeisclosed(fd, p);
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7f:	e8 0c fd ff ff       	call   800b90 <_pipeisclosed>
  800e84:	83 c4 10             	add    $0x10,%esp
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    
  800e89:	00 00                	add    %al,(%eax)
	...

00800e8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e9c:	68 02 1f 80 00       	push   $0x801f02
  800ea1:	ff 75 0c             	pushl  0xc(%ebp)
  800ea4:	e8 01 08 00 00       	call   8016aa <strcpy>
	return 0;
}
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ec0:	74 45                	je     800f07 <devcons_write+0x57>
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ecc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ed7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eda:	76 05                	jbe    800ee1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800edc:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	53                   	push   %ebx
  800ee5:	03 45 0c             	add    0xc(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	57                   	push   %edi
  800eea:	e8 7c 09 00 00       	call   80186b <memmove>
		sys_cputs(buf, m);
  800eef:	83 c4 08             	add    $0x8,%esp
  800ef2:	53                   	push   %ebx
  800ef3:	57                   	push   %edi
  800ef4:	e8 0c f2 ff ff       	call   800105 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef9:	01 de                	add    %ebx,%esi
  800efb:	89 f0                	mov    %esi,%eax
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f03:	72 cd                	jb     800ed2 <devcons_write+0x22>
  800f05:	eb 05                	jmp    800f0c <devcons_write+0x5c>
  800f07:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f0c:	89 f0                	mov    %esi,%eax
  800f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f20:	75 07                	jne    800f29 <devcons_read+0x13>
  800f22:	eb 25                	jmp    800f49 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f24:	e8 6c f2 ff ff       	call   800195 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f29:	e8 fd f1 ff ff       	call   80012b <sys_cgetc>
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	74 f2                	je     800f24 <devcons_read+0xe>
  800f32:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 1d                	js     800f55 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f38:	83 f8 04             	cmp    $0x4,%eax
  800f3b:	74 13                	je     800f50 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f40:	88 10                	mov    %dl,(%eax)
	return 1;
  800f42:	b8 01 00 00 00       	mov    $0x1,%eax
  800f47:	eb 0c                	jmp    800f55 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	eb 05                	jmp    800f55 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f63:	6a 01                	push   $0x1
  800f65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f68:	50                   	push   %eax
  800f69:	e8 97 f1 ff ff       	call   800105 <sys_cputs>
  800f6e:	83 c4 10             	add    $0x10,%esp
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <getchar>:

int
getchar(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f79:	6a 01                	push   $0x1
  800f7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7e:	50                   	push   %eax
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 fe f6 ff ff       	call   800684 <read>
	if (r < 0)
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 0f                	js     800f9c <getchar+0x29>
		return r;
	if (r < 1)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 06                	jle    800f97 <getchar+0x24>
		return -E_EOF;
	return c;
  800f91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f95:	eb 05                	jmp    800f9c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	ff 75 08             	pushl  0x8(%ebp)
  800fab:	e8 53 f4 ff ff       	call   800403 <fd_lookup>
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 11                	js     800fc8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fba:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fc0:	39 10                	cmp    %edx,(%eax)
  800fc2:	0f 94 c0             	sete   %al
  800fc5:	0f b6 c0             	movzbl %al,%eax
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <opencons>:

int
opencons(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	e8 b7 f3 ff ff       	call   800390 <fd_alloc>
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 3a                	js     80101a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 07 04 00 00       	push   $0x407
  800fe8:	ff 75 f4             	pushl  -0xc(%ebp)
  800feb:	6a 00                	push   $0x0
  800fed:	e8 ca f1 ff ff       	call   8001bc <sys_page_alloc>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 21                	js     80101a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801002:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801004:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801007:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	50                   	push   %eax
  801012:	e8 51 f3 ff ff       	call   800368 <fd2num>
  801017:	83 c4 10             	add    $0x10,%esp
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801021:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801024:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80102a:	e8 42 f1 ff ff       	call   800171 <sys_getenvid>
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	ff 75 0c             	pushl  0xc(%ebp)
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	53                   	push   %ebx
  801039:	50                   	push   %eax
  80103a:	68 10 1f 80 00       	push   $0x801f10
  80103f:	e8 b0 00 00 00       	call   8010f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801044:	83 c4 18             	add    $0x18,%esp
  801047:	56                   	push   %esi
  801048:	ff 75 10             	pushl  0x10(%ebp)
  80104b:	e8 53 00 00 00       	call   8010a3 <vcprintf>
	cprintf("\n");
  801050:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  801057:	e8 98 00 00 00       	call   8010f4 <cprintf>
  80105c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105f:	cc                   	int3   
  801060:	eb fd                	jmp    80105f <_panic+0x43>
	...

00801064 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80106e:	8b 03                	mov    (%ebx),%eax
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801077:	40                   	inc    %eax
  801078:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80107a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80107f:	75 1a                	jne    80109b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	68 ff 00 00 00       	push   $0xff
  801089:	8d 43 08             	lea    0x8(%ebx),%eax
  80108c:	50                   	push   %eax
  80108d:	e8 73 f0 ff ff       	call   800105 <sys_cputs>
		b->idx = 0;
  801092:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801098:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80109b:	ff 43 04             	incl   0x4(%ebx)
}
  80109e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010b3:	00 00 00 
	b.cnt = 0;
  8010b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010c0:	ff 75 0c             	pushl  0xc(%ebp)
  8010c3:	ff 75 08             	pushl  0x8(%ebp)
  8010c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	68 64 10 80 00       	push   $0x801064
  8010d2:	e8 82 01 00 00       	call   801259 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d7:	83 c4 08             	add    $0x8,%esp
  8010da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	e8 19 f0 ff ff       	call   800105 <sys_cputs>

	return b.cnt;
}
  8010ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010fd:	50                   	push   %eax
  8010fe:	ff 75 08             	pushl  0x8(%ebp)
  801101:	e8 9d ff ff ff       	call   8010a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	57                   	push   %edi
  80110c:	56                   	push   %esi
  80110d:	53                   	push   %ebx
  80110e:	83 ec 2c             	sub    $0x2c,%esp
  801111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801114:	89 d6                	mov    %edx,%esi
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801122:	8b 45 10             	mov    0x10(%ebp),%eax
  801125:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801128:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80112b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80112e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801135:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801138:	72 0c                	jb     801146 <printnum+0x3e>
  80113a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80113d:	76 07                	jbe    801146 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80113f:	4b                   	dec    %ebx
  801140:	85 db                	test   %ebx,%ebx
  801142:	7f 31                	jg     801175 <printnum+0x6d>
  801144:	eb 3f                	jmp    801185 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	57                   	push   %edi
  80114a:	4b                   	dec    %ebx
  80114b:	53                   	push   %ebx
  80114c:	50                   	push   %eax
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	ff 75 d4             	pushl  -0x2c(%ebp)
  801153:	ff 75 d0             	pushl  -0x30(%ebp)
  801156:	ff 75 dc             	pushl  -0x24(%ebp)
  801159:	ff 75 d8             	pushl  -0x28(%ebp)
  80115c:	e8 23 0a 00 00       	call   801b84 <__udivdi3>
  801161:	83 c4 18             	add    $0x18,%esp
  801164:	52                   	push   %edx
  801165:	50                   	push   %eax
  801166:	89 f2                	mov    %esi,%edx
  801168:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116b:	e8 98 ff ff ff       	call   801108 <printnum>
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	eb 10                	jmp    801185 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	56                   	push   %esi
  801179:	57                   	push   %edi
  80117a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80117d:	4b                   	dec    %ebx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	85 db                	test   %ebx,%ebx
  801183:	7f f0                	jg     801175 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118f:	ff 75 d0             	pushl  -0x30(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 03 0b 00 00       	call   801ca0 <__umoddi3>
  80119d:	83 c4 14             	add    $0x14,%esp
  8011a0:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011a7:	50                   	push   %eax
  8011a8:	ff 55 e4             	call   *-0x1c(%ebp)
  8011ab:	83 c4 10             	add    $0x10,%esp
}
  8011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b9:	83 fa 01             	cmp    $0x1,%edx
  8011bc:	7e 0e                	jle    8011cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011c3:	89 08                	mov    %ecx,(%eax)
  8011c5:	8b 02                	mov    (%edx),%eax
  8011c7:	8b 52 04             	mov    0x4(%edx),%edx
  8011ca:	eb 22                	jmp    8011ee <getuint+0x38>
	else if (lflag)
  8011cc:	85 d2                	test   %edx,%edx
  8011ce:	74 10                	je     8011e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011d0:	8b 10                	mov    (%eax),%edx
  8011d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d5:	89 08                	mov    %ecx,(%eax)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011de:	eb 0e                	jmp    8011ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011e0:	8b 10                	mov    (%eax),%edx
  8011e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e5:	89 08                	mov    %ecx,(%eax)
  8011e7:	8b 02                	mov    (%edx),%eax
  8011e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f3:	83 fa 01             	cmp    $0x1,%edx
  8011f6:	7e 0e                	jle    801206 <getint+0x16>
		return va_arg(*ap, long long);
  8011f8:	8b 10                	mov    (%eax),%edx
  8011fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011fd:	89 08                	mov    %ecx,(%eax)
  8011ff:	8b 02                	mov    (%edx),%eax
  801201:	8b 52 04             	mov    0x4(%edx),%edx
  801204:	eb 1a                	jmp    801220 <getint+0x30>
	else if (lflag)
  801206:	85 d2                	test   %edx,%edx
  801208:	74 0c                	je     801216 <getint+0x26>
		return va_arg(*ap, long);
  80120a:	8b 10                	mov    (%eax),%edx
  80120c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120f:	89 08                	mov    %ecx,(%eax)
  801211:	8b 02                	mov    (%edx),%eax
  801213:	99                   	cltd   
  801214:	eb 0a                	jmp    801220 <getint+0x30>
	else
		return va_arg(*ap, int);
  801216:	8b 10                	mov    (%eax),%edx
  801218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121b:	89 08                	mov    %ecx,(%eax)
  80121d:	8b 02                	mov    (%edx),%eax
  80121f:	99                   	cltd   
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801228:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80122b:	8b 10                	mov    (%eax),%edx
  80122d:	3b 50 04             	cmp    0x4(%eax),%edx
  801230:	73 08                	jae    80123a <sprintputch+0x18>
		*b->buf++ = ch;
  801232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801235:	88 0a                	mov    %cl,(%edx)
  801237:	42                   	inc    %edx
  801238:	89 10                	mov    %edx,(%eax)
}
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801242:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801245:	50                   	push   %eax
  801246:	ff 75 10             	pushl  0x10(%ebp)
  801249:	ff 75 0c             	pushl  0xc(%ebp)
  80124c:	ff 75 08             	pushl  0x8(%ebp)
  80124f:	e8 05 00 00 00       	call   801259 <vprintfmt>
	va_end(ap);
  801254:	83 c4 10             	add    $0x10,%esp
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 2c             	sub    $0x2c,%esp
  801262:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801265:	8b 75 10             	mov    0x10(%ebp),%esi
  801268:	eb 13                	jmp    80127d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80126a:	85 c0                	test   %eax,%eax
  80126c:	0f 84 6d 03 00 00    	je     8015df <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	57                   	push   %edi
  801276:	50                   	push   %eax
  801277:	ff 55 08             	call   *0x8(%ebp)
  80127a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80127d:	0f b6 06             	movzbl (%esi),%eax
  801280:	46                   	inc    %esi
  801281:	83 f8 25             	cmp    $0x25,%eax
  801284:	75 e4                	jne    80126a <vprintfmt+0x11>
  801286:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80128a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801291:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801298:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80129f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a4:	eb 28                	jmp    8012ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012ac:	eb 20                	jmp    8012ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ae:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012b4:	eb 18                	jmp    8012ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012bf:	eb 0d                	jmp    8012ce <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ce:	8a 06                	mov    (%esi),%al
  8012d0:	0f b6 d0             	movzbl %al,%edx
  8012d3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012d6:	83 e8 23             	sub    $0x23,%eax
  8012d9:	3c 55                	cmp    $0x55,%al
  8012db:	0f 87 e0 02 00 00    	ja     8015c1 <vprintfmt+0x368>
  8012e1:	0f b6 c0             	movzbl %al,%eax
  8012e4:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012eb:	83 ea 30             	sub    $0x30,%edx
  8012ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012f1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012f7:	83 fa 09             	cmp    $0x9,%edx
  8012fa:	77 44                	ja     801340 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fc:	89 de                	mov    %ebx,%esi
  8012fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801301:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801302:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801305:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801309:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80130c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80130f:	83 fb 09             	cmp    $0x9,%ebx
  801312:	76 ed                	jbe    801301 <vprintfmt+0xa8>
  801314:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801317:	eb 29                	jmp    801342 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801319:	8b 45 14             	mov    0x14(%ebp),%eax
  80131c:	8d 50 04             	lea    0x4(%eax),%edx
  80131f:	89 55 14             	mov    %edx,0x14(%ebp)
  801322:	8b 00                	mov    (%eax),%eax
  801324:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801327:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801329:	eb 17                	jmp    801342 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80132b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80132f:	78 85                	js     8012b6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	89 de                	mov    %ebx,%esi
  801333:	eb 99                	jmp    8012ce <vprintfmt+0x75>
  801335:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801337:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80133e:	eb 8e                	jmp    8012ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801340:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801342:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801346:	79 86                	jns    8012ce <vprintfmt+0x75>
  801348:	e9 74 ff ff ff       	jmp    8012c1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134e:	89 de                	mov    %ebx,%esi
  801350:	e9 79 ff ff ff       	jmp    8012ce <vprintfmt+0x75>
  801355:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801358:	8b 45 14             	mov    0x14(%ebp),%eax
  80135b:	8d 50 04             	lea    0x4(%eax),%edx
  80135e:	89 55 14             	mov    %edx,0x14(%ebp)
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	57                   	push   %edi
  801365:	ff 30                	pushl  (%eax)
  801367:	ff 55 08             	call   *0x8(%ebp)
			break;
  80136a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801370:	e9 08 ff ff ff       	jmp    80127d <vprintfmt+0x24>
  801375:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801378:	8b 45 14             	mov    0x14(%ebp),%eax
  80137b:	8d 50 04             	lea    0x4(%eax),%edx
  80137e:	89 55 14             	mov    %edx,0x14(%ebp)
  801381:	8b 00                	mov    (%eax),%eax
  801383:	85 c0                	test   %eax,%eax
  801385:	79 02                	jns    801389 <vprintfmt+0x130>
  801387:	f7 d8                	neg    %eax
  801389:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80138b:	83 f8 0f             	cmp    $0xf,%eax
  80138e:	7f 0b                	jg     80139b <vprintfmt+0x142>
  801390:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	75 1a                	jne    8013b5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80139b:	52                   	push   %edx
  80139c:	68 4b 1f 80 00       	push   $0x801f4b
  8013a1:	57                   	push   %edi
  8013a2:	ff 75 08             	pushl  0x8(%ebp)
  8013a5:	e8 92 fe ff ff       	call   80123c <printfmt>
  8013aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b0:	e9 c8 fe ff ff       	jmp    80127d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013b5:	50                   	push   %eax
  8013b6:	68 c9 1e 80 00       	push   $0x801ec9
  8013bb:	57                   	push   %edi
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 78 fe ff ff       	call   80123c <printfmt>
  8013c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013ca:	e9 ae fe ff ff       	jmp    80127d <vprintfmt+0x24>
  8013cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013d2:	89 de                	mov    %ebx,%esi
  8013d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013da:	8b 45 14             	mov    0x14(%ebp),%eax
  8013dd:	8d 50 04             	lea    0x4(%eax),%edx
  8013e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e3:	8b 00                	mov    (%eax),%eax
  8013e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	75 07                	jne    8013f3 <vprintfmt+0x19a>
				p = "(null)";
  8013ec:	c7 45 d0 44 1f 80 00 	movl   $0x801f44,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013f3:	85 db                	test   %ebx,%ebx
  8013f5:	7e 42                	jle    801439 <vprintfmt+0x1e0>
  8013f7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013fb:	74 3c                	je     801439 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	51                   	push   %ecx
  801401:	ff 75 d0             	pushl  -0x30(%ebp)
  801404:	e8 6f 02 00 00       	call   801678 <strnlen>
  801409:	29 c3                	sub    %eax,%ebx
  80140b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 db                	test   %ebx,%ebx
  801413:	7e 24                	jle    801439 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801415:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801419:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80141c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	57                   	push   %edi
  801423:	53                   	push   %ebx
  801424:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801427:	4e                   	dec    %esi
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 f6                	test   %esi,%esi
  80142d:	7f f0                	jg     80141f <vprintfmt+0x1c6>
  80142f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801432:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801439:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80143c:	0f be 02             	movsbl (%edx),%eax
  80143f:	85 c0                	test   %eax,%eax
  801441:	75 47                	jne    80148a <vprintfmt+0x231>
  801443:	eb 37                	jmp    80147c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801449:	74 16                	je     801461 <vprintfmt+0x208>
  80144b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80144e:	83 fa 5e             	cmp    $0x5e,%edx
  801451:	76 0e                	jbe    801461 <vprintfmt+0x208>
					putch('?', putdat);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	57                   	push   %edi
  801457:	6a 3f                	push   $0x3f
  801459:	ff 55 08             	call   *0x8(%ebp)
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	eb 0b                	jmp    80146c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	57                   	push   %edi
  801465:	50                   	push   %eax
  801466:	ff 55 08             	call   *0x8(%ebp)
  801469:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146c:	ff 4d e4             	decl   -0x1c(%ebp)
  80146f:	0f be 03             	movsbl (%ebx),%eax
  801472:	85 c0                	test   %eax,%eax
  801474:	74 03                	je     801479 <vprintfmt+0x220>
  801476:	43                   	inc    %ebx
  801477:	eb 1b                	jmp    801494 <vprintfmt+0x23b>
  801479:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801480:	7f 1e                	jg     8014a0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801482:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801485:	e9 f3 fd ff ff       	jmp    80127d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80148d:	43                   	inc    %ebx
  80148e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801491:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801494:	85 f6                	test   %esi,%esi
  801496:	78 ad                	js     801445 <vprintfmt+0x1ec>
  801498:	4e                   	dec    %esi
  801499:	79 aa                	jns    801445 <vprintfmt+0x1ec>
  80149b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80149e:	eb dc                	jmp    80147c <vprintfmt+0x223>
  8014a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	57                   	push   %edi
  8014a7:	6a 20                	push   $0x20
  8014a9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ac:	4b                   	dec    %ebx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 db                	test   %ebx,%ebx
  8014b2:	7f ef                	jg     8014a3 <vprintfmt+0x24a>
  8014b4:	e9 c4 fd ff ff       	jmp    80127d <vprintfmt+0x24>
  8014b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014bc:	89 ca                	mov    %ecx,%edx
  8014be:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c1:	e8 2a fd ff ff       	call   8011f0 <getint>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014ca:	85 d2                	test   %edx,%edx
  8014cc:	78 0a                	js     8014d8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d3:	e9 b0 00 00 00       	jmp    801588 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	57                   	push   %edi
  8014dc:	6a 2d                	push   $0x2d
  8014de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014e1:	f7 db                	neg    %ebx
  8014e3:	83 d6 00             	adc    $0x0,%esi
  8014e6:	f7 de                	neg    %esi
  8014e8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f0:	e9 93 00 00 00       	jmp    801588 <vprintfmt+0x32f>
  8014f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014f8:	89 ca                	mov    %ecx,%edx
  8014fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8014fd:	e8 b4 fc ff ff       	call   8011b6 <getuint>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	89 d6                	mov    %edx,%esi
			base = 10;
  801506:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80150b:	eb 7b                	jmp    801588 <vprintfmt+0x32f>
  80150d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801510:	89 ca                	mov    %ecx,%edx
  801512:	8d 45 14             	lea    0x14(%ebp),%eax
  801515:	e8 d6 fc ff ff       	call   8011f0 <getint>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80151e:	85 d2                	test   %edx,%edx
  801520:	78 07                	js     801529 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801522:	b8 08 00 00 00       	mov    $0x8,%eax
  801527:	eb 5f                	jmp    801588 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801529:	83 ec 08             	sub    $0x8,%esp
  80152c:	57                   	push   %edi
  80152d:	6a 2d                	push   $0x2d
  80152f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801532:	f7 db                	neg    %ebx
  801534:	83 d6 00             	adc    $0x0,%esi
  801537:	f7 de                	neg    %esi
  801539:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80153c:	b8 08 00 00 00       	mov    $0x8,%eax
  801541:	eb 45                	jmp    801588 <vprintfmt+0x32f>
  801543:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	57                   	push   %edi
  80154a:	6a 30                	push   $0x30
  80154c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	57                   	push   %edi
  801553:	6a 78                	push   $0x78
  801555:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 50 04             	lea    0x4(%eax),%edx
  80155e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801561:	8b 18                	mov    (%eax),%ebx
  801563:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801568:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80156b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801570:	eb 16                	jmp    801588 <vprintfmt+0x32f>
  801572:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801575:	89 ca                	mov    %ecx,%edx
  801577:	8d 45 14             	lea    0x14(%ebp),%eax
  80157a:	e8 37 fc ff ff       	call   8011b6 <getuint>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	89 d6                	mov    %edx,%esi
			base = 16;
  801583:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80158f:	52                   	push   %edx
  801590:	ff 75 e4             	pushl  -0x1c(%ebp)
  801593:	50                   	push   %eax
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	89 fa                	mov    %edi,%edx
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	e8 68 fb ff ff       	call   801108 <printnum>
			break;
  8015a0:	83 c4 20             	add    $0x20,%esp
  8015a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015a6:	e9 d2 fc ff ff       	jmp    80127d <vprintfmt+0x24>
  8015ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	57                   	push   %edi
  8015b2:	52                   	push   %edx
  8015b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015bc:	e9 bc fc ff ff       	jmp    80127d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	57                   	push   %edi
  8015c5:	6a 25                	push   $0x25
  8015c7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb 02                	jmp    8015d1 <vprintfmt+0x378>
  8015cf:	89 c6                	mov    %eax,%esi
  8015d1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015d4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015d8:	75 f5                	jne    8015cf <vprintfmt+0x376>
  8015da:	e9 9e fc ff ff       	jmp    80127d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5f                   	pop    %edi
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 18             	sub    $0x18,%esp
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801604:	85 c0                	test   %eax,%eax
  801606:	74 26                	je     80162e <vsnprintf+0x47>
  801608:	85 d2                	test   %edx,%edx
  80160a:	7e 29                	jle    801635 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160c:	ff 75 14             	pushl  0x14(%ebp)
  80160f:	ff 75 10             	pushl  0x10(%ebp)
  801612:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	68 22 12 80 00       	push   $0x801222
  80161b:	e8 39 fc ff ff       	call   801259 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801620:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801623:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 0c                	jmp    80163a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80162e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801633:	eb 05                	jmp    80163a <vsnprintf+0x53>
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801642:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801645:	50                   	push   %eax
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 93 ff ff ff       	call   8015e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    
	...

00801658 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165e:	80 3a 00             	cmpb   $0x0,(%edx)
  801661:	74 0e                	je     801671 <strlen+0x19>
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801668:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801669:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80166d:	75 f9                	jne    801668 <strlen+0x10>
  80166f:	eb 05                	jmp    801676 <strlen+0x1e>
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801681:	85 d2                	test   %edx,%edx
  801683:	74 17                	je     80169c <strnlen+0x24>
  801685:	80 39 00             	cmpb   $0x0,(%ecx)
  801688:	74 19                	je     8016a3 <strnlen+0x2b>
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80168f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801690:	39 d0                	cmp    %edx,%eax
  801692:	74 14                	je     8016a8 <strnlen+0x30>
  801694:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801698:	75 f5                	jne    80168f <strnlen+0x17>
  80169a:	eb 0c                	jmp    8016a8 <strnlen+0x30>
  80169c:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a1:	eb 05                	jmp    8016a8 <strnlen+0x30>
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016bc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016bf:	42                   	inc    %edx
  8016c0:	84 c9                	test   %cl,%cl
  8016c2:	75 f5                	jne    8016b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016c4:	5b                   	pop    %ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ce:	53                   	push   %ebx
  8016cf:	e8 84 ff ff ff       	call   801658 <strlen>
  8016d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016dd:	50                   	push   %eax
  8016de:	e8 c7 ff ff ff       	call   8016aa <strcpy>
	return dst;
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f8:	85 f6                	test   %esi,%esi
  8016fa:	74 15                	je     801711 <strncpy+0x27>
  8016fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801701:	8a 1a                	mov    (%edx),%bl
  801703:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801706:	80 3a 01             	cmpb   $0x1,(%edx)
  801709:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170c:	41                   	inc    %ecx
  80170d:	39 ce                	cmp    %ecx,%esi
  80170f:	77 f0                	ja     801701 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	57                   	push   %edi
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801721:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801724:	85 f6                	test   %esi,%esi
  801726:	74 32                	je     80175a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801728:	83 fe 01             	cmp    $0x1,%esi
  80172b:	74 22                	je     80174f <strlcpy+0x3a>
  80172d:	8a 0b                	mov    (%ebx),%cl
  80172f:	84 c9                	test   %cl,%cl
  801731:	74 20                	je     801753 <strlcpy+0x3e>
  801733:	89 f8                	mov    %edi,%eax
  801735:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80173a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173d:	88 08                	mov    %cl,(%eax)
  80173f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801740:	39 f2                	cmp    %esi,%edx
  801742:	74 11                	je     801755 <strlcpy+0x40>
  801744:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801748:	42                   	inc    %edx
  801749:	84 c9                	test   %cl,%cl
  80174b:	75 f0                	jne    80173d <strlcpy+0x28>
  80174d:	eb 06                	jmp    801755 <strlcpy+0x40>
  80174f:	89 f8                	mov    %edi,%eax
  801751:	eb 02                	jmp    801755 <strlcpy+0x40>
  801753:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801755:	c6 00 00             	movb   $0x0,(%eax)
  801758:	eb 02                	jmp    80175c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80175c:	29 f8                	sub    %edi,%eax
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801769:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176c:	8a 01                	mov    (%ecx),%al
  80176e:	84 c0                	test   %al,%al
  801770:	74 10                	je     801782 <strcmp+0x1f>
  801772:	3a 02                	cmp    (%edx),%al
  801774:	75 0c                	jne    801782 <strcmp+0x1f>
		p++, q++;
  801776:	41                   	inc    %ecx
  801777:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801778:	8a 01                	mov    (%ecx),%al
  80177a:	84 c0                	test   %al,%al
  80177c:	74 04                	je     801782 <strcmp+0x1f>
  80177e:	3a 02                	cmp    (%edx),%al
  801780:	74 f4                	je     801776 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801782:	0f b6 c0             	movzbl %al,%eax
  801785:	0f b6 12             	movzbl (%edx),%edx
  801788:	29 d0                	sub    %edx,%eax
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	8b 55 08             	mov    0x8(%ebp),%edx
  801793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801796:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801799:	85 c0                	test   %eax,%eax
  80179b:	74 1b                	je     8017b8 <strncmp+0x2c>
  80179d:	8a 1a                	mov    (%edx),%bl
  80179f:	84 db                	test   %bl,%bl
  8017a1:	74 24                	je     8017c7 <strncmp+0x3b>
  8017a3:	3a 19                	cmp    (%ecx),%bl
  8017a5:	75 20                	jne    8017c7 <strncmp+0x3b>
  8017a7:	48                   	dec    %eax
  8017a8:	74 15                	je     8017bf <strncmp+0x33>
		n--, p++, q++;
  8017aa:	42                   	inc    %edx
  8017ab:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ac:	8a 1a                	mov    (%edx),%bl
  8017ae:	84 db                	test   %bl,%bl
  8017b0:	74 15                	je     8017c7 <strncmp+0x3b>
  8017b2:	3a 19                	cmp    (%ecx),%bl
  8017b4:	74 f1                	je     8017a7 <strncmp+0x1b>
  8017b6:	eb 0f                	jmp    8017c7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bd:	eb 05                	jmp    8017c4 <strncmp+0x38>
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c4:	5b                   	pop    %ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c7:	0f b6 02             	movzbl (%edx),%eax
  8017ca:	0f b6 11             	movzbl (%ecx),%edx
  8017cd:	29 d0                	sub    %edx,%eax
  8017cf:	eb f3                	jmp    8017c4 <strncmp+0x38>

008017d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017da:	8a 10                	mov    (%eax),%dl
  8017dc:	84 d2                	test   %dl,%dl
  8017de:	74 18                	je     8017f8 <strchr+0x27>
		if (*s == c)
  8017e0:	38 ca                	cmp    %cl,%dl
  8017e2:	75 06                	jne    8017ea <strchr+0x19>
  8017e4:	eb 17                	jmp    8017fd <strchr+0x2c>
  8017e6:	38 ca                	cmp    %cl,%dl
  8017e8:	74 13                	je     8017fd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ea:	40                   	inc    %eax
  8017eb:	8a 10                	mov    (%eax),%dl
  8017ed:	84 d2                	test   %dl,%dl
  8017ef:	75 f5                	jne    8017e6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f6:	eb 05                	jmp    8017fd <strchr+0x2c>
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801808:	8a 10                	mov    (%eax),%dl
  80180a:	84 d2                	test   %dl,%dl
  80180c:	74 11                	je     80181f <strfind+0x20>
		if (*s == c)
  80180e:	38 ca                	cmp    %cl,%dl
  801810:	75 06                	jne    801818 <strfind+0x19>
  801812:	eb 0b                	jmp    80181f <strfind+0x20>
  801814:	38 ca                	cmp    %cl,%dl
  801816:	74 07                	je     80181f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801818:	40                   	inc    %eax
  801819:	8a 10                	mov    (%eax),%dl
  80181b:	84 d2                	test   %dl,%dl
  80181d:	75 f5                	jne    801814 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 30                	je     801864 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 25                	jne    801861 <memset+0x40>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 20                	jne    801861 <memset+0x40>
		c &= 0xFF;
  801841:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801844:	89 d3                	mov    %edx,%ebx
  801846:	c1 e3 08             	shl    $0x8,%ebx
  801849:	89 d6                	mov    %edx,%esi
  80184b:	c1 e6 18             	shl    $0x18,%esi
  80184e:	89 d0                	mov    %edx,%eax
  801850:	c1 e0 10             	shl    $0x10,%eax
  801853:	09 f0                	or     %esi,%eax
  801855:	09 d0                	or     %edx,%eax
  801857:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801859:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80185c:	fc                   	cld    
  80185d:	f3 ab                	rep stos %eax,%es:(%edi)
  80185f:	eb 03                	jmp    801864 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801861:	fc                   	cld    
  801862:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801864:	89 f8                	mov    %edi,%eax
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5f                   	pop    %edi
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	57                   	push   %edi
  80186f:	56                   	push   %esi
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 75 0c             	mov    0xc(%ebp),%esi
  801876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801879:	39 c6                	cmp    %eax,%esi
  80187b:	73 34                	jae    8018b1 <memmove+0x46>
  80187d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801880:	39 d0                	cmp    %edx,%eax
  801882:	73 2d                	jae    8018b1 <memmove+0x46>
		s += n;
		d += n;
  801884:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801887:	f6 c2 03             	test   $0x3,%dl
  80188a:	75 1b                	jne    8018a7 <memmove+0x3c>
  80188c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801892:	75 13                	jne    8018a7 <memmove+0x3c>
  801894:	f6 c1 03             	test   $0x3,%cl
  801897:	75 0e                	jne    8018a7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801899:	83 ef 04             	sub    $0x4,%edi
  80189c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018a2:	fd                   	std    
  8018a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a5:	eb 07                	jmp    8018ae <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a7:	4f                   	dec    %edi
  8018a8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ab:	fd                   	std    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ae:	fc                   	cld    
  8018af:	eb 20                	jmp    8018d1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b7:	75 13                	jne    8018cc <memmove+0x61>
  8018b9:	a8 03                	test   $0x3,%al
  8018bb:	75 0f                	jne    8018cc <memmove+0x61>
  8018bd:	f6 c1 03             	test   $0x3,%cl
  8018c0:	75 0a                	jne    8018cc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018c5:	89 c7                	mov    %eax,%edi
  8018c7:	fc                   	cld    
  8018c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ca:	eb 05                	jmp    8018d1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d8:	ff 75 10             	pushl  0x10(%ebp)
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 85 ff ff ff       	call   80186b <memmove>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f7:	85 ff                	test   %edi,%edi
  8018f9:	74 32                	je     80192d <memcmp+0x45>
		if (*s1 != *s2)
  8018fb:	8a 03                	mov    (%ebx),%al
  8018fd:	8a 0e                	mov    (%esi),%cl
  8018ff:	38 c8                	cmp    %cl,%al
  801901:	74 19                	je     80191c <memcmp+0x34>
  801903:	eb 0d                	jmp    801912 <memcmp+0x2a>
  801905:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801909:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80190d:	42                   	inc    %edx
  80190e:	38 c8                	cmp    %cl,%al
  801910:	74 10                	je     801922 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801912:	0f b6 c0             	movzbl %al,%eax
  801915:	0f b6 c9             	movzbl %cl,%ecx
  801918:	29 c8                	sub    %ecx,%eax
  80191a:	eb 16                	jmp    801932 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191c:	4f                   	dec    %edi
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	39 fa                	cmp    %edi,%edx
  801924:	75 df                	jne    801905 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
  80192b:	eb 05                	jmp    801932 <memcmp+0x4a>
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5f                   	pop    %edi
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801942:	39 d0                	cmp    %edx,%eax
  801944:	73 12                	jae    801958 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801946:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801949:	38 08                	cmp    %cl,(%eax)
  80194b:	75 06                	jne    801953 <memfind+0x1c>
  80194d:	eb 09                	jmp    801958 <memfind+0x21>
  80194f:	38 08                	cmp    %cl,(%eax)
  801951:	74 05                	je     801958 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801953:	40                   	inc    %eax
  801954:	39 c2                	cmp    %eax,%edx
  801956:	77 f7                	ja     80194f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 55 08             	mov    0x8(%ebp),%edx
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801966:	eb 01                	jmp    801969 <strtol+0xf>
		s++;
  801968:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801969:	8a 02                	mov    (%edx),%al
  80196b:	3c 20                	cmp    $0x20,%al
  80196d:	74 f9                	je     801968 <strtol+0xe>
  80196f:	3c 09                	cmp    $0x9,%al
  801971:	74 f5                	je     801968 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801973:	3c 2b                	cmp    $0x2b,%al
  801975:	75 08                	jne    80197f <strtol+0x25>
		s++;
  801977:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
  80197d:	eb 13                	jmp    801992 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197f:	3c 2d                	cmp    $0x2d,%al
  801981:	75 0a                	jne    80198d <strtol+0x33>
		s++, neg = 1;
  801983:	8d 52 01             	lea    0x1(%edx),%edx
  801986:	bf 01 00 00 00       	mov    $0x1,%edi
  80198b:	eb 05                	jmp    801992 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801992:	85 db                	test   %ebx,%ebx
  801994:	74 05                	je     80199b <strtol+0x41>
  801996:	83 fb 10             	cmp    $0x10,%ebx
  801999:	75 28                	jne    8019c3 <strtol+0x69>
  80199b:	8a 02                	mov    (%edx),%al
  80199d:	3c 30                	cmp    $0x30,%al
  80199f:	75 10                	jne    8019b1 <strtol+0x57>
  8019a1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8019a5:	75 0a                	jne    8019b1 <strtol+0x57>
		s += 2, base = 16;
  8019a7:	83 c2 02             	add    $0x2,%edx
  8019aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019af:	eb 12                	jmp    8019c3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019b1:	85 db                	test   %ebx,%ebx
  8019b3:	75 0e                	jne    8019c3 <strtol+0x69>
  8019b5:	3c 30                	cmp    $0x30,%al
  8019b7:	75 05                	jne    8019be <strtol+0x64>
		s++, base = 8;
  8019b9:	42                   	inc    %edx
  8019ba:	b3 08                	mov    $0x8,%bl
  8019bc:	eb 05                	jmp    8019c3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019be:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ca:	8a 0a                	mov    (%edx),%cl
  8019cc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019cf:	80 fb 09             	cmp    $0x9,%bl
  8019d2:	77 08                	ja     8019dc <strtol+0x82>
			dig = *s - '0';
  8019d4:	0f be c9             	movsbl %cl,%ecx
  8019d7:	83 e9 30             	sub    $0x30,%ecx
  8019da:	eb 1e                	jmp    8019fa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019dc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019df:	80 fb 19             	cmp    $0x19,%bl
  8019e2:	77 08                	ja     8019ec <strtol+0x92>
			dig = *s - 'a' + 10;
  8019e4:	0f be c9             	movsbl %cl,%ecx
  8019e7:	83 e9 57             	sub    $0x57,%ecx
  8019ea:	eb 0e                	jmp    8019fa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019ec:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019ef:	80 fb 19             	cmp    $0x19,%bl
  8019f2:	77 13                	ja     801a07 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019f4:	0f be c9             	movsbl %cl,%ecx
  8019f7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019fa:	39 f1                	cmp    %esi,%ecx
  8019fc:	7d 0d                	jge    801a0b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019fe:	42                   	inc    %edx
  8019ff:	0f af c6             	imul   %esi,%eax
  801a02:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801a05:	eb c3                	jmp    8019ca <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801a07:	89 c1                	mov    %eax,%ecx
  801a09:	eb 02                	jmp    801a0d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a0b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a11:	74 05                	je     801a18 <strtol+0xbe>
		*endptr = (char *) s;
  801a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a16:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a18:	85 ff                	test   %edi,%edi
  801a1a:	74 04                	je     801a20 <strtol+0xc6>
  801a1c:	89 c8                	mov    %ecx,%eax
  801a1e:	f7 d8                	neg    %eax
}
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    
  801a25:	00 00                	add    %al,(%eax)
	...

00801a28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a36:	85 c0                	test   %eax,%eax
  801a38:	74 0e                	je     801a48 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	50                   	push   %eax
  801a3e:	e8 74 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb 10                	jmp    801a58 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	68 00 00 c0 ee       	push   $0xeec00000
  801a50:	e8 62 e8 ff ff       	call   8002b7 <sys_ipc_recv>
  801a55:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	75 26                	jne    801a82 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	74 0a                	je     801a6a <ipc_recv+0x42>
  801a60:	a1 04 40 80 00       	mov    0x804004,%eax
  801a65:	8b 40 74             	mov    0x74(%eax),%eax
  801a68:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x50>
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 78             	mov    0x78(%eax),%eax
  801a76:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 40 70             	mov    0x70(%eax),%eax
  801a80:	eb 14                	jmp    801a96 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a82:	85 f6                	test   %esi,%esi
  801a84:	74 06                	je     801a8c <ipc_recv+0x64>
  801a86:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a8c:	85 db                	test   %ebx,%ebx
  801a8e:	74 06                	je     801a96 <ipc_recv+0x6e>
  801a90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aac:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	75 25                	jne    801ad8 <ipc_send+0x3b>
  801ab3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ab8:	eb 1e                	jmp    801ad8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abd:	75 07                	jne    801ac6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801abf:	e8 d1 e6 ff ff       	call   800195 <sys_yield>
  801ac4:	eb 12                	jmp    801ad8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ac6:	50                   	push   %eax
  801ac7:	68 40 22 80 00       	push   $0x802240
  801acc:	6a 43                	push   $0x43
  801ace:	68 53 22 80 00       	push   $0x802253
  801ad3:	e8 44 f5 ff ff       	call   80101c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	57                   	push   %edi
  801adb:	ff 75 08             	pushl  0x8(%ebp)
  801ade:	e8 af e7 ff ff       	call   800292 <sys_ipc_try_send>
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	75 d0                	jne    801aba <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801af8:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801afe:	74 1a                	je     801b1a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b00:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 e2 07             	shl    $0x7,%edx
  801b0a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b11:	8b 52 50             	mov    0x50(%edx),%edx
  801b14:	39 ca                	cmp    %ecx,%edx
  801b16:	75 18                	jne    801b30 <ipc_find_env+0x3e>
  801b18:	eb 05                	jmp    801b1f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	c1 e2 07             	shl    $0x7,%edx
  801b24:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b2b:	8b 40 40             	mov    0x40(%eax),%eax
  801b2e:	eb 0c                	jmp    801b3c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b30:	40                   	inc    %eax
  801b31:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b36:	75 cd                	jne    801b05 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b38:	66 b8 00 00          	mov    $0x0,%ax
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    
	...

00801b40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b46:	89 c2                	mov    %eax,%edx
  801b48:	c1 ea 16             	shr    $0x16,%edx
  801b4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b52:	f6 c2 01             	test   $0x1,%dl
  801b55:	74 1e                	je     801b75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b57:	c1 e8 0c             	shr    $0xc,%eax
  801b5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b61:	a8 01                	test   $0x1,%al
  801b63:	74 17                	je     801b7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b65:	c1 e8 0c             	shr    $0xc,%eax
  801b68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b6f:	ef 
  801b70:	0f b7 c0             	movzwl %ax,%eax
  801b73:	eb 0c                	jmp    801b81 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	eb 05                	jmp    801b81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    
	...

00801b84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	83 ec 10             	sub    $0x10,%esp
  801b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b92:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	75 2e                	jne    801bd0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ba2:	39 f1                	cmp    %esi,%ecx
  801ba4:	77 5a                	ja     801c00 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ba6:	85 c9                	test   %ecx,%ecx
  801ba8:	75 0b                	jne    801bb5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801baa:	b8 01 00 00 00       	mov    $0x1,%eax
  801baf:	31 d2                	xor    %edx,%edx
  801bb1:	f7 f1                	div    %ecx
  801bb3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	f7 f1                	div    %ecx
  801bbb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bbd:	89 f8                	mov    %edi,%eax
  801bbf:	f7 f1                	div    %ecx
  801bc1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bc3:	89 f8                	mov    %edi,%eax
  801bc5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    
  801bce:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bd0:	39 f0                	cmp    %esi,%eax
  801bd2:	77 1c                	ja     801bf0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bd4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	75 3c                	jne    801c18 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bdc:	39 f0                	cmp    %esi,%eax
  801bde:	0f 82 90 00 00 00    	jb     801c74 <__udivdi3+0xf0>
  801be4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801be7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bea:	0f 86 84 00 00 00    	jbe    801c74 <__udivdi3+0xf0>
  801bf0:	31 f6                	xor    %esi,%esi
  801bf2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bf4:	89 f8                	mov    %edi,%eax
  801bf6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	5e                   	pop    %esi
  801bfc:	5f                   	pop    %edi
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    
  801bff:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c00:	89 f2                	mov    %esi,%edx
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	f7 f1                	div    %ecx
  801c06:	89 c7                	mov    %eax,%edi
  801c08:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c18:	89 f9                	mov    %edi,%ecx
  801c1a:	d3 e0                	shl    %cl,%eax
  801c1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c1f:	b8 20 00 00 00       	mov    $0x20,%eax
  801c24:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c29:	88 c1                	mov    %al,%cl
  801c2b:	d3 ea                	shr    %cl,%edx
  801c2d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c30:	09 ca                	or     %ecx,%edx
  801c32:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c38:	89 f9                	mov    %edi,%ecx
  801c3a:	d3 e2                	shl    %cl,%edx
  801c3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c3f:	89 f2                	mov    %esi,%edx
  801c41:	88 c1                	mov    %al,%cl
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	89 f9                	mov    %edi,%ecx
  801c4c:	d3 e2                	shl    %cl,%edx
  801c4e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c51:	88 c1                	mov    %al,%cl
  801c53:	d3 ee                	shr    %cl,%esi
  801c55:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c57:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c5a:	89 f0                	mov    %esi,%eax
  801c5c:	89 ca                	mov    %ecx,%edx
  801c5e:	f7 75 ec             	divl   -0x14(%ebp)
  801c61:	89 d1                	mov    %edx,%ecx
  801c63:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c65:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c68:	39 d1                	cmp    %edx,%ecx
  801c6a:	72 28                	jb     801c94 <__udivdi3+0x110>
  801c6c:	74 1a                	je     801c88 <__udivdi3+0x104>
  801c6e:	89 f7                	mov    %esi,%edi
  801c70:	31 f6                	xor    %esi,%esi
  801c72:	eb 80                	jmp    801bf4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c74:	31 f6                	xor    %esi,%esi
  801c76:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    
  801c86:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c8f:	39 c2                	cmp    %eax,%edx
  801c91:	73 db                	jae    801c6e <__udivdi3+0xea>
  801c93:	90                   	nop
		{
		  q0--;
  801c94:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c97:	31 f6                	xor    %esi,%esi
  801c99:	e9 56 ff ff ff       	jmp    801bf4 <__udivdi3+0x70>
	...

00801ca0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	83 ec 20             	sub    $0x20,%esp
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cb4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cbd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cbf:	85 ff                	test   %edi,%edi
  801cc1:	75 15                	jne    801cd8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cc3:	39 f1                	cmp    %esi,%ecx
  801cc5:	0f 86 99 00 00 00    	jbe    801d64 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ccb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ccd:	89 d0                	mov    %edx,%eax
  801ccf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cd1:	83 c4 20             	add    $0x20,%esp
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd8:	39 f7                	cmp    %esi,%edi
  801cda:	0f 87 a4 00 00 00    	ja     801d84 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ce0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ce3:	83 f0 1f             	xor    $0x1f,%eax
  801ce6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce9:	0f 84 a1 00 00 00    	je     801d90 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cf6:	bf 20 00 00 00       	mov    $0x20,%edi
  801cfb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	09 c2                	or     %eax,%edx
  801d07:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d10:	d3 e0                	shl    %cl,%eax
  801d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d15:	89 f2                	mov    %esi,%edx
  801d17:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d24:	89 f9                	mov    %edi,%ecx
  801d26:	d3 e8                	shr    %cl,%eax
  801d28:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d2a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	f7 75 f0             	divl   -0x10(%ebp)
  801d31:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d33:	f7 65 f4             	mull   -0xc(%ebp)
  801d36:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d39:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d3b:	39 d6                	cmp    %edx,%esi
  801d3d:	72 71                	jb     801db0 <__umoddi3+0x110>
  801d3f:	74 7f                	je     801dc0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d44:	29 c8                	sub    %ecx,%eax
  801d46:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d48:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	89 f9                	mov    %edi,%ecx
  801d51:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d53:	09 d0                	or     %edx,%eax
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d5c:	83 c4 20             	add    $0x20,%esp
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    
  801d63:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	75 0b                	jne    801d73 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f1                	div    %ecx
  801d71:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	31 d2                	xor    %edx,%edx
  801d77:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7c:	f7 f1                	div    %ecx
  801d7e:	e9 4a ff ff ff       	jmp    801ccd <__umoddi3+0x2d>
  801d83:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d84:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d86:	83 c4 20             	add    $0x20,%esp
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d90:	39 f7                	cmp    %esi,%edi
  801d92:	72 05                	jb     801d99 <__umoddi3+0xf9>
  801d94:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d97:	77 0c                	ja     801da5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d99:	89 f2                	mov    %esi,%edx
  801d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9e:	29 c8                	sub    %ecx,%eax
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
  801daf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801db0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801db3:	89 c1                	mov    %eax,%ecx
  801db5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801db8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801dbb:	eb 84                	jmp    801d41 <__umoddi3+0xa1>
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dc0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dc3:	72 eb                	jb     801db0 <__umoddi3+0x110>
  801dc5:	89 f2                	mov    %esi,%edx
  801dc7:	e9 75 ff ff ff       	jmp    801d41 <__umoddi3+0xa1>
