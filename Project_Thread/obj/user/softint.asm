
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c9                   	leave  
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 75 08             	mov    0x8(%ebp),%esi
  800044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800047:	e8 11 01 00 00       	call   80015d <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 07             	shl    $0x7,%edx
  800056:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80005d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 f6                	test   %esi,%esi
  800064:	7e 07                	jle    80006d <libmain+0x31>
		binaryname = argv[0];
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80006d:	83 ec 08             	sub    $0x8,%esp
  800070:	53                   	push   %ebx
  800071:	56                   	push   %esi
  800072:	e8 bd ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800077:	e8 0c 00 00 00       	call   800088 <exit>
  80007c:	83 c4 10             	add    $0x10,%esp
}
  80007f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800082:	5b                   	pop    %ebx
  800083:	5e                   	pop    %esi
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 cb 04 00 00       	call   80055e <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 9e 00 00 00       	call   80013b <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 1c             	sub    $0x1c,%esp
  8000ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c1:	cd 30                	int    $0x30
  8000c3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c9:	74 1c                	je     8000e7 <syscall+0x43>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7e 18                	jle    8000e7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	50                   	push   %eax
  8000d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000d6:	68 ca 1d 80 00       	push   $0x801dca
  8000db:	6a 42                	push   $0x42
  8000dd:	68 e7 1d 80 00       	push   $0x801de7
  8000e2:	e8 21 0f 00 00       	call   801008 <_panic>

	return ret;
}
  8000e7:	89 d0                	mov    %edx,%eax
  8000e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f7:	6a 00                	push   $0x0
  8000f9:	6a 00                	push   $0x0
  8000fb:	6a 00                	push   $0x0
  8000fd:	ff 75 0c             	pushl  0xc(%ebp)
  800100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800103:	ba 00 00 00 00       	mov    $0x0,%edx
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 92 ff ff ff       	call   8000a4 <syscall>
  800112:	83 c4 10             	add    $0x10,%esp
	return;
}
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <sys_cgetc>:

int
sys_cgetc(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 01 00 00 00       	mov    $0x1,%eax
  800134:	e8 6b ff ff ff       	call   8000a4 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014c:	ba 01 00 00 00       	mov    $0x1,%edx
  800151:	b8 03 00 00 00       	mov    $0x3,%eax
  800156:	e8 49 ff ff ff       	call   8000a4 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 02 00 00 00       	mov    $0x2,%eax
  80017a:	e8 25 ff ff ff       	call   8000a4 <syscall>
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <sys_yield>:

void
sys_yield(void)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019e:	e8 01 ff ff ff       	call   8000a4 <syscall>
  8001a3:	83 c4 10             	add    $0x10,%esp
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ae:	6a 00                	push   $0x0
  8001b0:	6a 00                	push   $0x0
  8001b2:	ff 75 10             	pushl  0x10(%ebp)
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c5:	e8 da fe ff ff       	call   8000a4 <syscall>
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff 75 14             	pushl  0x14(%ebp)
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	e8 b4 fe ff ff       	call   8000a4 <syscall>
}
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f8:	6a 00                	push   $0x0
  8001fa:	6a 00                	push   $0x0
  8001fc:	6a 00                	push   $0x0
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800204:	ba 01 00 00 00       	mov    $0x1,%edx
  800209:	b8 06 00 00 00       	mov    $0x6,%eax
  80020e:	e8 91 fe ff ff       	call   8000a4 <syscall>
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021b:	6a 00                	push   $0x0
  80021d:	6a 00                	push   $0x0
  80021f:	6a 00                	push   $0x0
  800221:	ff 75 0c             	pushl  0xc(%ebp)
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	ba 01 00 00 00       	mov    $0x1,%edx
  80022c:	b8 08 00 00 00       	mov    $0x8,%eax
  800231:	e8 6e fe ff ff       	call   8000a4 <syscall>
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80023e:	6a 00                	push   $0x0
  800240:	6a 00                	push   $0x0
  800242:	6a 00                	push   $0x0
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024a:	ba 01 00 00 00       	mov    $0x1,%edx
  80024f:	b8 09 00 00 00       	mov    $0x9,%eax
  800254:	e8 4b fe ff ff       	call   8000a4 <syscall>
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800261:	6a 00                	push   $0x0
  800263:	6a 00                	push   $0x0
  800265:	6a 00                	push   $0x0
  800267:	ff 75 0c             	pushl  0xc(%ebp)
  80026a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026d:	ba 01 00 00 00       	mov    $0x1,%edx
  800272:	b8 0a 00 00 00       	mov    $0xa,%eax
  800277:	e8 28 fe ff ff       	call   8000a4 <syscall>
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800284:	6a 00                	push   $0x0
  800286:	ff 75 14             	pushl  0x14(%ebp)
  800289:	ff 75 10             	pushl  0x10(%ebp)
  80028c:	ff 75 0c             	pushl  0xc(%ebp)
  80028f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029c:	e8 03 fe ff ff       	call   8000a4 <syscall>
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002a9:	6a 00                	push   $0x0
  8002ab:	6a 00                	push   $0x0
  8002ad:	6a 00                	push   $0x0
  8002af:	6a 00                	push   $0x0
  8002b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002be:	e8 e1 fd ff ff       	call   8000a4 <syscall>
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002cb:	6a 00                	push   $0x0
  8002cd:	6a 00                	push   $0x0
  8002cf:	6a 00                	push   $0x0
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e1:	e8 be fd ff ff       	call   8000a4 <syscall>
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002ee:	6a 00                	push   $0x0
  8002f0:	ff 75 14             	pushl  0x14(%ebp)
  8002f3:	ff 75 10             	pushl  0x10(%ebp)
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800301:	b8 0f 00 00 00       	mov    $0xf,%eax
  800306:	e8 99 fd ff ff       	call   8000a4 <syscall>
} 
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800313:	6a 00                	push   $0x0
  800315:	6a 00                	push   $0x0
  800317:	6a 00                	push   $0x0
  800319:	6a 00                	push   $0x0
  80031b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
  800323:	b8 11 00 00 00       	mov    $0x11,%eax
  800328:	e8 77 fd ff ff       	call   8000a4 <syscall>
}
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <sys_getpid>:

envid_t
sys_getpid(void)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800335:	6a 00                	push   $0x0
  800337:	6a 00                	push   $0x0
  800339:	6a 00                	push   $0x0
  80033b:	6a 00                	push   $0x0
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	ba 00 00 00 00       	mov    $0x0,%edx
  800347:	b8 10 00 00 00       	mov    $0x10,%eax
  80034c:	e8 53 fd ff ff       	call   8000a4 <syscall>
  800351:	c9                   	leave  
  800352:	c3                   	ret    
	...

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	ff 75 08             	pushl  0x8(%ebp)
  80036a:	e8 e5 ff ff ff       	call   800354 <fd2num>
  80036f:	83 c4 04             	add    $0x4,%esp
  800372:	05 20 00 0d 00       	add    $0xd0020,%eax
  800377:	c1 e0 0c             	shl    $0xc,%eax
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800383:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800388:	a8 01                	test   $0x1,%al
  80038a:	74 34                	je     8003c0 <fd_alloc+0x44>
  80038c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800391:	a8 01                	test   $0x1,%al
  800393:	74 32                	je     8003c7 <fd_alloc+0x4b>
  800395:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80039a:	89 c1                	mov    %eax,%ecx
  80039c:	89 c2                	mov    %eax,%edx
  80039e:	c1 ea 16             	shr    $0x16,%edx
  8003a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a8:	f6 c2 01             	test   $0x1,%dl
  8003ab:	74 1f                	je     8003cc <fd_alloc+0x50>
  8003ad:	89 c2                	mov    %eax,%edx
  8003af:	c1 ea 0c             	shr    $0xc,%edx
  8003b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	75 17                	jne    8003d5 <fd_alloc+0x59>
  8003be:	eb 0c                	jmp    8003cc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003c0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003c5:	eb 05                	jmp    8003cc <fd_alloc+0x50>
  8003c7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003cc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d3:	eb 17                	jmp    8003ec <fd_alloc+0x70>
  8003d5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003da:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003df:	75 b9                	jne    80039a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003e7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ec:	5b                   	pop    %ebx
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    

008003ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f5:	83 f8 1f             	cmp    $0x1f,%eax
  8003f8:	77 36                	ja     800430 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fa:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003ff:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800402:	89 c2                	mov    %eax,%edx
  800404:	c1 ea 16             	shr    $0x16,%edx
  800407:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040e:	f6 c2 01             	test   $0x1,%dl
  800411:	74 24                	je     800437 <fd_lookup+0x48>
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 0c             	shr    $0xc,%edx
  800418:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	74 1a                	je     80043e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800424:	8b 55 0c             	mov    0xc(%ebp),%edx
  800427:	89 02                	mov    %eax,(%edx)
	return 0;
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	eb 13                	jmp    800443 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 0c                	jmp    800443 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043c:	eb 05                	jmp    800443 <fd_lookup+0x54>
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800443:	c9                   	leave  
  800444:	c3                   	ret    

00800445 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800452:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800458:	74 0d                	je     800467 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 14                	jmp    800475 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800461:	39 0a                	cmp    %ecx,(%edx)
  800463:	75 10                	jne    800475 <dev_lookup+0x30>
  800465:	eb 05                	jmp    80046c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800467:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80046c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	eb 31                	jmp    8004a6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800475:	40                   	inc    %eax
  800476:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	75 e0                	jne    800461 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800481:	a1 04 40 80 00       	mov    0x804004,%eax
  800486:	8b 40 48             	mov    0x48(%eax),%eax
  800489:	83 ec 04             	sub    $0x4,%esp
  80048c:	51                   	push   %ecx
  80048d:	50                   	push   %eax
  80048e:	68 f8 1d 80 00       	push   $0x801df8
  800493:	e8 48 0c 00 00       	call   8010e0 <cprintf>
	*dev = 0;
  800498:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	56                   	push   %esi
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 20             	sub    $0x20,%esp
  8004b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b6:	8a 45 0c             	mov    0xc(%ebp),%al
  8004b9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bc:	56                   	push   %esi
  8004bd:	e8 92 fe ff ff       	call   800354 <fd2num>
  8004c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004c5:	89 14 24             	mov    %edx,(%esp)
  8004c8:	50                   	push   %eax
  8004c9:	e8 21 ff ff ff       	call   8003ef <fd_lookup>
  8004ce:	89 c3                	mov    %eax,%ebx
  8004d0:	83 c4 08             	add    $0x8,%esp
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	78 05                	js     8004dc <fd_close+0x31>
	    || fd != fd2)
  8004d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004da:	74 0d                	je     8004e9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004dc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004e0:	75 48                	jne    80052a <fd_close+0x7f>
  8004e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004e7:	eb 41                	jmp    80052a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 36                	pushl  (%esi)
  8004f2:	e8 4e ff ff ff       	call   800445 <dev_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 1c                	js     80051c <fd_close+0x71>
		if (dev->dev_close)
  800500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800503:	8b 40 10             	mov    0x10(%eax),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	74 0d                	je     800517 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80050a:	83 ec 0c             	sub    $0xc,%esp
  80050d:	56                   	push   %esi
  80050e:	ff d0                	call   *%eax
  800510:	89 c3                	mov    %eax,%ebx
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	eb 05                	jmp    80051c <fd_close+0x71>
		else
			r = 0;
  800517:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	56                   	push   %esi
  800520:	6a 00                	push   $0x0
  800522:	e8 cb fc ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  800527:	83 c4 10             	add    $0x10,%esp
}
  80052a:	89 d8                	mov    %ebx,%eax
  80052c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 aa fe ff ff       	call   8003ef <fd_lookup>
  800545:	83 c4 08             	add    $0x8,%esp
  800548:	85 c0                	test   %eax,%eax
  80054a:	78 10                	js     80055c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	6a 01                	push   $0x1
  800551:	ff 75 f4             	pushl  -0xc(%ebp)
  800554:	e8 52 ff ff ff       	call   8004ab <fd_close>
  800559:	83 c4 10             	add    $0x10,%esp
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <close_all>:

void
close_all(void)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	53                   	push   %ebx
  800562:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	53                   	push   %ebx
  80056e:	e8 c0 ff ff ff       	call   800533 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	43                   	inc    %ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ee                	jne    80056a <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 56 fe ff ff       	call   8003ef <fd_lookup>
  800599:	89 c3                	mov    %eax,%ebx
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 88 c0 00 00 00    	js     800666 <dup+0xe5>
		return r;
	close(newfdnum);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	57                   	push   %edi
  8005aa:	e8 84 ff ff ff       	call   800533 <close>

	newfd = INDEX2FD(newfdnum);
  8005af:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005b5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 a1 fd ff ff       	call   800364 <fd2data>
  8005c3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005c5:	89 34 24             	mov    %esi,(%esp)
  8005c8:	e8 97 fd ff ff       	call   800364 <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 d8                	mov    %ebx,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 37                	je     80061a <dup+0x99>
  8005e3:	89 d8                	mov    %ebx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 26                	je     80061a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	ff 75 d4             	pushl  -0x2c(%ebp)
  800607:	6a 00                	push   $0x0
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 bb fb ff ff       	call   8001cc <sys_page_map>
  800611:	89 c3                	mov    %eax,%ebx
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	85 c0                	test   %eax,%eax
  800618:	78 2d                	js     800647 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061d:	89 c2                	mov    %eax,%edx
  80061f:	c1 ea 0c             	shr    $0xc,%edx
  800622:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800632:	52                   	push   %edx
  800633:	56                   	push   %esi
  800634:	6a 00                	push   $0x0
  800636:	50                   	push   %eax
  800637:	6a 00                	push   $0x0
  800639:	e8 8e fb ff ff       	call   8001cc <sys_page_map>
  80063e:	89 c3                	mov    %eax,%ebx
  800640:	83 c4 20             	add    $0x20,%esp
  800643:	85 c0                	test   %eax,%eax
  800645:	79 1d                	jns    800664 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	56                   	push   %esi
  80064b:	6a 00                	push   $0x0
  80064d:	e8 a0 fb ff ff       	call   8001f2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	ff 75 d4             	pushl  -0x2c(%ebp)
  800658:	6a 00                	push   $0x0
  80065a:	e8 93 fb ff ff       	call   8001f2 <sys_page_unmap>
	return r;
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	eb 02                	jmp    800666 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800664:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800666:	89 d8                	mov    %ebx,%eax
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	53                   	push   %ebx
  800674:	83 ec 14             	sub    $0x14,%esp
  800677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	53                   	push   %ebx
  80067f:	e8 6b fd ff ff       	call   8003ef <fd_lookup>
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	78 67                	js     8006f2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800695:	ff 30                	pushl  (%eax)
  800697:	e8 a9 fd ff ff       	call   800445 <dev_lookup>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	78 4f                	js     8006f2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a6:	8b 50 08             	mov    0x8(%eax),%edx
  8006a9:	83 e2 03             	and    $0x3,%edx
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	75 21                	jne    8006d2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b6:	8b 40 48             	mov    0x48(%eax),%eax
  8006b9:	83 ec 04             	sub    $0x4,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	50                   	push   %eax
  8006be:	68 39 1e 80 00       	push   $0x801e39
  8006c3:	e8 18 0a 00 00       	call   8010e0 <cprintf>
		return -E_INVAL;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d0:	eb 20                	jmp    8006f2 <read+0x82>
	}
	if (!dev->dev_read)
  8006d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d5:	8b 52 08             	mov    0x8(%edx),%edx
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	74 11                	je     8006ed <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	50                   	push   %eax
  8006e6:	ff d2                	call   *%edx
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 05                	jmp    8006f2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	57                   	push   %edi
  8006fb:	56                   	push   %esi
  8006fc:	53                   	push   %ebx
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	8b 7d 08             	mov    0x8(%ebp),%edi
  800703:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800706:	85 f6                	test   %esi,%esi
  800708:	74 31                	je     80073b <readn+0x44>
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f2                	mov    %esi,%edx
  800719:	29 c2                	sub    %eax,%edx
  80071b:	52                   	push   %edx
  80071c:	03 45 0c             	add    0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	57                   	push   %edi
  800721:	e8 4a ff ff ff       	call   800670 <read>
		if (m < 0)
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	85 c0                	test   %eax,%eax
  80072b:	78 17                	js     800744 <readn+0x4d>
			return m;
		if (m == 0)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 11                	je     800742 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800731:	01 c3                	add    %eax,%ebx
  800733:	89 d8                	mov    %ebx,%eax
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x1d>
  800739:	eb 09                	jmp    800744 <readn+0x4d>
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 02                	jmp    800744 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800742:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 14             	sub    $0x14,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	53                   	push   %ebx
  80075b:	e8 8f fc ff ff       	call   8003ef <fd_lookup>
  800760:	83 c4 08             	add    $0x8,%esp
  800763:	85 c0                	test   %eax,%eax
  800765:	78 62                	js     8007c9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800771:	ff 30                	pushl  (%eax)
  800773:	e8 cd fc ff ff       	call   800445 <dev_lookup>
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 4a                	js     8007c9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800782:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800786:	75 21                	jne    8007a9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800788:	a1 04 40 80 00       	mov    0x804004,%eax
  80078d:	8b 40 48             	mov    0x48(%eax),%eax
  800790:	83 ec 04             	sub    $0x4,%esp
  800793:	53                   	push   %ebx
  800794:	50                   	push   %eax
  800795:	68 55 1e 80 00       	push   $0x801e55
  80079a:	e8 41 09 00 00       	call   8010e0 <cprintf>
		return -E_INVAL;
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb 20                	jmp    8007c9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	74 11                	je     8007c4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b3:	83 ec 04             	sub    $0x4,%esp
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	50                   	push   %eax
  8007bd:	ff d2                	call   *%edx
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	eb 05                	jmp    8007c9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 0f fc ff ff       	call   8003ef <fd_lookup>
  8007e0:	83 c4 08             	add    $0x8,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 0e                	js     8007f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 14             	sub    $0x14,%esp
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800801:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	53                   	push   %ebx
  800806:	e8 e4 fb ff ff       	call   8003ef <fd_lookup>
  80080b:	83 c4 08             	add    $0x8,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 5f                	js     800871 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	ff 30                	pushl  (%eax)
  80081e:	e8 22 fc ff ff       	call   800445 <dev_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 47                	js     800871 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800831:	75 21                	jne    800854 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800833:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800838:	8b 40 48             	mov    0x48(%eax),%eax
  80083b:	83 ec 04             	sub    $0x4,%esp
  80083e:	53                   	push   %ebx
  80083f:	50                   	push   %eax
  800840:	68 18 1e 80 00       	push   $0x801e18
  800845:	e8 96 08 00 00       	call   8010e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800852:	eb 1d                	jmp    800871 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800857:	8b 52 18             	mov    0x18(%edx),%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 0e                	je     80086c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	ff 75 0c             	pushl  0xc(%ebp)
  800864:	50                   	push   %eax
  800865:	ff d2                	call   *%edx
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	eb 05                	jmp    800871 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	83 ec 14             	sub    $0x14,%esp
  80087d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	ff 75 08             	pushl  0x8(%ebp)
  800887:	e8 63 fb ff ff       	call   8003ef <fd_lookup>
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 52                	js     8008e5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800899:	50                   	push   %eax
  80089a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089d:	ff 30                	pushl  (%eax)
  80089f:	e8 a1 fb ff ff       	call   800445 <dev_lookup>
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 3a                	js     8008e5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b2:	74 2c                	je     8008e0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008be:	00 00 00 
	stat->st_isdir = 0;
  8008c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c8:	00 00 00 
	stat->st_dev = dev;
  8008cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	53                   	push   %ebx
  8008d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d8:	ff 50 14             	call   *0x14(%eax)
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	eb 05                	jmp    8008e5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	6a 00                	push   $0x0
  8008f4:	ff 75 08             	pushl  0x8(%ebp)
  8008f7:	e8 78 01 00 00       	call   800a74 <open>
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	85 c0                	test   %eax,%eax
  800903:	78 1b                	js     800920 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	50                   	push   %eax
  80090c:	e8 65 ff ff ff       	call   800876 <fstat>
  800911:	89 c6                	mov    %eax,%esi
	close(fd);
  800913:	89 1c 24             	mov    %ebx,(%esp)
  800916:	e8 18 fc ff ff       	call   800533 <close>
	return r;
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	89 f3                	mov    %esi,%ebx
}
  800920:	89 d8                	mov    %ebx,%eax
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	c9                   	leave  
  800928:	c3                   	ret    
  800929:	00 00                	add    %al,(%eax)
	...

0080092c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	89 c3                	mov    %eax,%ebx
  800933:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800935:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80093c:	75 12                	jne    800950 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093e:	83 ec 0c             	sub    $0xc,%esp
  800941:	6a 01                	push   $0x1
  800943:	e8 96 11 00 00       	call   801ade <ipc_find_env>
  800948:	a3 00 40 80 00       	mov    %eax,0x804000
  80094d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800950:	6a 07                	push   $0x7
  800952:	68 00 50 80 00       	push   $0x805000
  800957:	53                   	push   %ebx
  800958:	ff 35 00 40 80 00    	pushl  0x804000
  80095e:	e8 26 11 00 00       	call   801a89 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800963:	83 c4 0c             	add    $0xc,%esp
  800966:	6a 00                	push   $0x0
  800968:	56                   	push   %esi
  800969:	6a 00                	push   $0x0
  80096b:	e8 a4 10 00 00       	call   801a14 <ipc_recv>
}
  800970:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	83 ec 04             	sub    $0x4,%esp
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 05 00 00 00       	mov    $0x5,%eax
  800996:	e8 91 ff ff ff       	call   80092c <fsipc>
  80099b:	85 c0                	test   %eax,%eax
  80099d:	78 2c                	js     8009cb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	68 00 50 80 00       	push   $0x805000
  8009a7:	53                   	push   %ebx
  8009a8:	e8 e9 0c 00 00       	call   801696 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009eb:	e8 3c ff ff ff       	call   80092c <fsipc>
}
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    

008009f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 40 0c             	mov    0xc(%eax),%eax
  800a00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a05:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a10:	b8 03 00 00 00       	mov    $0x3,%eax
  800a15:	e8 12 ff ff ff       	call   80092c <fsipc>
  800a1a:	89 c3                	mov    %eax,%ebx
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	78 4b                	js     800a6b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a20:	39 c6                	cmp    %eax,%esi
  800a22:	73 16                	jae    800a3a <devfile_read+0x48>
  800a24:	68 84 1e 80 00       	push   $0x801e84
  800a29:	68 8b 1e 80 00       	push   $0x801e8b
  800a2e:	6a 7d                	push   $0x7d
  800a30:	68 a0 1e 80 00       	push   $0x801ea0
  800a35:	e8 ce 05 00 00       	call   801008 <_panic>
	assert(r <= PGSIZE);
  800a3a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3f:	7e 16                	jle    800a57 <devfile_read+0x65>
  800a41:	68 ab 1e 80 00       	push   $0x801eab
  800a46:	68 8b 1e 80 00       	push   $0x801e8b
  800a4b:	6a 7e                	push   $0x7e
  800a4d:	68 a0 1e 80 00       	push   $0x801ea0
  800a52:	e8 b1 05 00 00       	call   801008 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a57:	83 ec 04             	sub    $0x4,%esp
  800a5a:	50                   	push   %eax
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	e8 ef 0d 00 00       	call   801857 <memmove>
	return r;
  800a68:	83 c4 10             	add    $0x10,%esp
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	83 ec 1c             	sub    $0x1c,%esp
  800a7c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a7f:	56                   	push   %esi
  800a80:	e8 bf 0b 00 00       	call   801644 <strlen>
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a8d:	7f 65                	jg     800af4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a8f:	83 ec 0c             	sub    $0xc,%esp
  800a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a95:	50                   	push   %eax
  800a96:	e8 e1 f8 ff ff       	call   80037c <fd_alloc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	83 c4 10             	add    $0x10,%esp
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	78 55                	js     800af9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aa4:	83 ec 08             	sub    $0x8,%esp
  800aa7:	56                   	push   %esi
  800aa8:	68 00 50 80 00       	push   $0x805000
  800aad:	e8 e4 0b 00 00       	call   801696 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800abd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac2:	e8 65 fe ff ff       	call   80092c <fsipc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	85 c0                	test   %eax,%eax
  800ace:	79 12                	jns    800ae2 <open+0x6e>
		fd_close(fd, 0);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	6a 00                	push   $0x0
  800ad5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ad8:	e8 ce f9 ff ff       	call   8004ab <fd_close>
		return r;
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	eb 17                	jmp    800af9 <open+0x85>
	}

	return fd2num(fd);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae8:	e8 67 f8 ff ff       	call   800354 <fd2num>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	eb 05                	jmp    800af9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800af4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    
	...

00800b04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	ff 75 08             	pushl  0x8(%ebp)
  800b12:	e8 4d f8 ff ff       	call   800364 <fd2data>
  800b17:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b19:	83 c4 08             	add    $0x8,%esp
  800b1c:	68 b7 1e 80 00       	push   $0x801eb7
  800b21:	56                   	push   %esi
  800b22:	e8 6f 0b 00 00       	call   801696 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b27:	8b 43 04             	mov    0x4(%ebx),%eax
  800b2a:	2b 03                	sub    (%ebx),%eax
  800b2c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b32:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b39:	00 00 00 
	stat->st_dev = &devpipe;
  800b3c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b43:	30 80 00 
	return 0;
}
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b5c:	53                   	push   %ebx
  800b5d:	6a 00                	push   $0x0
  800b5f:	e8 8e f6 ff ff       	call   8001f2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b64:	89 1c 24             	mov    %ebx,(%esp)
  800b67:	e8 f8 f7 ff ff       	call   800364 <fd2data>
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 00                	push   $0x0
  800b72:	e8 7b f6 ff ff       	call   8001f2 <sys_page_unmap>
}
  800b77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 1c             	sub    $0x1c,%esp
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b8f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	57                   	push   %edi
  800b96:	e8 91 0f 00 00       	call   801b2c <pageref>
  800b9b:	89 c6                	mov    %eax,%esi
  800b9d:	83 c4 04             	add    $0x4,%esp
  800ba0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba3:	e8 84 0f 00 00       	call   801b2c <pageref>
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	39 c6                	cmp    %eax,%esi
  800bad:	0f 94 c0             	sete   %al
  800bb0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bb3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bb9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bbc:	39 cb                	cmp    %ecx,%ebx
  800bbe:	75 08                	jne    800bc8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bc8:	83 f8 01             	cmp    $0x1,%eax
  800bcb:	75 bd                	jne    800b8a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bcd:	8b 42 58             	mov    0x58(%edx),%eax
  800bd0:	6a 01                	push   $0x1
  800bd2:	50                   	push   %eax
  800bd3:	53                   	push   %ebx
  800bd4:	68 be 1e 80 00       	push   $0x801ebe
  800bd9:	e8 02 05 00 00       	call   8010e0 <cprintf>
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	eb a7                	jmp    800b8a <_pipeisclosed+0xe>

00800be3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 28             	sub    $0x28,%esp
  800bec:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bef:	56                   	push   %esi
  800bf0:	e8 6f f7 ff ff       	call   800364 <fd2data>
  800bf5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bf7:	83 c4 10             	add    $0x10,%esp
  800bfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bfe:	75 4a                	jne    800c4a <devpipe_write+0x67>
  800c00:	bf 00 00 00 00       	mov    $0x0,%edi
  800c05:	eb 56                	jmp    800c5d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c07:	89 da                	mov    %ebx,%edx
  800c09:	89 f0                	mov    %esi,%eax
  800c0b:	e8 6c ff ff ff       	call   800b7c <_pipeisclosed>
  800c10:	85 c0                	test   %eax,%eax
  800c12:	75 4d                	jne    800c61 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c14:	e8 68 f5 ff ff       	call   800181 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c19:	8b 43 04             	mov    0x4(%ebx),%eax
  800c1c:	8b 13                	mov    (%ebx),%edx
  800c1e:	83 c2 20             	add    $0x20,%edx
  800c21:	39 d0                	cmp    %edx,%eax
  800c23:	73 e2                	jae    800c07 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c25:	89 c2                	mov    %eax,%edx
  800c27:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c2d:	79 05                	jns    800c34 <devpipe_write+0x51>
  800c2f:	4a                   	dec    %edx
  800c30:	83 ca e0             	or     $0xffffffe0,%edx
  800c33:	42                   	inc    %edx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c3a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c3e:	40                   	inc    %eax
  800c3f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c42:	47                   	inc    %edi
  800c43:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c46:	77 07                	ja     800c4f <devpipe_write+0x6c>
  800c48:	eb 13                	jmp    800c5d <devpipe_write+0x7a>
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c52:	8b 13                	mov    (%ebx),%edx
  800c54:	83 c2 20             	add    $0x20,%edx
  800c57:	39 d0                	cmp    %edx,%eax
  800c59:	73 ac                	jae    800c07 <devpipe_write+0x24>
  800c5b:	eb c8                	jmp    800c25 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c5d:	89 f8                	mov    %edi,%eax
  800c5f:	eb 05                	jmp    800c66 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 18             	sub    $0x18,%esp
  800c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c7a:	57                   	push   %edi
  800c7b:	e8 e4 f6 ff ff       	call   800364 <fd2data>
  800c80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c89:	75 44                	jne    800ccf <devpipe_read+0x61>
  800c8b:	be 00 00 00 00       	mov    $0x0,%esi
  800c90:	eb 4f                	jmp    800ce1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	eb 54                	jmp    800cea <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c96:	89 da                	mov    %ebx,%edx
  800c98:	89 f8                	mov    %edi,%eax
  800c9a:	e8 dd fe ff ff       	call   800b7c <_pipeisclosed>
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	75 42                	jne    800ce5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ca3:	e8 d9 f4 ff ff       	call   800181 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ca8:	8b 03                	mov    (%ebx),%eax
  800caa:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cad:	74 e7                	je     800c96 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800caf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cb4:	79 05                	jns    800cbb <devpipe_read+0x4d>
  800cb6:	48                   	dec    %eax
  800cb7:	83 c8 e0             	or     $0xffffffe0,%eax
  800cba:	40                   	inc    %eax
  800cbb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800cc5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	46                   	inc    %esi
  800cc8:	39 75 10             	cmp    %esi,0x10(%ebp)
  800ccb:	77 07                	ja     800cd4 <devpipe_read+0x66>
  800ccd:	eb 12                	jmp    800ce1 <devpipe_read+0x73>
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cd4:	8b 03                	mov    (%ebx),%eax
  800cd6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd9:	75 d4                	jne    800caf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdb:	85 f6                	test   %esi,%esi
  800cdd:	75 b3                	jne    800c92 <devpipe_read+0x24>
  800cdf:	eb b5                	jmp    800c96 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ce1:	89 f0                	mov    %esi,%eax
  800ce3:	eb 05                	jmp    800cea <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 28             	sub    $0x28,%esp
  800cfb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cfe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d01:	50                   	push   %eax
  800d02:	e8 75 f6 ff ff       	call   80037c <fd_alloc>
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	0f 88 24 01 00 00    	js     800e38 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d14:	83 ec 04             	sub    $0x4,%esp
  800d17:	68 07 04 00 00       	push   $0x407
  800d1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d1f:	6a 00                	push   $0x0
  800d21:	e8 82 f4 ff ff       	call   8001a8 <sys_page_alloc>
  800d26:	89 c3                	mov    %eax,%ebx
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	0f 88 05 01 00 00    	js     800e38 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 3d f6 ff ff       	call   80037c <fd_alloc>
  800d3f:	89 c3                	mov    %eax,%ebx
  800d41:	83 c4 10             	add    $0x10,%esp
  800d44:	85 c0                	test   %eax,%eax
  800d46:	0f 88 dc 00 00 00    	js     800e28 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4c:	83 ec 04             	sub    $0x4,%esp
  800d4f:	68 07 04 00 00       	push   $0x407
  800d54:	ff 75 e0             	pushl  -0x20(%ebp)
  800d57:	6a 00                	push   $0x0
  800d59:	e8 4a f4 ff ff       	call   8001a8 <sys_page_alloc>
  800d5e:	89 c3                	mov    %eax,%ebx
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	85 c0                	test   %eax,%eax
  800d65:	0f 88 bd 00 00 00    	js     800e28 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d71:	e8 ee f5 ff ff       	call   800364 <fd2data>
  800d76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d78:	83 c4 0c             	add    $0xc,%esp
  800d7b:	68 07 04 00 00       	push   $0x407
  800d80:	50                   	push   %eax
  800d81:	6a 00                	push   $0x0
  800d83:	e8 20 f4 ff ff       	call   8001a8 <sys_page_alloc>
  800d88:	89 c3                	mov    %eax,%ebx
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	0f 88 83 00 00 00    	js     800e18 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	ff 75 e0             	pushl  -0x20(%ebp)
  800d9b:	e8 c4 f5 ff ff       	call   800364 <fd2data>
  800da0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800da7:	50                   	push   %eax
  800da8:	6a 00                	push   $0x0
  800daa:	56                   	push   %esi
  800dab:	6a 00                	push   $0x0
  800dad:	e8 1a f4 ff ff       	call   8001cc <sys_page_map>
  800db2:	89 c3                	mov    %eax,%ebx
  800db4:	83 c4 20             	add    $0x20,%esp
  800db7:	85 c0                	test   %eax,%eax
  800db9:	78 4f                	js     800e0a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dbb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dd9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800ddb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dde:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800deb:	e8 64 f5 ff ff       	call   800354 <fd2num>
  800df0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800df2:	83 c4 04             	add    $0x4,%esp
  800df5:	ff 75 e0             	pushl  -0x20(%ebp)
  800df8:	e8 57 f5 ff ff       	call   800354 <fd2num>
  800dfd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	eb 2e                	jmp    800e38 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 dd f3 ff ff       	call   8001f2 <sys_page_unmap>
  800e15:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	ff 75 e0             	pushl  -0x20(%ebp)
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 cd f3 ff ff       	call   8001f2 <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 bd f3 ff ff       	call   8001f2 <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4b:	50                   	push   %eax
  800e4c:	ff 75 08             	pushl  0x8(%ebp)
  800e4f:	e8 9b f5 ff ff       	call   8003ef <fd_lookup>
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	78 18                	js     800e73 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e61:	e8 fe f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e66:	89 c2                	mov    %eax,%edx
  800e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6b:	e8 0c fd ff ff       	call   800b7c <_pipeisclosed>
  800e70:	83 c4 10             	add    $0x10,%esp
}
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    
  800e75:	00 00                	add    %al,(%eax)
	...

00800e78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e88:	68 d6 1e 80 00       	push   $0x801ed6
  800e8d:	ff 75 0c             	pushl  0xc(%ebp)
  800e90:	e8 01 08 00 00       	call   801696 <strcpy>
	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ea8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eac:	74 45                	je     800ef3 <devcons_write+0x57>
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ec3:	83 fb 7f             	cmp    $0x7f,%ebx
  800ec6:	76 05                	jbe    800ecd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ec8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	53                   	push   %ebx
  800ed1:	03 45 0c             	add    0xc(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	57                   	push   %edi
  800ed6:	e8 7c 09 00 00       	call   801857 <memmove>
		sys_cputs(buf, m);
  800edb:	83 c4 08             	add    $0x8,%esp
  800ede:	53                   	push   %ebx
  800edf:	57                   	push   %edi
  800ee0:	e8 0c f2 ff ff       	call   8000f1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee5:	01 de                	add    %ebx,%esi
  800ee7:	89 f0                	mov    %esi,%eax
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eef:	72 cd                	jb     800ebe <devcons_write+0x22>
  800ef1:	eb 05                	jmp    800ef8 <devcons_write+0x5c>
  800ef3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef8:	89 f0                	mov    %esi,%eax
  800efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0c:	75 07                	jne    800f15 <devcons_read+0x13>
  800f0e:	eb 25                	jmp    800f35 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f10:	e8 6c f2 ff ff       	call   800181 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f15:	e8 fd f1 ff ff       	call   800117 <sys_cgetc>
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	74 f2                	je     800f10 <devcons_read+0xe>
  800f1e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 1d                	js     800f41 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f24:	83 f8 04             	cmp    $0x4,%eax
  800f27:	74 13                	je     800f3c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	88 10                	mov    %dl,(%eax)
	return 1;
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	eb 0c                	jmp    800f41 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb 05                	jmp    800f41 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f4f:	6a 01                	push   $0x1
  800f51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f54:	50                   	push   %eax
  800f55:	e8 97 f1 ff ff       	call   8000f1 <sys_cputs>
  800f5a:	83 c4 10             	add    $0x10,%esp
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <getchar>:

int
getchar(void)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f65:	6a 01                	push   $0x1
  800f67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6a:	50                   	push   %eax
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 fe f6 ff ff       	call   800670 <read>
	if (r < 0)
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 0f                	js     800f88 <getchar+0x29>
		return r;
	if (r < 1)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 06                	jle    800f83 <getchar+0x24>
		return -E_EOF;
	return c;
  800f7d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f81:	eb 05                	jmp    800f88 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f83:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	ff 75 08             	pushl  0x8(%ebp)
  800f97:	e8 53 f4 ff ff       	call   8003ef <fd_lookup>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 11                	js     800fb4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fac:	39 10                	cmp    %edx,(%eax)
  800fae:	0f 94 c0             	sete   %al
  800fb1:	0f b6 c0             	movzbl %al,%eax
}
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <opencons>:

int
opencons(void)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	e8 b7 f3 ff ff       	call   80037c <fd_alloc>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 3a                	js     801006 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 07 04 00 00       	push   $0x407
  800fd4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 ca f1 ff ff       	call   8001a8 <sys_page_alloc>
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	78 21                	js     801006 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	50                   	push   %eax
  800ffe:	e8 51 f3 ff ff       	call   800354 <fd2num>
  801003:	83 c4 10             	add    $0x10,%esp
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801010:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801016:	e8 42 f1 ff ff       	call   80015d <sys_getenvid>
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	ff 75 0c             	pushl  0xc(%ebp)
  801021:	ff 75 08             	pushl  0x8(%ebp)
  801024:	53                   	push   %ebx
  801025:	50                   	push   %eax
  801026:	68 e4 1e 80 00       	push   $0x801ee4
  80102b:	e8 b0 00 00 00       	call   8010e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801030:	83 c4 18             	add    $0x18,%esp
  801033:	56                   	push   %esi
  801034:	ff 75 10             	pushl  0x10(%ebp)
  801037:	e8 53 00 00 00       	call   80108f <vcprintf>
	cprintf("\n");
  80103c:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801043:	e8 98 00 00 00       	call   8010e0 <cprintf>
  801048:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104b:	cc                   	int3   
  80104c:	eb fd                	jmp    80104b <_panic+0x43>
	...

00801050 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	53                   	push   %ebx
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80105a:	8b 03                	mov    (%ebx),%eax
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801063:	40                   	inc    %eax
  801064:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801066:	3d ff 00 00 00       	cmp    $0xff,%eax
  80106b:	75 1a                	jne    801087 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	68 ff 00 00 00       	push   $0xff
  801075:	8d 43 08             	lea    0x8(%ebx),%eax
  801078:	50                   	push   %eax
  801079:	e8 73 f0 ff ff       	call   8000f1 <sys_cputs>
		b->idx = 0;
  80107e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801084:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801087:	ff 43 04             	incl   0x4(%ebx)
}
  80108a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801098:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109f:	00 00 00 
	b.cnt = 0;
  8010a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ac:	ff 75 0c             	pushl  0xc(%ebp)
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b8:	50                   	push   %eax
  8010b9:	68 50 10 80 00       	push   $0x801050
  8010be:	e8 82 01 00 00       	call   801245 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d2:	50                   	push   %eax
  8010d3:	e8 19 f0 ff ff       	call   8000f1 <sys_cputs>

	return b.cnt;
}
  8010d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e9:	50                   	push   %eax
  8010ea:	ff 75 08             	pushl  0x8(%ebp)
  8010ed:	e8 9d ff ff ff       	call   80108f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 2c             	sub    $0x2c,%esp
  8010fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801100:	89 d6                	mov    %edx,%esi
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	8b 55 0c             	mov    0xc(%ebp),%edx
  801108:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80110e:	8b 45 10             	mov    0x10(%ebp),%eax
  801111:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801114:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801117:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80111a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801121:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801124:	72 0c                	jb     801132 <printnum+0x3e>
  801126:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801129:	76 07                	jbe    801132 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80112b:	4b                   	dec    %ebx
  80112c:	85 db                	test   %ebx,%ebx
  80112e:	7f 31                	jg     801161 <printnum+0x6d>
  801130:	eb 3f                	jmp    801171 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	57                   	push   %edi
  801136:	4b                   	dec    %ebx
  801137:	53                   	push   %ebx
  801138:	50                   	push   %eax
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113f:	ff 75 d0             	pushl  -0x30(%ebp)
  801142:	ff 75 dc             	pushl  -0x24(%ebp)
  801145:	ff 75 d8             	pushl  -0x28(%ebp)
  801148:	e8 23 0a 00 00       	call   801b70 <__udivdi3>
  80114d:	83 c4 18             	add    $0x18,%esp
  801150:	52                   	push   %edx
  801151:	50                   	push   %eax
  801152:	89 f2                	mov    %esi,%edx
  801154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801157:	e8 98 ff ff ff       	call   8010f4 <printnum>
  80115c:	83 c4 20             	add    $0x20,%esp
  80115f:	eb 10                	jmp    801171 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801169:	4b                   	dec    %ebx
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	7f f0                	jg     801161 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	56                   	push   %esi
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117b:	ff 75 d0             	pushl  -0x30(%ebp)
  80117e:	ff 75 dc             	pushl  -0x24(%ebp)
  801181:	ff 75 d8             	pushl  -0x28(%ebp)
  801184:	e8 03 0b 00 00       	call   801c8c <__umoddi3>
  801189:	83 c4 14             	add    $0x14,%esp
  80118c:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  801193:	50                   	push   %eax
  801194:	ff 55 e4             	call   *-0x1c(%ebp)
  801197:	83 c4 10             	add    $0x10,%esp
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	c9                   	leave  
  8011a1:	c3                   	ret    

008011a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a5:	83 fa 01             	cmp    $0x1,%edx
  8011a8:	7e 0e                	jle    8011b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011aa:	8b 10                	mov    (%eax),%edx
  8011ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011af:	89 08                	mov    %ecx,(%eax)
  8011b1:	8b 02                	mov    (%edx),%eax
  8011b3:	8b 52 04             	mov    0x4(%edx),%edx
  8011b6:	eb 22                	jmp    8011da <getuint+0x38>
	else if (lflag)
  8011b8:	85 d2                	test   %edx,%edx
  8011ba:	74 10                	je     8011cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011bc:	8b 10                	mov    (%eax),%edx
  8011be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c1:	89 08                	mov    %ecx,(%eax)
  8011c3:	8b 02                	mov    (%edx),%eax
  8011c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ca:	eb 0e                	jmp    8011da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011cc:	8b 10                	mov    (%eax),%edx
  8011ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d1:	89 08                	mov    %ecx,(%eax)
  8011d3:	8b 02                	mov    (%edx),%eax
  8011d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011df:	83 fa 01             	cmp    $0x1,%edx
  8011e2:	7e 0e                	jle    8011f2 <getint+0x16>
		return va_arg(*ap, long long);
  8011e4:	8b 10                	mov    (%eax),%edx
  8011e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e9:	89 08                	mov    %ecx,(%eax)
  8011eb:	8b 02                	mov    (%edx),%eax
  8011ed:	8b 52 04             	mov    0x4(%edx),%edx
  8011f0:	eb 1a                	jmp    80120c <getint+0x30>
	else if (lflag)
  8011f2:	85 d2                	test   %edx,%edx
  8011f4:	74 0c                	je     801202 <getint+0x26>
		return va_arg(*ap, long);
  8011f6:	8b 10                	mov    (%eax),%edx
  8011f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fb:	89 08                	mov    %ecx,(%eax)
  8011fd:	8b 02                	mov    (%edx),%eax
  8011ff:	99                   	cltd   
  801200:	eb 0a                	jmp    80120c <getint+0x30>
	else
		return va_arg(*ap, int);
  801202:	8b 10                	mov    (%eax),%edx
  801204:	8d 4a 04             	lea    0x4(%edx),%ecx
  801207:	89 08                	mov    %ecx,(%eax)
  801209:	8b 02                	mov    (%edx),%eax
  80120b:	99                   	cltd   
}
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801214:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801217:	8b 10                	mov    (%eax),%edx
  801219:	3b 50 04             	cmp    0x4(%eax),%edx
  80121c:	73 08                	jae    801226 <sprintputch+0x18>
		*b->buf++ = ch;
  80121e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801221:	88 0a                	mov    %cl,(%edx)
  801223:	42                   	inc    %edx
  801224:	89 10                	mov    %edx,(%eax)
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801231:	50                   	push   %eax
  801232:	ff 75 10             	pushl  0x10(%ebp)
  801235:	ff 75 0c             	pushl  0xc(%ebp)
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 05 00 00 00       	call   801245 <vprintfmt>
	va_end(ap);
  801240:	83 c4 10             	add    $0x10,%esp
}
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 2c             	sub    $0x2c,%esp
  80124e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801251:	8b 75 10             	mov    0x10(%ebp),%esi
  801254:	eb 13                	jmp    801269 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801256:	85 c0                	test   %eax,%eax
  801258:	0f 84 6d 03 00 00    	je     8015cb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	57                   	push   %edi
  801262:	50                   	push   %eax
  801263:	ff 55 08             	call   *0x8(%ebp)
  801266:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801269:	0f b6 06             	movzbl (%esi),%eax
  80126c:	46                   	inc    %esi
  80126d:	83 f8 25             	cmp    $0x25,%eax
  801270:	75 e4                	jne    801256 <vprintfmt+0x11>
  801272:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801276:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80127d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801284:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80128b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801290:	eb 28                	jmp    8012ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801292:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801294:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801298:	eb 20                	jmp    8012ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80129c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012a0:	eb 18                	jmp    8012ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012ab:	eb 0d                	jmp    8012ba <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ba:	8a 06                	mov    (%esi),%al
  8012bc:	0f b6 d0             	movzbl %al,%edx
  8012bf:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012c2:	83 e8 23             	sub    $0x23,%eax
  8012c5:	3c 55                	cmp    $0x55,%al
  8012c7:	0f 87 e0 02 00 00    	ja     8015ad <vprintfmt+0x368>
  8012cd:	0f b6 c0             	movzbl %al,%eax
  8012d0:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d7:	83 ea 30             	sub    $0x30,%edx
  8012da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012dd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012e0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012e3:	83 fa 09             	cmp    $0x9,%edx
  8012e6:	77 44                	ja     80132c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	89 de                	mov    %ebx,%esi
  8012ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ee:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012f1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012f5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012f8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8012fb:	83 fb 09             	cmp    $0x9,%ebx
  8012fe:	76 ed                	jbe    8012ed <vprintfmt+0xa8>
  801300:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801303:	eb 29                	jmp    80132e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801305:	8b 45 14             	mov    0x14(%ebp),%eax
  801308:	8d 50 04             	lea    0x4(%eax),%edx
  80130b:	89 55 14             	mov    %edx,0x14(%ebp)
  80130e:	8b 00                	mov    (%eax),%eax
  801310:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801313:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801315:	eb 17                	jmp    80132e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801317:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80131b:	78 85                	js     8012a2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	89 de                	mov    %ebx,%esi
  80131f:	eb 99                	jmp    8012ba <vprintfmt+0x75>
  801321:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801323:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80132a:	eb 8e                	jmp    8012ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80132e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801332:	79 86                	jns    8012ba <vprintfmt+0x75>
  801334:	e9 74 ff ff ff       	jmp    8012ad <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801339:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133a:	89 de                	mov    %ebx,%esi
  80133c:	e9 79 ff ff ff       	jmp    8012ba <vprintfmt+0x75>
  801341:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8d 50 04             	lea    0x4(%eax),%edx
  80134a:	89 55 14             	mov    %edx,0x14(%ebp)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	57                   	push   %edi
  801351:	ff 30                	pushl  (%eax)
  801353:	ff 55 08             	call   *0x8(%ebp)
			break;
  801356:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801359:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135c:	e9 08 ff ff ff       	jmp    801269 <vprintfmt+0x24>
  801361:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801364:	8b 45 14             	mov    0x14(%ebp),%eax
  801367:	8d 50 04             	lea    0x4(%eax),%edx
  80136a:	89 55 14             	mov    %edx,0x14(%ebp)
  80136d:	8b 00                	mov    (%eax),%eax
  80136f:	85 c0                	test   %eax,%eax
  801371:	79 02                	jns    801375 <vprintfmt+0x130>
  801373:	f7 d8                	neg    %eax
  801375:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801377:	83 f8 0f             	cmp    $0xf,%eax
  80137a:	7f 0b                	jg     801387 <vprintfmt+0x142>
  80137c:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  801383:	85 c0                	test   %eax,%eax
  801385:	75 1a                	jne    8013a1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801387:	52                   	push   %edx
  801388:	68 1f 1f 80 00       	push   $0x801f1f
  80138d:	57                   	push   %edi
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 92 fe ff ff       	call   801228 <printfmt>
  801396:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801399:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80139c:	e9 c8 fe ff ff       	jmp    801269 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013a1:	50                   	push   %eax
  8013a2:	68 9d 1e 80 00       	push   $0x801e9d
  8013a7:	57                   	push   %edi
  8013a8:	ff 75 08             	pushl  0x8(%ebp)
  8013ab:	e8 78 fe ff ff       	call   801228 <printfmt>
  8013b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013b6:	e9 ae fe ff ff       	jmp    801269 <vprintfmt+0x24>
  8013bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013be:	89 de                	mov    %ebx,%esi
  8013c0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	8d 50 04             	lea    0x4(%eax),%edx
  8013cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013cf:	8b 00                	mov    (%eax),%eax
  8013d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	75 07                	jne    8013df <vprintfmt+0x19a>
				p = "(null)";
  8013d8:	c7 45 d0 18 1f 80 00 	movl   $0x801f18,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013df:	85 db                	test   %ebx,%ebx
  8013e1:	7e 42                	jle    801425 <vprintfmt+0x1e0>
  8013e3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013e7:	74 3c                	je     801425 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	51                   	push   %ecx
  8013ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f0:	e8 6f 02 00 00       	call   801664 <strnlen>
  8013f5:	29 c3                	sub    %eax,%ebx
  8013f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	85 db                	test   %ebx,%ebx
  8013ff:	7e 24                	jle    801425 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801401:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801405:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801408:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	57                   	push   %edi
  80140f:	53                   	push   %ebx
  801410:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801413:	4e                   	dec    %esi
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 f6                	test   %esi,%esi
  801419:	7f f0                	jg     80140b <vprintfmt+0x1c6>
  80141b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80141e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801425:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801428:	0f be 02             	movsbl (%edx),%eax
  80142b:	85 c0                	test   %eax,%eax
  80142d:	75 47                	jne    801476 <vprintfmt+0x231>
  80142f:	eb 37                	jmp    801468 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801435:	74 16                	je     80144d <vprintfmt+0x208>
  801437:	8d 50 e0             	lea    -0x20(%eax),%edx
  80143a:	83 fa 5e             	cmp    $0x5e,%edx
  80143d:	76 0e                	jbe    80144d <vprintfmt+0x208>
					putch('?', putdat);
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	57                   	push   %edi
  801443:	6a 3f                	push   $0x3f
  801445:	ff 55 08             	call   *0x8(%ebp)
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	eb 0b                	jmp    801458 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	57                   	push   %edi
  801451:	50                   	push   %eax
  801452:	ff 55 08             	call   *0x8(%ebp)
  801455:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801458:	ff 4d e4             	decl   -0x1c(%ebp)
  80145b:	0f be 03             	movsbl (%ebx),%eax
  80145e:	85 c0                	test   %eax,%eax
  801460:	74 03                	je     801465 <vprintfmt+0x220>
  801462:	43                   	inc    %ebx
  801463:	eb 1b                	jmp    801480 <vprintfmt+0x23b>
  801465:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801468:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80146c:	7f 1e                	jg     80148c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801471:	e9 f3 fd ff ff       	jmp    801269 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801476:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801479:	43                   	inc    %ebx
  80147a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80147d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801480:	85 f6                	test   %esi,%esi
  801482:	78 ad                	js     801431 <vprintfmt+0x1ec>
  801484:	4e                   	dec    %esi
  801485:	79 aa                	jns    801431 <vprintfmt+0x1ec>
  801487:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80148a:	eb dc                	jmp    801468 <vprintfmt+0x223>
  80148c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	57                   	push   %edi
  801493:	6a 20                	push   $0x20
  801495:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801498:	4b                   	dec    %ebx
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 db                	test   %ebx,%ebx
  80149e:	7f ef                	jg     80148f <vprintfmt+0x24a>
  8014a0:	e9 c4 fd ff ff       	jmp    801269 <vprintfmt+0x24>
  8014a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014a8:	89 ca                	mov    %ecx,%edx
  8014aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ad:	e8 2a fd ff ff       	call   8011dc <getint>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	78 0a                	js     8014c4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014bf:	e9 b0 00 00 00       	jmp    801574 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	57                   	push   %edi
  8014c8:	6a 2d                	push   $0x2d
  8014ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014cd:	f7 db                	neg    %ebx
  8014cf:	83 d6 00             	adc    $0x0,%esi
  8014d2:	f7 de                	neg    %esi
  8014d4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014dc:	e9 93 00 00 00       	jmp    801574 <vprintfmt+0x32f>
  8014e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e4:	89 ca                	mov    %ecx,%edx
  8014e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e9:	e8 b4 fc ff ff       	call   8011a2 <getuint>
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	89 d6                	mov    %edx,%esi
			base = 10;
  8014f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014f7:	eb 7b                	jmp    801574 <vprintfmt+0x32f>
  8014f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014fc:	89 ca                	mov    %ecx,%edx
  8014fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801501:	e8 d6 fc ff ff       	call   8011dc <getint>
  801506:	89 c3                	mov    %eax,%ebx
  801508:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80150a:	85 d2                	test   %edx,%edx
  80150c:	78 07                	js     801515 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80150e:	b8 08 00 00 00       	mov    $0x8,%eax
  801513:	eb 5f                	jmp    801574 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	57                   	push   %edi
  801519:	6a 2d                	push   $0x2d
  80151b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80151e:	f7 db                	neg    %ebx
  801520:	83 d6 00             	adc    $0x0,%esi
  801523:	f7 de                	neg    %esi
  801525:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801528:	b8 08 00 00 00       	mov    $0x8,%eax
  80152d:	eb 45                	jmp    801574 <vprintfmt+0x32f>
  80152f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	57                   	push   %edi
  801536:	6a 30                	push   $0x30
  801538:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	57                   	push   %edi
  80153f:	6a 78                	push   $0x78
  801541:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 50 04             	lea    0x4(%eax),%edx
  80154a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80154d:	8b 18                	mov    (%eax),%ebx
  80154f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801554:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801557:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80155c:	eb 16                	jmp    801574 <vprintfmt+0x32f>
  80155e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801561:	89 ca                	mov    %ecx,%edx
  801563:	8d 45 14             	lea    0x14(%ebp),%eax
  801566:	e8 37 fc ff ff       	call   8011a2 <getuint>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	89 d6                	mov    %edx,%esi
			base = 16;
  80156f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80157b:	52                   	push   %edx
  80157c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157f:	50                   	push   %eax
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	89 fa                	mov    %edi,%edx
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	e8 68 fb ff ff       	call   8010f4 <printnum>
			break;
  80158c:	83 c4 20             	add    $0x20,%esp
  80158f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801592:	e9 d2 fc ff ff       	jmp    801269 <vprintfmt+0x24>
  801597:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	57                   	push   %edi
  80159e:	52                   	push   %edx
  80159f:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015a8:	e9 bc fc ff ff       	jmp    801269 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	57                   	push   %edi
  8015b1:	6a 25                	push   $0x25
  8015b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	eb 02                	jmp    8015bd <vprintfmt+0x378>
  8015bb:	89 c6                	mov    %eax,%esi
  8015bd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015c0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015c4:	75 f5                	jne    8015bb <vprintfmt+0x376>
  8015c6:	e9 9e fc ff ff       	jmp    801269 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 18             	sub    $0x18,%esp
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	74 26                	je     80161a <vsnprintf+0x47>
  8015f4:	85 d2                	test   %edx,%edx
  8015f6:	7e 29                	jle    801621 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015f8:	ff 75 14             	pushl  0x14(%ebp)
  8015fb:	ff 75 10             	pushl  0x10(%ebp)
  8015fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	68 0e 12 80 00       	push   $0x80120e
  801607:	e8 39 fc ff ff       	call   801245 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80160c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80160f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 0c                	jmp    801626 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80161a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161f:	eb 05                	jmp    801626 <vsnprintf+0x53>
  801621:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80162e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801631:	50                   	push   %eax
  801632:	ff 75 10             	pushl  0x10(%ebp)
  801635:	ff 75 0c             	pushl  0xc(%ebp)
  801638:	ff 75 08             	pushl  0x8(%ebp)
  80163b:	e8 93 ff ff ff       	call   8015d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801640:	c9                   	leave  
  801641:	c3                   	ret    
	...

00801644 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80164a:	80 3a 00             	cmpb   $0x0,(%edx)
  80164d:	74 0e                	je     80165d <strlen+0x19>
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801654:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801655:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801659:	75 f9                	jne    801654 <strlen+0x10>
  80165b:	eb 05                	jmp    801662 <strlen+0x1e>
  80165d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80166d:	85 d2                	test   %edx,%edx
  80166f:	74 17                	je     801688 <strnlen+0x24>
  801671:	80 39 00             	cmpb   $0x0,(%ecx)
  801674:	74 19                	je     80168f <strnlen+0x2b>
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80167b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167c:	39 d0                	cmp    %edx,%eax
  80167e:	74 14                	je     801694 <strnlen+0x30>
  801680:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801684:	75 f5                	jne    80167b <strnlen+0x17>
  801686:	eb 0c                	jmp    801694 <strnlen+0x30>
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
  80168d:	eb 05                	jmp    801694 <strnlen+0x30>
  80168f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016a8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016ab:	42                   	inc    %edx
  8016ac:	84 c9                	test   %cl,%cl
  8016ae:	75 f5                	jne    8016a5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016b0:	5b                   	pop    %ebx
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	53                   	push   %ebx
  8016b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ba:	53                   	push   %ebx
  8016bb:	e8 84 ff ff ff       	call   801644 <strlen>
  8016c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016c9:	50                   	push   %eax
  8016ca:	e8 c7 ff ff ff       	call   801696 <strcpy>
	return dst;
}
  8016cf:	89 d8                	mov    %ebx,%eax
  8016d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	8b 45 08             	mov    0x8(%ebp),%eax
  8016de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e4:	85 f6                	test   %esi,%esi
  8016e6:	74 15                	je     8016fd <strncpy+0x27>
  8016e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016ed:	8a 1a                	mov    (%edx),%bl
  8016ef:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8016f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f8:	41                   	inc    %ecx
  8016f9:	39 ce                	cmp    %ecx,%esi
  8016fb:	77 f0                	ja     8016ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	57                   	push   %edi
  801705:	56                   	push   %esi
  801706:	53                   	push   %ebx
  801707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801710:	85 f6                	test   %esi,%esi
  801712:	74 32                	je     801746 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801714:	83 fe 01             	cmp    $0x1,%esi
  801717:	74 22                	je     80173b <strlcpy+0x3a>
  801719:	8a 0b                	mov    (%ebx),%cl
  80171b:	84 c9                	test   %cl,%cl
  80171d:	74 20                	je     80173f <strlcpy+0x3e>
  80171f:	89 f8                	mov    %edi,%eax
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801726:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801729:	88 08                	mov    %cl,(%eax)
  80172b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80172c:	39 f2                	cmp    %esi,%edx
  80172e:	74 11                	je     801741 <strlcpy+0x40>
  801730:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801734:	42                   	inc    %edx
  801735:	84 c9                	test   %cl,%cl
  801737:	75 f0                	jne    801729 <strlcpy+0x28>
  801739:	eb 06                	jmp    801741 <strlcpy+0x40>
  80173b:	89 f8                	mov    %edi,%eax
  80173d:	eb 02                	jmp    801741 <strlcpy+0x40>
  80173f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801741:	c6 00 00             	movb   $0x0,(%eax)
  801744:	eb 02                	jmp    801748 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801746:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801748:	29 f8                	sub    %edi,%eax
}
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5f                   	pop    %edi
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801755:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801758:	8a 01                	mov    (%ecx),%al
  80175a:	84 c0                	test   %al,%al
  80175c:	74 10                	je     80176e <strcmp+0x1f>
  80175e:	3a 02                	cmp    (%edx),%al
  801760:	75 0c                	jne    80176e <strcmp+0x1f>
		p++, q++;
  801762:	41                   	inc    %ecx
  801763:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801764:	8a 01                	mov    (%ecx),%al
  801766:	84 c0                	test   %al,%al
  801768:	74 04                	je     80176e <strcmp+0x1f>
  80176a:	3a 02                	cmp    (%edx),%al
  80176c:	74 f4                	je     801762 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176e:	0f b6 c0             	movzbl %al,%eax
  801771:	0f b6 12             	movzbl (%edx),%edx
  801774:	29 d0                	sub    %edx,%eax
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	8b 55 08             	mov    0x8(%ebp),%edx
  80177f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801782:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801785:	85 c0                	test   %eax,%eax
  801787:	74 1b                	je     8017a4 <strncmp+0x2c>
  801789:	8a 1a                	mov    (%edx),%bl
  80178b:	84 db                	test   %bl,%bl
  80178d:	74 24                	je     8017b3 <strncmp+0x3b>
  80178f:	3a 19                	cmp    (%ecx),%bl
  801791:	75 20                	jne    8017b3 <strncmp+0x3b>
  801793:	48                   	dec    %eax
  801794:	74 15                	je     8017ab <strncmp+0x33>
		n--, p++, q++;
  801796:	42                   	inc    %edx
  801797:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801798:	8a 1a                	mov    (%edx),%bl
  80179a:	84 db                	test   %bl,%bl
  80179c:	74 15                	je     8017b3 <strncmp+0x3b>
  80179e:	3a 19                	cmp    (%ecx),%bl
  8017a0:	74 f1                	je     801793 <strncmp+0x1b>
  8017a2:	eb 0f                	jmp    8017b3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a9:	eb 05                	jmp    8017b0 <strncmp+0x38>
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b0:	5b                   	pop    %ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b3:	0f b6 02             	movzbl (%edx),%eax
  8017b6:	0f b6 11             	movzbl (%ecx),%edx
  8017b9:	29 d0                	sub    %edx,%eax
  8017bb:	eb f3                	jmp    8017b0 <strncmp+0x38>

008017bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017c6:	8a 10                	mov    (%eax),%dl
  8017c8:	84 d2                	test   %dl,%dl
  8017ca:	74 18                	je     8017e4 <strchr+0x27>
		if (*s == c)
  8017cc:	38 ca                	cmp    %cl,%dl
  8017ce:	75 06                	jne    8017d6 <strchr+0x19>
  8017d0:	eb 17                	jmp    8017e9 <strchr+0x2c>
  8017d2:	38 ca                	cmp    %cl,%dl
  8017d4:	74 13                	je     8017e9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d6:	40                   	inc    %eax
  8017d7:	8a 10                	mov    (%eax),%dl
  8017d9:	84 d2                	test   %dl,%dl
  8017db:	75 f5                	jne    8017d2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e2:	eb 05                	jmp    8017e9 <strchr+0x2c>
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017f4:	8a 10                	mov    (%eax),%dl
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	74 11                	je     80180b <strfind+0x20>
		if (*s == c)
  8017fa:	38 ca                	cmp    %cl,%dl
  8017fc:	75 06                	jne    801804 <strfind+0x19>
  8017fe:	eb 0b                	jmp    80180b <strfind+0x20>
  801800:	38 ca                	cmp    %cl,%dl
  801802:	74 07                	je     80180b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801804:	40                   	inc    %eax
  801805:	8a 10                	mov    (%eax),%dl
  801807:	84 d2                	test   %dl,%dl
  801809:	75 f5                	jne    801800 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
  801816:	8b 45 0c             	mov    0xc(%ebp),%eax
  801819:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80181c:	85 c9                	test   %ecx,%ecx
  80181e:	74 30                	je     801850 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801820:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801826:	75 25                	jne    80184d <memset+0x40>
  801828:	f6 c1 03             	test   $0x3,%cl
  80182b:	75 20                	jne    80184d <memset+0x40>
		c &= 0xFF;
  80182d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801830:	89 d3                	mov    %edx,%ebx
  801832:	c1 e3 08             	shl    $0x8,%ebx
  801835:	89 d6                	mov    %edx,%esi
  801837:	c1 e6 18             	shl    $0x18,%esi
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	c1 e0 10             	shl    $0x10,%eax
  80183f:	09 f0                	or     %esi,%eax
  801841:	09 d0                	or     %edx,%eax
  801843:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801845:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801848:	fc                   	cld    
  801849:	f3 ab                	rep stos %eax,%es:(%edi)
  80184b:	eb 03                	jmp    801850 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184d:	fc                   	cld    
  80184e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801850:	89 f8                	mov    %edi,%eax
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	57                   	push   %edi
  80185b:	56                   	push   %esi
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801865:	39 c6                	cmp    %eax,%esi
  801867:	73 34                	jae    80189d <memmove+0x46>
  801869:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186c:	39 d0                	cmp    %edx,%eax
  80186e:	73 2d                	jae    80189d <memmove+0x46>
		s += n;
		d += n;
  801870:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801873:	f6 c2 03             	test   $0x3,%dl
  801876:	75 1b                	jne    801893 <memmove+0x3c>
  801878:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187e:	75 13                	jne    801893 <memmove+0x3c>
  801880:	f6 c1 03             	test   $0x3,%cl
  801883:	75 0e                	jne    801893 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801885:	83 ef 04             	sub    $0x4,%edi
  801888:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80188e:	fd                   	std    
  80188f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801891:	eb 07                	jmp    80189a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801893:	4f                   	dec    %edi
  801894:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801897:	fd                   	std    
  801898:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189a:	fc                   	cld    
  80189b:	eb 20                	jmp    8018bd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a3:	75 13                	jne    8018b8 <memmove+0x61>
  8018a5:	a8 03                	test   $0x3,%al
  8018a7:	75 0f                	jne    8018b8 <memmove+0x61>
  8018a9:	f6 c1 03             	test   $0x3,%cl
  8018ac:	75 0a                	jne    8018b8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018b1:	89 c7                	mov    %eax,%edi
  8018b3:	fc                   	cld    
  8018b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b6:	eb 05                	jmp    8018bd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b8:	89 c7                	mov    %eax,%edi
  8018ba:	fc                   	cld    
  8018bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018bd:	5e                   	pop    %esi
  8018be:	5f                   	pop    %edi
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c4:	ff 75 10             	pushl  0x10(%ebp)
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	ff 75 08             	pushl  0x8(%ebp)
  8018cd:	e8 85 ff ff ff       	call   801857 <memmove>
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e3:	85 ff                	test   %edi,%edi
  8018e5:	74 32                	je     801919 <memcmp+0x45>
		if (*s1 != *s2)
  8018e7:	8a 03                	mov    (%ebx),%al
  8018e9:	8a 0e                	mov    (%esi),%cl
  8018eb:	38 c8                	cmp    %cl,%al
  8018ed:	74 19                	je     801908 <memcmp+0x34>
  8018ef:	eb 0d                	jmp    8018fe <memcmp+0x2a>
  8018f1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018f5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8018f9:	42                   	inc    %edx
  8018fa:	38 c8                	cmp    %cl,%al
  8018fc:	74 10                	je     80190e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018fe:	0f b6 c0             	movzbl %al,%eax
  801901:	0f b6 c9             	movzbl %cl,%ecx
  801904:	29 c8                	sub    %ecx,%eax
  801906:	eb 16                	jmp    80191e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801908:	4f                   	dec    %edi
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
  80190e:	39 fa                	cmp    %edi,%edx
  801910:	75 df                	jne    8018f1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801912:	b8 00 00 00 00       	mov    $0x0,%eax
  801917:	eb 05                	jmp    80191e <memcmp+0x4a>
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5f                   	pop    %edi
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801929:	89 c2                	mov    %eax,%edx
  80192b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80192e:	39 d0                	cmp    %edx,%eax
  801930:	73 12                	jae    801944 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801932:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801935:	38 08                	cmp    %cl,(%eax)
  801937:	75 06                	jne    80193f <memfind+0x1c>
  801939:	eb 09                	jmp    801944 <memfind+0x21>
  80193b:	38 08                	cmp    %cl,(%eax)
  80193d:	74 05                	je     801944 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193f:	40                   	inc    %eax
  801940:	39 c2                	cmp    %eax,%edx
  801942:	77 f7                	ja     80193b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	57                   	push   %edi
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 55 08             	mov    0x8(%ebp),%edx
  80194f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801952:	eb 01                	jmp    801955 <strtol+0xf>
		s++;
  801954:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801955:	8a 02                	mov    (%edx),%al
  801957:	3c 20                	cmp    $0x20,%al
  801959:	74 f9                	je     801954 <strtol+0xe>
  80195b:	3c 09                	cmp    $0x9,%al
  80195d:	74 f5                	je     801954 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195f:	3c 2b                	cmp    $0x2b,%al
  801961:	75 08                	jne    80196b <strtol+0x25>
		s++;
  801963:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801964:	bf 00 00 00 00       	mov    $0x0,%edi
  801969:	eb 13                	jmp    80197e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196b:	3c 2d                	cmp    $0x2d,%al
  80196d:	75 0a                	jne    801979 <strtol+0x33>
		s++, neg = 1;
  80196f:	8d 52 01             	lea    0x1(%edx),%edx
  801972:	bf 01 00 00 00       	mov    $0x1,%edi
  801977:	eb 05                	jmp    80197e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801979:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197e:	85 db                	test   %ebx,%ebx
  801980:	74 05                	je     801987 <strtol+0x41>
  801982:	83 fb 10             	cmp    $0x10,%ebx
  801985:	75 28                	jne    8019af <strtol+0x69>
  801987:	8a 02                	mov    (%edx),%al
  801989:	3c 30                	cmp    $0x30,%al
  80198b:	75 10                	jne    80199d <strtol+0x57>
  80198d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801991:	75 0a                	jne    80199d <strtol+0x57>
		s += 2, base = 16;
  801993:	83 c2 02             	add    $0x2,%edx
  801996:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199b:	eb 12                	jmp    8019af <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80199d:	85 db                	test   %ebx,%ebx
  80199f:	75 0e                	jne    8019af <strtol+0x69>
  8019a1:	3c 30                	cmp    $0x30,%al
  8019a3:	75 05                	jne    8019aa <strtol+0x64>
		s++, base = 8;
  8019a5:	42                   	inc    %edx
  8019a6:	b3 08                	mov    $0x8,%bl
  8019a8:	eb 05                	jmp    8019af <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b6:	8a 0a                	mov    (%edx),%cl
  8019b8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019bb:	80 fb 09             	cmp    $0x9,%bl
  8019be:	77 08                	ja     8019c8 <strtol+0x82>
			dig = *s - '0';
  8019c0:	0f be c9             	movsbl %cl,%ecx
  8019c3:	83 e9 30             	sub    $0x30,%ecx
  8019c6:	eb 1e                	jmp    8019e6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019c8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019cb:	80 fb 19             	cmp    $0x19,%bl
  8019ce:	77 08                	ja     8019d8 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019d0:	0f be c9             	movsbl %cl,%ecx
  8019d3:	83 e9 57             	sub    $0x57,%ecx
  8019d6:	eb 0e                	jmp    8019e6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019d8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019db:	80 fb 19             	cmp    $0x19,%bl
  8019de:	77 13                	ja     8019f3 <strtol+0xad>
			dig = *s - 'A' + 10;
  8019e0:	0f be c9             	movsbl %cl,%ecx
  8019e3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019e6:	39 f1                	cmp    %esi,%ecx
  8019e8:	7d 0d                	jge    8019f7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019ea:	42                   	inc    %edx
  8019eb:	0f af c6             	imul   %esi,%eax
  8019ee:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019f1:	eb c3                	jmp    8019b6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019f3:	89 c1                	mov    %eax,%ecx
  8019f5:	eb 02                	jmp    8019f9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019f7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8019f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019fd:	74 05                	je     801a04 <strtol+0xbe>
		*endptr = (char *) s;
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a02:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a04:	85 ff                	test   %edi,%edi
  801a06:	74 04                	je     801a0c <strtol+0xc6>
  801a08:	89 c8                	mov    %ecx,%eax
  801a0a:	f7 d8                	neg    %eax
}
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5f                   	pop    %edi
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    
  801a11:	00 00                	add    %al,(%eax)
	...

00801a14 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a22:	85 c0                	test   %eax,%eax
  801a24:	74 0e                	je     801a34 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	50                   	push   %eax
  801a2a:	e8 74 e8 ff ff       	call   8002a3 <sys_ipc_recv>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	eb 10                	jmp    801a44 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	68 00 00 c0 ee       	push   $0xeec00000
  801a3c:	e8 62 e8 ff ff       	call   8002a3 <sys_ipc_recv>
  801a41:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a44:	85 c0                	test   %eax,%eax
  801a46:	75 26                	jne    801a6e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a48:	85 f6                	test   %esi,%esi
  801a4a:	74 0a                	je     801a56 <ipc_recv+0x42>
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 40 74             	mov    0x74(%eax),%eax
  801a54:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a56:	85 db                	test   %ebx,%ebx
  801a58:	74 0a                	je     801a64 <ipc_recv+0x50>
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 40 78             	mov    0x78(%eax),%eax
  801a62:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a64:	a1 04 40 80 00       	mov    0x804004,%eax
  801a69:	8b 40 70             	mov    0x70(%eax),%eax
  801a6c:	eb 14                	jmp    801a82 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a6e:	85 f6                	test   %esi,%esi
  801a70:	74 06                	je     801a78 <ipc_recv+0x64>
  801a72:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a78:	85 db                	test   %ebx,%ebx
  801a7a:	74 06                	je     801a82 <ipc_recv+0x6e>
  801a7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a98:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	75 25                	jne    801ac4 <ipc_send+0x3b>
  801a9f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aa4:	eb 1e                	jmp    801ac4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aa6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa9:	75 07                	jne    801ab2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aab:	e8 d1 e6 ff ff       	call   800181 <sys_yield>
  801ab0:	eb 12                	jmp    801ac4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ab2:	50                   	push   %eax
  801ab3:	68 00 22 80 00       	push   $0x802200
  801ab8:	6a 43                	push   $0x43
  801aba:	68 13 22 80 00       	push   $0x802213
  801abf:	e8 44 f5 ff ff       	call   801008 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	57                   	push   %edi
  801ac7:	ff 75 08             	pushl  0x8(%ebp)
  801aca:	e8 af e7 ff ff       	call   80027e <sys_ipc_try_send>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	75 d0                	jne    801aa6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ae4:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801aea:	74 1a                	je     801b06 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aec:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	c1 e2 07             	shl    $0x7,%edx
  801af6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801afd:	8b 52 50             	mov    0x50(%edx),%edx
  801b00:	39 ca                	cmp    %ecx,%edx
  801b02:	75 18                	jne    801b1c <ipc_find_env+0x3e>
  801b04:	eb 05                	jmp    801b0b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	c1 e2 07             	shl    $0x7,%edx
  801b10:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b17:	8b 40 40             	mov    0x40(%eax),%eax
  801b1a:	eb 0c                	jmp    801b28 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1c:	40                   	inc    %eax
  801b1d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b22:	75 cd                	jne    801af1 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b24:	66 b8 00 00          	mov    $0x0,%ax
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    
	...

00801b2c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b32:	89 c2                	mov    %eax,%edx
  801b34:	c1 ea 16             	shr    $0x16,%edx
  801b37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b3e:	f6 c2 01             	test   $0x1,%dl
  801b41:	74 1e                	je     801b61 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b43:	c1 e8 0c             	shr    $0xc,%eax
  801b46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b4d:	a8 01                	test   $0x1,%al
  801b4f:	74 17                	je     801b68 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b51:	c1 e8 0c             	shr    $0xc,%eax
  801b54:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b5b:	ef 
  801b5c:	0f b7 c0             	movzwl %ax,%eax
  801b5f:	eb 0c                	jmp    801b6d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	eb 05                	jmp    801b6d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    
	...

00801b70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	83 ec 10             	sub    $0x10,%esp
  801b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b7e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b87:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	75 2e                	jne    801bbc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b8e:	39 f1                	cmp    %esi,%ecx
  801b90:	77 5a                	ja     801bec <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b92:	85 c9                	test   %ecx,%ecx
  801b94:	75 0b                	jne    801ba1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b96:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9b:	31 d2                	xor    %edx,%edx
  801b9d:	f7 f1                	div    %ecx
  801b9f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ba1:	31 d2                	xor    %edx,%edx
  801ba3:	89 f0                	mov    %esi,%eax
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba9:	89 f8                	mov    %edi,%eax
  801bab:	f7 f1                	div    %ecx
  801bad:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    
  801bba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bbc:	39 f0                	cmp    %esi,%eax
  801bbe:	77 1c                	ja     801bdc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bc0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 3c                	jne    801c04 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bc8:	39 f0                	cmp    %esi,%eax
  801bca:	0f 82 90 00 00 00    	jb     801c60 <__udivdi3+0xf0>
  801bd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bd3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bd6:	0f 86 84 00 00 00    	jbe    801c60 <__udivdi3+0xf0>
  801bdc:	31 f6                	xor    %esi,%esi
  801bde:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be0:	89 f8                	mov    %edi,%eax
  801be2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    
  801beb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bec:	89 f2                	mov    %esi,%edx
  801bee:	89 f8                	mov    %edi,%eax
  801bf0:	f7 f1                	div    %ecx
  801bf2:	89 c7                	mov    %eax,%edi
  801bf4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bf6:	89 f8                	mov    %edi,%eax
  801bf8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    
  801c01:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c04:	89 f9                	mov    %edi,%ecx
  801c06:	d3 e0                	shl    %cl,%eax
  801c08:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c0b:	b8 20 00 00 00       	mov    $0x20,%eax
  801c10:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c15:	88 c1                	mov    %al,%cl
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c1c:	09 ca                	or     %ecx,%edx
  801c1e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c24:	89 f9                	mov    %edi,%ecx
  801c26:	d3 e2                	shl    %cl,%edx
  801c28:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	88 c1                	mov    %al,%cl
  801c2f:	d3 ea                	shr    %cl,%edx
  801c31:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c34:	89 f2                	mov    %esi,%edx
  801c36:	89 f9                	mov    %edi,%ecx
  801c38:	d3 e2                	shl    %cl,%edx
  801c3a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c3d:	88 c1                	mov    %al,%cl
  801c3f:	d3 ee                	shr    %cl,%esi
  801c41:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c43:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c46:	89 f0                	mov    %esi,%eax
  801c48:	89 ca                	mov    %ecx,%edx
  801c4a:	f7 75 ec             	divl   -0x14(%ebp)
  801c4d:	89 d1                	mov    %edx,%ecx
  801c4f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c51:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c54:	39 d1                	cmp    %edx,%ecx
  801c56:	72 28                	jb     801c80 <__udivdi3+0x110>
  801c58:	74 1a                	je     801c74 <__udivdi3+0x104>
  801c5a:	89 f7                	mov    %esi,%edi
  801c5c:	31 f6                	xor    %esi,%esi
  801c5e:	eb 80                	jmp    801be0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c60:	31 f6                	xor    %esi,%esi
  801c62:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c67:	89 f8                	mov    %edi,%eax
  801c69:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    
  801c72:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c77:	89 f9                	mov    %edi,%ecx
  801c79:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c7b:	39 c2                	cmp    %eax,%edx
  801c7d:	73 db                	jae    801c5a <__udivdi3+0xea>
  801c7f:	90                   	nop
		{
		  q0--;
  801c80:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c83:	31 f6                	xor    %esi,%esi
  801c85:	e9 56 ff ff ff       	jmp    801be0 <__udivdi3+0x70>
	...

00801c8c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	83 ec 20             	sub    $0x20,%esp
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ca0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ca9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cab:	85 ff                	test   %edi,%edi
  801cad:	75 15                	jne    801cc4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801caf:	39 f1                	cmp    %esi,%ecx
  801cb1:	0f 86 99 00 00 00    	jbe    801d50 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cb7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cbd:	83 c4 20             	add    $0x20,%esp
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cc4:	39 f7                	cmp    %esi,%edi
  801cc6:	0f 87 a4 00 00 00    	ja     801d70 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ccc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ccf:	83 f0 1f             	xor    $0x1f,%eax
  801cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cd5:	0f 84 a1 00 00 00    	je     801d7c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cdb:	89 f8                	mov    %edi,%eax
  801cdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ce2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ced:	89 f9                	mov    %edi,%ecx
  801cef:	d3 ea                	shr    %cl,%edx
  801cf1:	09 c2                	or     %eax,%edx
  801cf3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d01:	89 f2                	mov    %esi,%edx
  801d03:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d08:	d3 e0                	shl    %cl,%eax
  801d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d10:	89 f9                	mov    %edi,%ecx
  801d12:	d3 e8                	shr    %cl,%eax
  801d14:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d16:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d18:	89 f2                	mov    %esi,%edx
  801d1a:	f7 75 f0             	divl   -0x10(%ebp)
  801d1d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d1f:	f7 65 f4             	mull   -0xc(%ebp)
  801d22:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d25:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d27:	39 d6                	cmp    %edx,%esi
  801d29:	72 71                	jb     801d9c <__umoddi3+0x110>
  801d2b:	74 7f                	je     801dac <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d30:	29 c8                	sub    %ecx,%eax
  801d32:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d34:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d37:	d3 e8                	shr    %cl,%eax
  801d39:	89 f2                	mov    %esi,%edx
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d3f:	09 d0                	or     %edx,%eax
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d46:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d48:	83 c4 20             	add    $0x20,%esp
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    
  801d4f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d50:	85 c9                	test   %ecx,%ecx
  801d52:	75 0b                	jne    801d5f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d54:	b8 01 00 00 00       	mov    $0x1,%eax
  801d59:	31 d2                	xor    %edx,%edx
  801d5b:	f7 f1                	div    %ecx
  801d5d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d68:	f7 f1                	div    %ecx
  801d6a:	e9 4a ff ff ff       	jmp    801cb9 <__umoddi3+0x2d>
  801d6f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d70:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d72:	83 c4 20             	add    $0x20,%esp
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    
  801d79:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d7c:	39 f7                	cmp    %esi,%edi
  801d7e:	72 05                	jb     801d85 <__umoddi3+0xf9>
  801d80:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d83:	77 0c                	ja     801d91 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d85:	89 f2                	mov    %esi,%edx
  801d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8a:	29 c8                	sub    %ecx,%eax
  801d8c:	19 fa                	sbb    %edi,%edx
  801d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d94:	83 c4 20             	add    $0x20,%esp
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    
  801d9b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d9c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801da4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801da7:	eb 84                	jmp    801d2d <__umoddi3+0xa1>
  801da9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801daf:	72 eb                	jb     801d9c <__umoddi3+0x110>
  801db1:	89 f2                	mov    %esi,%edx
  801db3:	e9 75 ff ff ff       	jmp    801d2d <__umoddi3+0xa1>
