
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
  80003a:	68 70 03 80 00       	push   $0x800370
  80003f:	6a 00                	push   $0x0
  800041:	e8 31 02 00 00       	call   800277 <sys_env_set_pgfault_upcall>
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
  800063:	e8 11 01 00 00       	call   800179 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	89 c2                	mov    %eax,%edx
  80006f:	c1 e2 07             	shl    $0x7,%edx
  800072:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800079:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x31>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	53                   	push   %ebx
  80008d:	56                   	push   %esi
  80008e:	e8 a1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800093:	e8 0c 00 00 00       	call   8000a4 <exit>
  800098:	83 c4 10             	add    $0x10,%esp
}
  80009b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 f3 04 00 00       	call   8005a2 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 9e 00 00 00       	call   800157 <sys_env_destroy>
  8000b9:	83 c4 10             	add    $0x10,%esp
}
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    
	...

008000c0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 1c             	sub    $0x1c,%esp
  8000c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000cf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dd:	cd 30                	int    $0x30
  8000df:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000e5:	74 1c                	je     800103 <syscall+0x43>
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	7e 18                	jle    800103 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	50                   	push   %eax
  8000ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f2:	68 8a 1e 80 00       	push   $0x801e8a
  8000f7:	6a 42                	push   $0x42
  8000f9:	68 a7 1e 80 00       	push   $0x801ea7
  8000fe:	e8 49 0f 00 00       	call   80104c <_panic>

	return ret;
}
  800103:	89 d0                	mov    %edx,%eax
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	6a 00                	push   $0x0
  800119:	ff 75 0c             	pushl  0xc(%ebp)
  80011c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011f:	ba 00 00 00 00       	mov    $0x0,%edx
  800124:	b8 00 00 00 00       	mov    $0x0,%eax
  800129:	e8 92 ff ff ff       	call   8000c0 <syscall>
  80012e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <sys_cgetc>:

int
sys_cgetc(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	b9 00 00 00 00       	mov    $0x0,%ecx
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 01 00 00 00       	mov    $0x1,%eax
  800150:	e8 6b ff ff ff       	call   8000c0 <syscall>
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800168:	ba 01 00 00 00       	mov    $0x1,%edx
  80016d:	b8 03 00 00 00       	mov    $0x3,%eax
  800172:	e8 49 ff ff ff       	call   8000c0 <syscall>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018c:	ba 00 00 00 00       	mov    $0x0,%edx
  800191:	b8 02 00 00 00       	mov    $0x2,%eax
  800196:	e8 25 ff ff ff       	call   8000c0 <syscall>
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_yield>:

void
sys_yield(void)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	6a 00                	push   $0x0
  8001ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ba:	e8 01 ff ff ff       	call   8000c0 <syscall>
  8001bf:	83 c4 10             	add    $0x10,%esp
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ca:	6a 00                	push   $0x0
  8001cc:	6a 00                	push   $0x0
  8001ce:	ff 75 10             	pushl  0x10(%ebp)
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e1:	e8 da fe ff ff       	call   8000c0 <syscall>
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ee:	ff 75 18             	pushl  0x18(%ebp)
  8001f1:	ff 75 14             	pushl  0x14(%ebp)
  8001f4:	ff 75 10             	pushl  0x10(%ebp)
  8001f7:	ff 75 0c             	pushl  0xc(%ebp)
  8001fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fd:	ba 01 00 00 00       	mov    $0x1,%edx
  800202:	b8 05 00 00 00       	mov    $0x5,%eax
  800207:	e8 b4 fe ff ff       	call   8000c0 <syscall>
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800214:	6a 00                	push   $0x0
  800216:	6a 00                	push   $0x0
  800218:	6a 00                	push   $0x0
  80021a:	ff 75 0c             	pushl  0xc(%ebp)
  80021d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800220:	ba 01 00 00 00       	mov    $0x1,%edx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	e8 91 fe ff ff       	call   8000c0 <syscall>
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800237:	6a 00                	push   $0x0
  800239:	6a 00                	push   $0x0
  80023b:	6a 00                	push   $0x0
  80023d:	ff 75 0c             	pushl  0xc(%ebp)
  800240:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800243:	ba 01 00 00 00       	mov    $0x1,%edx
  800248:	b8 08 00 00 00       	mov    $0x8,%eax
  80024d:	e8 6e fe ff ff       	call   8000c0 <syscall>
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80025a:	6a 00                	push   $0x0
  80025c:	6a 00                	push   $0x0
  80025e:	6a 00                	push   $0x0
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800266:	ba 01 00 00 00       	mov    $0x1,%edx
  80026b:	b8 09 00 00 00       	mov    $0x9,%eax
  800270:	e8 4b fe ff ff       	call   8000c0 <syscall>
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80027d:	6a 00                	push   $0x0
  80027f:	6a 00                	push   $0x0
  800281:	6a 00                	push   $0x0
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	ba 01 00 00 00       	mov    $0x1,%edx
  80028e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800293:	e8 28 fe ff ff       	call   8000c0 <syscall>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002a0:	6a 00                	push   $0x0
  8002a2:	ff 75 14             	pushl  0x14(%ebp)
  8002a5:	ff 75 10             	pushl  0x10(%ebp)
  8002a8:	ff 75 0c             	pushl  0xc(%ebp)
  8002ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002b8:	e8 03 fe ff ff       	call   8000c0 <syscall>
}
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002c5:	6a 00                	push   $0x0
  8002c7:	6a 00                	push   $0x0
  8002c9:	6a 00                	push   $0x0
  8002cb:	6a 00                	push   $0x0
  8002cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002da:	e8 e1 fd ff ff       	call   8000c0 <syscall>
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002e7:	6a 00                	push   $0x0
  8002e9:	6a 00                	push   $0x0
  8002eb:	6a 00                	push   $0x0
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002fd:	e8 be fd ff ff       	call   8000c0 <syscall>
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80030a:	6a 00                	push   $0x0
  80030c:	ff 75 14             	pushl  0x14(%ebp)
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800322:	e8 99 fd ff ff       	call   8000c0 <syscall>
} 
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80032f:	6a 00                	push   $0x0
  800331:	6a 00                	push   $0x0
  800333:	6a 00                	push   $0x0
  800335:	6a 00                	push   $0x0
  800337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033a:	ba 00 00 00 00       	mov    $0x0,%edx
  80033f:	b8 11 00 00 00       	mov    $0x11,%eax
  800344:	e8 77 fd ff ff       	call   8000c0 <syscall>
}
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <sys_getpid>:

envid_t
sys_getpid(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800351:	6a 00                	push   $0x0
  800353:	6a 00                	push   $0x0
  800355:	6a 00                	push   $0x0
  800357:	6a 00                	push   $0x0
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	b8 10 00 00 00       	mov    $0x10,%eax
  800368:	e8 53 fd ff ff       	call   8000c0 <syscall>
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    
	...

00800370 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800370:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800371:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800376:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800378:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80037b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80037f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800382:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800386:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80038a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80038c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80038f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800390:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800393:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800394:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800395:	c3                   	ret    
	...

00800398 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
  80039e:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003ab:	ff 75 08             	pushl  0x8(%ebp)
  8003ae:	e8 e5 ff ff ff       	call   800398 <fd2num>
  8003b3:	83 c4 04             	add    $0x4,%esp
  8003b6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8003bb:	c1 e0 0c             	shl    $0xc,%eax
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	53                   	push   %ebx
  8003c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8003cc:	a8 01                	test   $0x1,%al
  8003ce:	74 34                	je     800404 <fd_alloc+0x44>
  8003d0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003d5:	a8 01                	test   $0x1,%al
  8003d7:	74 32                	je     80040b <fd_alloc+0x4b>
  8003d9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003de:	89 c1                	mov    %eax,%ecx
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1f                	je     800410 <fd_alloc+0x50>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	75 17                	jne    800419 <fd_alloc+0x59>
  800402:	eb 0c                	jmp    800410 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800404:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800409:	eb 05                	jmp    800410 <fd_alloc+0x50>
  80040b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800410:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	eb 17                	jmp    800430 <fd_alloc+0x70>
  800419:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80041e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800423:	75 b9                	jne    8003de <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800425:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80042b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800430:	5b                   	pop    %ebx
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800439:	83 f8 1f             	cmp    $0x1f,%eax
  80043c:	77 36                	ja     800474 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800443:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800446:	89 c2                	mov    %eax,%edx
  800448:	c1 ea 16             	shr    $0x16,%edx
  80044b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800452:	f6 c2 01             	test   $0x1,%dl
  800455:	74 24                	je     80047b <fd_lookup+0x48>
  800457:	89 c2                	mov    %eax,%edx
  800459:	c1 ea 0c             	shr    $0xc,%edx
  80045c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800463:	f6 c2 01             	test   $0x1,%dl
  800466:	74 1a                	je     800482 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800468:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046b:	89 02                	mov    %eax,(%edx)
	return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 13                	jmp    800487 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800479:	eb 0c                	jmp    800487 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80047b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800480:	eb 05                	jmp    800487 <fd_lookup+0x54>
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	53                   	push   %ebx
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800496:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80049c:	74 0d                	je     8004ab <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	eb 14                	jmp    8004b9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8004a5:	39 0a                	cmp    %ecx,(%edx)
  8004a7:	75 10                	jne    8004b9 <dev_lookup+0x30>
  8004a9:	eb 05                	jmp    8004b0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ab:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8004b0:	89 13                	mov    %edx,(%ebx)
			return 0;
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	eb 31                	jmp    8004ea <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004b9:	40                   	inc    %eax
  8004ba:	8b 14 85 34 1f 80 00 	mov    0x801f34(,%eax,4),%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	75 e0                	jne    8004a5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ca:	8b 40 48             	mov    0x48(%eax),%eax
  8004cd:	83 ec 04             	sub    $0x4,%esp
  8004d0:	51                   	push   %ecx
  8004d1:	50                   	push   %eax
  8004d2:	68 b8 1e 80 00       	push   $0x801eb8
  8004d7:	e8 48 0c 00 00       	call   801124 <cprintf>
	*dev = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 20             	sub    $0x20,%esp
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8a 45 0c             	mov    0xc(%ebp),%al
  8004fd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800500:	56                   	push   %esi
  800501:	e8 92 fe ff ff       	call   800398 <fd2num>
  800506:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800509:	89 14 24             	mov    %edx,(%esp)
  80050c:	50                   	push   %eax
  80050d:	e8 21 ff ff ff       	call   800433 <fd_lookup>
  800512:	89 c3                	mov    %eax,%ebx
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	85 c0                	test   %eax,%eax
  800519:	78 05                	js     800520 <fd_close+0x31>
	    || fd != fd2)
  80051b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80051e:	74 0d                	je     80052d <fd_close+0x3e>
		return (must_exist ? r : 0);
  800520:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800524:	75 48                	jne    80056e <fd_close+0x7f>
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
  80052b:	eb 41                	jmp    80056e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800533:	50                   	push   %eax
  800534:	ff 36                	pushl  (%esi)
  800536:	e8 4e ff ff ff       	call   800489 <dev_lookup>
  80053b:	89 c3                	mov    %eax,%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 c0                	test   %eax,%eax
  800542:	78 1c                	js     800560 <fd_close+0x71>
		if (dev->dev_close)
  800544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800547:	8b 40 10             	mov    0x10(%eax),%eax
  80054a:	85 c0                	test   %eax,%eax
  80054c:	74 0d                	je     80055b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80054e:	83 ec 0c             	sub    $0xc,%esp
  800551:	56                   	push   %esi
  800552:	ff d0                	call   *%eax
  800554:	89 c3                	mov    %eax,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 05                	jmp    800560 <fd_close+0x71>
		else
			r = 0;
  80055b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	56                   	push   %esi
  800564:	6a 00                	push   $0x0
  800566:	e8 a3 fc ff ff       	call   80020e <sys_page_unmap>
	return r;
  80056b:	83 c4 10             	add    $0x10,%esp
}
  80056e:	89 d8                	mov    %ebx,%eax
  800570:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800573:	5b                   	pop    %ebx
  800574:	5e                   	pop    %esi
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80057d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800580:	50                   	push   %eax
  800581:	ff 75 08             	pushl  0x8(%ebp)
  800584:	e8 aa fe ff ff       	call   800433 <fd_lookup>
  800589:	83 c4 08             	add    $0x8,%esp
  80058c:	85 c0                	test   %eax,%eax
  80058e:	78 10                	js     8005a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	6a 01                	push   $0x1
  800595:	ff 75 f4             	pushl  -0xc(%ebp)
  800598:	e8 52 ff ff ff       	call   8004ef <fd_close>
  80059d:	83 c4 10             	add    $0x10,%esp
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <close_all>:

void
close_all(void)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ae:	83 ec 0c             	sub    $0xc,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	e8 c0 ff ff ff       	call   800577 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005b7:	43                   	inc    %ebx
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	83 fb 20             	cmp    $0x20,%ebx
  8005be:	75 ee                	jne    8005ae <close_all+0xc>
		close(i);
}
  8005c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005c3:	c9                   	leave  
  8005c4:	c3                   	ret    

008005c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  8005c8:	57                   	push   %edi
  8005c9:	56                   	push   %esi
  8005ca:	53                   	push   %ebx
  8005cb:	83 ec 2c             	sub    $0x2c,%esp
  8005ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	e8 56 fe ff ff       	call   800433 <fd_lookup>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 08             	add    $0x8,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	0f 88 c0 00 00 00    	js     8006aa <dup+0xe5>
		return r;
	close(newfdnum);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	57                   	push   %edi
  8005ee:	e8 84 ff ff ff       	call   800577 <close>

	newfd = INDEX2FD(newfdnum);
  8005f3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005f9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005fc:	83 c4 04             	add    $0x4,%esp
  8005ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800602:	e8 a1 fd ff ff       	call   8003a8 <fd2data>
  800607:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800609:	89 34 24             	mov    %esi,(%esp)
  80060c:	e8 97 fd ff ff       	call   8003a8 <fd2data>
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800617:	89 d8                	mov    %ebx,%eax
  800619:	c1 e8 16             	shr    $0x16,%eax
  80061c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800623:	a8 01                	test   $0x1,%al
  800625:	74 37                	je     80065e <dup+0x99>
  800627:	89 d8                	mov    %ebx,%eax
  800629:	c1 e8 0c             	shr    $0xc,%eax
  80062c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800633:	f6 c2 01             	test   $0x1,%dl
  800636:	74 26                	je     80065e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800638:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	25 07 0e 00 00       	and    $0xe07,%eax
  800647:	50                   	push   %eax
  800648:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064b:	6a 00                	push   $0x0
  80064d:	53                   	push   %ebx
  80064e:	6a 00                	push   $0x0
  800650:	e8 93 fb ff ff       	call   8001e8 <sys_page_map>
  800655:	89 c3                	mov    %eax,%ebx
  800657:	83 c4 20             	add    $0x20,%esp
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 2d                	js     80068b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800661:	89 c2                	mov    %eax,%edx
  800663:	c1 ea 0c             	shr    $0xc,%edx
  800666:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800676:	52                   	push   %edx
  800677:	56                   	push   %esi
  800678:	6a 00                	push   $0x0
  80067a:	50                   	push   %eax
  80067b:	6a 00                	push   $0x0
  80067d:	e8 66 fb ff ff       	call   8001e8 <sys_page_map>
  800682:	89 c3                	mov    %eax,%ebx
  800684:	83 c4 20             	add    $0x20,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	79 1d                	jns    8006a8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	56                   	push   %esi
  80068f:	6a 00                	push   $0x0
  800691:	e8 78 fb ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	ff 75 d4             	pushl  -0x2c(%ebp)
  80069c:	6a 00                	push   $0x0
  80069e:	e8 6b fb ff ff       	call   80020e <sys_page_unmap>
	return r;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 02                	jmp    8006aa <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006a8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006aa:	89 d8                	mov    %ebx,%eax
  8006ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006af:	5b                   	pop    %ebx
  8006b0:	5e                   	pop    %esi
  8006b1:	5f                   	pop    %edi
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 14             	sub    $0x14,%esp
  8006bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	53                   	push   %ebx
  8006c3:	e8 6b fd ff ff       	call   800433 <fd_lookup>
  8006c8:	83 c4 08             	add    $0x8,%esp
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	78 67                	js     800736 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d9:	ff 30                	pushl  (%eax)
  8006db:	e8 a9 fd ff ff       	call   800489 <dev_lookup>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 4f                	js     800736 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ea:	8b 50 08             	mov    0x8(%eax),%edx
  8006ed:	83 e2 03             	and    $0x3,%edx
  8006f0:	83 fa 01             	cmp    $0x1,%edx
  8006f3:	75 21                	jne    800716 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8006fa:	8b 40 48             	mov    0x48(%eax),%eax
  8006fd:	83 ec 04             	sub    $0x4,%esp
  800700:	53                   	push   %ebx
  800701:	50                   	push   %eax
  800702:	68 f9 1e 80 00       	push   $0x801ef9
  800707:	e8 18 0a 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800714:	eb 20                	jmp    800736 <read+0x82>
	}
	if (!dev->dev_read)
  800716:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800719:	8b 52 08             	mov    0x8(%edx),%edx
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 11                	je     800731 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800720:	83 ec 04             	sub    $0x4,%esp
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	50                   	push   %eax
  80072a:	ff d2                	call   *%edx
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 05                	jmp    800736 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800731:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	57                   	push   %edi
  80073f:	56                   	push   %esi
  800740:	53                   	push   %ebx
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	8b 7d 08             	mov    0x8(%ebp),%edi
  800747:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074a:	85 f6                	test   %esi,%esi
  80074c:	74 31                	je     80077f <readn+0x44>
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800758:	83 ec 04             	sub    $0x4,%esp
  80075b:	89 f2                	mov    %esi,%edx
  80075d:	29 c2                	sub    %eax,%edx
  80075f:	52                   	push   %edx
  800760:	03 45 0c             	add    0xc(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	57                   	push   %edi
  800765:	e8 4a ff ff ff       	call   8006b4 <read>
		if (m < 0)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 17                	js     800788 <readn+0x4d>
			return m;
		if (m == 0)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 11                	je     800786 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800775:	01 c3                	add    %eax,%ebx
  800777:	89 d8                	mov    %ebx,%eax
  800779:	39 f3                	cmp    %esi,%ebx
  80077b:	72 db                	jb     800758 <readn+0x1d>
  80077d:	eb 09                	jmp    800788 <readn+0x4d>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
  800784:	eb 02                	jmp    800788 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800786:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5f                   	pop    %edi
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 14             	sub    $0x14,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	53                   	push   %ebx
  80079f:	e8 8f fc ff ff       	call   800433 <fd_lookup>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 62                	js     80080d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b5:	ff 30                	pushl  (%eax)
  8007b7:	e8 cd fc ff ff       	call   800489 <dev_lookup>
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 4a                	js     80080d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ca:	75 21                	jne    8007ed <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d1:	8b 40 48             	mov    0x48(%eax),%eax
  8007d4:	83 ec 04             	sub    $0x4,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	50                   	push   %eax
  8007d9:	68 15 1f 80 00       	push   $0x801f15
  8007de:	e8 41 09 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007eb:	eb 20                	jmp    80080d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	74 11                	je     800808 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	50                   	push   %eax
  800801:	ff d2                	call   *%edx
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	eb 05                	jmp    80080d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <seek>:

int
seek(int fdnum, off_t offset)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800818:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80081b:	50                   	push   %eax
  80081c:	ff 75 08             	pushl  0x8(%ebp)
  80081f:	e8 0f fc ff ff       	call   800433 <fd_lookup>
  800824:	83 c4 08             	add    $0x8,%esp
  800827:	85 c0                	test   %eax,%eax
  800829:	78 0e                	js     800839 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80082b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	53                   	push   %ebx
  80084a:	e8 e4 fb ff ff       	call   800433 <fd_lookup>
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	85 c0                	test   %eax,%eax
  800854:	78 5f                	js     8008b5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800860:	ff 30                	pushl  (%eax)
  800862:	e8 22 fc ff ff       	call   800489 <dev_lookup>
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 47                	js     8008b5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800875:	75 21                	jne    800898 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800877:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80087c:	8b 40 48             	mov    0x48(%eax),%eax
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	50                   	push   %eax
  800884:	68 d8 1e 80 00       	push   $0x801ed8
  800889:	e8 96 08 00 00       	call   801124 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800896:	eb 1d                	jmp    8008b5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800898:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089b:	8b 52 18             	mov    0x18(%edx),%edx
  80089e:	85 d2                	test   %edx,%edx
  8008a0:	74 0e                	je     8008b0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	ff 75 0c             	pushl  0xc(%ebp)
  8008a8:	50                   	push   %eax
  8008a9:	ff d2                	call   *%edx
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	eb 05                	jmp    8008b5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 14             	sub    $0x14,%esp
  8008c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c7:	50                   	push   %eax
  8008c8:	ff 75 08             	pushl  0x8(%ebp)
  8008cb:	e8 63 fb ff ff       	call   800433 <fd_lookup>
  8008d0:	83 c4 08             	add    $0x8,%esp
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 52                	js     800929 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008dd:	50                   	push   %eax
  8008de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e1:	ff 30                	pushl  (%eax)
  8008e3:	e8 a1 fb ff ff       	call   800489 <dev_lookup>
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	78 3a                	js     800929 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008f6:	74 2c                	je     800924 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800902:	00 00 00 
	stat->st_isdir = 0;
  800905:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80090c:	00 00 00 
	stat->st_dev = dev;
  80090f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	ff 75 f0             	pushl  -0x10(%ebp)
  80091c:	ff 50 14             	call   *0x14(%eax)
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	eb 05                	jmp    800929 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800924:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	6a 00                	push   $0x0
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 78 01 00 00       	call   800ab8 <open>
  800940:	89 c3                	mov    %eax,%ebx
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	85 c0                	test   %eax,%eax
  800947:	78 1b                	js     800964 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	ff 75 0c             	pushl  0xc(%ebp)
  80094f:	50                   	push   %eax
  800950:	e8 65 ff ff ff       	call   8008ba <fstat>
  800955:	89 c6                	mov    %eax,%esi
	close(fd);
  800957:	89 1c 24             	mov    %ebx,(%esp)
  80095a:	e8 18 fc ff ff       	call   800577 <close>
	return r;
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	89 f3                	mov    %esi,%ebx
}
  800964:	89 d8                	mov    %ebx,%eax
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    
  80096d:	00 00                	add    %al,(%eax)
	...

00800970 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	89 c3                	mov    %eax,%ebx
  800977:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800979:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800980:	75 12                	jne    800994 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800982:	83 ec 0c             	sub    $0xc,%esp
  800985:	6a 01                	push   $0x1
  800987:	e8 02 12 00 00       	call   801b8e <ipc_find_env>
  80098c:	a3 00 40 80 00       	mov    %eax,0x804000
  800991:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800994:	6a 07                	push   $0x7
  800996:	68 00 50 80 00       	push   $0x805000
  80099b:	53                   	push   %ebx
  80099c:	ff 35 00 40 80 00    	pushl  0x804000
  8009a2:	e8 92 11 00 00       	call   801b39 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8009a7:	83 c4 0c             	add    $0xc,%esp
  8009aa:	6a 00                	push   $0x0
  8009ac:	56                   	push   %esi
  8009ad:	6a 00                	push   $0x0
  8009af:	e8 10 11 00 00       	call   801ac4 <ipc_recv>
}
  8009b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 04             	sub    $0x4,%esp
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8009d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009da:	e8 91 ff ff ff       	call   800970 <fsipc>
  8009df:	85 c0                	test   %eax,%eax
  8009e1:	78 2c                	js     800a0f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e3:	83 ec 08             	sub    $0x8,%esp
  8009e6:	68 00 50 80 00       	push   $0x805000
  8009eb:	53                   	push   %ebx
  8009ec:	e8 e9 0c 00 00       	call   8016da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fc:	a1 84 50 80 00       	mov    0x805084,%eax
  800a01:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a20:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a2f:	e8 3c ff ff ff       	call   800970 <fsipc>
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 40 0c             	mov    0xc(%eax),%eax
  800a44:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a49:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	b8 03 00 00 00       	mov    $0x3,%eax
  800a59:	e8 12 ff ff ff       	call   800970 <fsipc>
  800a5e:	89 c3                	mov    %eax,%ebx
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 4b                	js     800aaf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a64:	39 c6                	cmp    %eax,%esi
  800a66:	73 16                	jae    800a7e <devfile_read+0x48>
  800a68:	68 44 1f 80 00       	push   $0x801f44
  800a6d:	68 4b 1f 80 00       	push   $0x801f4b
  800a72:	6a 7d                	push   $0x7d
  800a74:	68 60 1f 80 00       	push   $0x801f60
  800a79:	e8 ce 05 00 00       	call   80104c <_panic>
	assert(r <= PGSIZE);
  800a7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a83:	7e 16                	jle    800a9b <devfile_read+0x65>
  800a85:	68 6b 1f 80 00       	push   $0x801f6b
  800a8a:	68 4b 1f 80 00       	push   $0x801f4b
  800a8f:	6a 7e                	push   $0x7e
  800a91:	68 60 1f 80 00       	push   $0x801f60
  800a96:	e8 b1 05 00 00       	call   80104c <_panic>
	memmove(buf, &fsipcbuf, r);
  800a9b:	83 ec 04             	sub    $0x4,%esp
  800a9e:	50                   	push   %eax
  800a9f:	68 00 50 80 00       	push   $0x805000
  800aa4:	ff 75 0c             	pushl  0xc(%ebp)
  800aa7:	e8 ef 0d 00 00       	call   80189b <memmove>
	return r;
  800aac:	83 c4 10             	add    $0x10,%esp
}
  800aaf:	89 d8                	mov    %ebx,%eax
  800ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	83 ec 1c             	sub    $0x1c,%esp
  800ac0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac3:	56                   	push   %esi
  800ac4:	e8 bf 0b 00 00       	call   801688 <strlen>
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad1:	7f 65                	jg     800b38 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad9:	50                   	push   %eax
  800ada:	e8 e1 f8 ff ff       	call   8003c0 <fd_alloc>
  800adf:	89 c3                	mov    %eax,%ebx
  800ae1:	83 c4 10             	add    $0x10,%esp
  800ae4:	85 c0                	test   %eax,%eax
  800ae6:	78 55                	js     800b3d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	56                   	push   %esi
  800aec:	68 00 50 80 00       	push   $0x805000
  800af1:	e8 e4 0b 00 00       	call   8016da <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	e8 65 fe ff ff       	call   800970 <fsipc>
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	85 c0                	test   %eax,%eax
  800b12:	79 12                	jns    800b26 <open+0x6e>
		fd_close(fd, 0);
  800b14:	83 ec 08             	sub    $0x8,%esp
  800b17:	6a 00                	push   $0x0
  800b19:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1c:	e8 ce f9 ff ff       	call   8004ef <fd_close>
		return r;
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	eb 17                	jmp    800b3d <open+0x85>
	}

	return fd2num(fd);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2c:	e8 67 f8 ff ff       	call   800398 <fd2num>
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	eb 05                	jmp    800b3d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b38:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3d:	89 d8                	mov    %ebx,%eax
  800b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    
	...

00800b48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 08             	pushl  0x8(%ebp)
  800b56:	e8 4d f8 ff ff       	call   8003a8 <fd2data>
  800b5b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b5d:	83 c4 08             	add    $0x8,%esp
  800b60:	68 77 1f 80 00       	push   $0x801f77
  800b65:	56                   	push   %esi
  800b66:	e8 6f 0b 00 00       	call   8016da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6b:	8b 43 04             	mov    0x4(%ebx),%eax
  800b6e:	2b 03                	sub    (%ebx),%eax
  800b70:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b76:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b7d:	00 00 00 
	stat->st_dev = &devpipe;
  800b80:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b87:	30 80 00 
	return 0;
}
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba0:	53                   	push   %ebx
  800ba1:	6a 00                	push   $0x0
  800ba3:	e8 66 f6 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba8:	89 1c 24             	mov    %ebx,(%esp)
  800bab:	e8 f8 f7 ff ff       	call   8003a8 <fd2data>
  800bb0:	83 c4 08             	add    $0x8,%esp
  800bb3:	50                   	push   %eax
  800bb4:	6a 00                	push   $0x0
  800bb6:	e8 53 f6 ff ff       	call   80020e <sys_page_unmap>
}
  800bbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 1c             	sub    $0x1c,%esp
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bce:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	57                   	push   %edi
  800bda:	e8 fd 0f 00 00       	call   801bdc <pageref>
  800bdf:	89 c6                	mov    %eax,%esi
  800be1:	83 c4 04             	add    $0x4,%esp
  800be4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be7:	e8 f0 0f 00 00       	call   801bdc <pageref>
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	39 c6                	cmp    %eax,%esi
  800bf1:	0f 94 c0             	sete   %al
  800bf4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bf7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bfd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c00:	39 cb                	cmp    %ecx,%ebx
  800c02:	75 08                	jne    800c0c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800c0c:	83 f8 01             	cmp    $0x1,%eax
  800c0f:	75 bd                	jne    800bce <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c11:	8b 42 58             	mov    0x58(%edx),%eax
  800c14:	6a 01                	push   $0x1
  800c16:	50                   	push   %eax
  800c17:	53                   	push   %ebx
  800c18:	68 7e 1f 80 00       	push   $0x801f7e
  800c1d:	e8 02 05 00 00       	call   801124 <cprintf>
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	eb a7                	jmp    800bce <_pipeisclosed+0xe>

00800c27 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 28             	sub    $0x28,%esp
  800c30:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c33:	56                   	push   %esi
  800c34:	e8 6f f7 ff ff       	call   8003a8 <fd2data>
  800c39:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c42:	75 4a                	jne    800c8e <devpipe_write+0x67>
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
  800c49:	eb 56                	jmp    800ca1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c4b:	89 da                	mov    %ebx,%edx
  800c4d:	89 f0                	mov    %esi,%eax
  800c4f:	e8 6c ff ff ff       	call   800bc0 <_pipeisclosed>
  800c54:	85 c0                	test   %eax,%eax
  800c56:	75 4d                	jne    800ca5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c58:	e8 40 f5 ff ff       	call   80019d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c5d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c60:	8b 13                	mov    (%ebx),%edx
  800c62:	83 c2 20             	add    $0x20,%edx
  800c65:	39 d0                	cmp    %edx,%eax
  800c67:	73 e2                	jae    800c4b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c71:	79 05                	jns    800c78 <devpipe_write+0x51>
  800c73:	4a                   	dec    %edx
  800c74:	83 ca e0             	or     $0xffffffe0,%edx
  800c77:	42                   	inc    %edx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c82:	40                   	inc    %eax
  800c83:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c86:	47                   	inc    %edi
  800c87:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c8a:	77 07                	ja     800c93 <devpipe_write+0x6c>
  800c8c:	eb 13                	jmp    800ca1 <devpipe_write+0x7a>
  800c8e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c93:	8b 43 04             	mov    0x4(%ebx),%eax
  800c96:	8b 13                	mov    (%ebx),%edx
  800c98:	83 c2 20             	add    $0x20,%edx
  800c9b:	39 d0                	cmp    %edx,%eax
  800c9d:	73 ac                	jae    800c4b <devpipe_write+0x24>
  800c9f:	eb c8                	jmp    800c69 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca1:	89 f8                	mov    %edi,%eax
  800ca3:	eb 05                	jmp    800caa <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 18             	sub    $0x18,%esp
  800cbb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cbe:	57                   	push   %edi
  800cbf:	e8 e4 f6 ff ff       	call   8003a8 <fd2data>
  800cc4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ccd:	75 44                	jne    800d13 <devpipe_read+0x61>
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	eb 4f                	jmp    800d25 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800cd6:	89 f0                	mov    %esi,%eax
  800cd8:	eb 54                	jmp    800d2e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cda:	89 da                	mov    %ebx,%edx
  800cdc:	89 f8                	mov    %edi,%eax
  800cde:	e8 dd fe ff ff       	call   800bc0 <_pipeisclosed>
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	75 42                	jne    800d29 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce7:	e8 b1 f4 ff ff       	call   80019d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cec:	8b 03                	mov    (%ebx),%eax
  800cee:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cf1:	74 e7                	je     800cda <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cf8:	79 05                	jns    800cff <devpipe_read+0x4d>
  800cfa:	48                   	dec    %eax
  800cfb:	83 c8 e0             	or     $0xffffffe0,%eax
  800cfe:	40                   	inc    %eax
  800cff:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800d03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d06:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800d09:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0b:	46                   	inc    %esi
  800d0c:	39 75 10             	cmp    %esi,0x10(%ebp)
  800d0f:	77 07                	ja     800d18 <devpipe_read+0x66>
  800d11:	eb 12                	jmp    800d25 <devpipe_read+0x73>
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800d18:	8b 03                	mov    (%ebx),%eax
  800d1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d1d:	75 d4                	jne    800cf3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1f:	85 f6                	test   %esi,%esi
  800d21:	75 b3                	jne    800cd6 <devpipe_read+0x24>
  800d23:	eb b5                	jmp    800cda <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d25:	89 f0                	mov    %esi,%eax
  800d27:	eb 05                	jmp    800d2e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 28             	sub    $0x28,%esp
  800d3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d45:	50                   	push   %eax
  800d46:	e8 75 f6 ff ff       	call   8003c0 <fd_alloc>
  800d4b:	89 c3                	mov    %eax,%ebx
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 24 01 00 00    	js     800e7c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	68 07 04 00 00       	push   $0x407
  800d60:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d63:	6a 00                	push   $0x0
  800d65:	e8 5a f4 ff ff       	call   8001c4 <sys_page_alloc>
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 05 01 00 00    	js     800e7c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d7d:	50                   	push   %eax
  800d7e:	e8 3d f6 ff ff       	call   8003c0 <fd_alloc>
  800d83:	89 c3                	mov    %eax,%ebx
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 dc 00 00 00    	js     800e6c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	68 07 04 00 00       	push   $0x407
  800d98:	ff 75 e0             	pushl  -0x20(%ebp)
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 22 f4 ff ff       	call   8001c4 <sys_page_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 bd 00 00 00    	js     800e6c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800db5:	e8 ee f5 ff ff       	call   8003a8 <fd2data>
  800dba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbc:	83 c4 0c             	add    $0xc,%esp
  800dbf:	68 07 04 00 00       	push   $0x407
  800dc4:	50                   	push   %eax
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 f8 f3 ff ff       	call   8001c4 <sys_page_alloc>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	0f 88 83 00 00 00    	js     800e5c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	ff 75 e0             	pushl  -0x20(%ebp)
  800ddf:	e8 c4 f5 ff ff       	call   8003a8 <fd2data>
  800de4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800deb:	50                   	push   %eax
  800dec:	6a 00                	push   $0x0
  800dee:	56                   	push   %esi
  800def:	6a 00                	push   $0x0
  800df1:	e8 f2 f3 ff ff       	call   8001e8 <sys_page_map>
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	83 c4 20             	add    $0x20,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 4f                	js     800e4e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e2f:	e8 64 f5 ff ff       	call   800398 <fd2num>
  800e34:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800e36:	83 c4 04             	add    $0x4,%esp
  800e39:	ff 75 e0             	pushl  -0x20(%ebp)
  800e3c:	e8 57 f5 ff ff       	call   800398 <fd2num>
  800e41:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4c:	eb 2e                	jmp    800e7c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e4e:	83 ec 08             	sub    $0x8,%esp
  800e51:	56                   	push   %esi
  800e52:	6a 00                	push   $0x0
  800e54:	e8 b5 f3 ff ff       	call   80020e <sys_page_unmap>
  800e59:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	ff 75 e0             	pushl  -0x20(%ebp)
  800e62:	6a 00                	push   $0x0
  800e64:	e8 a5 f3 ff ff       	call   80020e <sys_page_unmap>
  800e69:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e72:	6a 00                	push   $0x0
  800e74:	e8 95 f3 ff ff       	call   80020e <sys_page_unmap>
  800e79:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8f:	50                   	push   %eax
  800e90:	ff 75 08             	pushl  0x8(%ebp)
  800e93:	e8 9b f5 ff ff       	call   800433 <fd_lookup>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 18                	js     800eb7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea5:	e8 fe f4 ff ff       	call   8003a8 <fd2data>
	return _pipeisclosed(fd, p);
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eaf:	e8 0c fd ff ff       	call   800bc0 <_pipeisclosed>
  800eb4:	83 c4 10             	add    $0x10,%esp
}
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    
  800eb9:	00 00                	add    %al,(%eax)
	...

00800ebc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecc:	68 96 1f 80 00       	push   $0x801f96
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	e8 01 08 00 00       	call   8016da <strcpy>
	return 0;
}
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef0:	74 45                	je     800f37 <devcons_write+0x57>
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f05:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800f07:	83 fb 7f             	cmp    $0x7f,%ebx
  800f0a:	76 05                	jbe    800f11 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800f0c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	53                   	push   %ebx
  800f15:	03 45 0c             	add    0xc(%ebp),%eax
  800f18:	50                   	push   %eax
  800f19:	57                   	push   %edi
  800f1a:	e8 7c 09 00 00       	call   80189b <memmove>
		sys_cputs(buf, m);
  800f1f:	83 c4 08             	add    $0x8,%esp
  800f22:	53                   	push   %ebx
  800f23:	57                   	push   %edi
  800f24:	e8 e4 f1 ff ff       	call   80010d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f29:	01 de                	add    %ebx,%esi
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f33:	72 cd                	jb     800f02 <devcons_write+0x22>
  800f35:	eb 05                	jmp    800f3c <devcons_write+0x5c>
  800f37:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f3c:	89 f0                	mov    %esi,%eax
  800f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f50:	75 07                	jne    800f59 <devcons_read+0x13>
  800f52:	eb 25                	jmp    800f79 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f54:	e8 44 f2 ff ff       	call   80019d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f59:	e8 d5 f1 ff ff       	call   800133 <sys_cgetc>
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	74 f2                	je     800f54 <devcons_read+0xe>
  800f62:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 1d                	js     800f85 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f68:	83 f8 04             	cmp    $0x4,%eax
  800f6b:	74 13                	je     800f80 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f70:	88 10                	mov    %dl,(%eax)
	return 1;
  800f72:	b8 01 00 00 00       	mov    $0x1,%eax
  800f77:	eb 0c                	jmp    800f85 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7e:	eb 05                	jmp    800f85 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f93:	6a 01                	push   $0x1
  800f95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	e8 6f f1 ff ff       	call   80010d <sys_cputs>
  800f9e:	83 c4 10             	add    $0x10,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <getchar>:

int
getchar(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa9:	6a 01                	push   $0x1
  800fab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 fe f6 ff ff       	call   8006b4 <read>
	if (r < 0)
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 0f                	js     800fcc <getchar+0x29>
		return r;
	if (r < 1)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 06                	jle    800fc7 <getchar+0x24>
		return -E_EOF;
	return c;
  800fc1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc5:	eb 05                	jmp    800fcc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 53 f4 ff ff       	call   800433 <fd_lookup>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 11                	js     800ff8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff0:	39 10                	cmp    %edx,(%eax)
  800ff2:	0f 94 c0             	sete   %al
  800ff5:	0f b6 c0             	movzbl %al,%eax
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <opencons>:

int
opencons(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801000:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	e8 b7 f3 ff ff       	call   8003c0 <fd_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 3a                	js     80104a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	68 07 04 00 00       	push   $0x407
  801018:	ff 75 f4             	pushl  -0xc(%ebp)
  80101b:	6a 00                	push   $0x0
  80101d:	e8 a2 f1 ff ff       	call   8001c4 <sys_page_alloc>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 21                	js     80104a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801029:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801032:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801037:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	50                   	push   %eax
  801042:	e8 51 f3 ff ff       	call   800398 <fd2num>
  801047:	83 c4 10             	add    $0x10,%esp
}
  80104a:	c9                   	leave  
  80104b:	c3                   	ret    

0080104c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801051:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801054:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80105a:	e8 1a f1 ff ff       	call   800179 <sys_getenvid>
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	53                   	push   %ebx
  801069:	50                   	push   %eax
  80106a:	68 a4 1f 80 00       	push   $0x801fa4
  80106f:	e8 b0 00 00 00       	call   801124 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801074:	83 c4 18             	add    $0x18,%esp
  801077:	56                   	push   %esi
  801078:	ff 75 10             	pushl  0x10(%ebp)
  80107b:	e8 53 00 00 00       	call   8010d3 <vcprintf>
	cprintf("\n");
  801080:	c7 04 24 8f 1f 80 00 	movl   $0x801f8f,(%esp)
  801087:	e8 98 00 00 00       	call   801124 <cprintf>
  80108c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108f:	cc                   	int3   
  801090:	eb fd                	jmp    80108f <_panic+0x43>
	...

00801094 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109e:	8b 03                	mov    (%ebx),%eax
  8010a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8010a7:	40                   	inc    %eax
  8010a8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8010aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010af:	75 1a                	jne    8010cb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	68 ff 00 00 00       	push   $0xff
  8010b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bc:	50                   	push   %eax
  8010bd:	e8 4b f0 ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  8010c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010cb:	ff 43 04             	incl   0x4(%ebx)
}
  8010ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e3:	00 00 00 
	b.cnt = 0;
  8010e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	68 94 10 80 00       	push   $0x801094
  801102:	e8 82 01 00 00       	call   801289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801110:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	e8 f1 ef ff ff       	call   80010d <sys_cputs>

	return b.cnt;
}
  80111c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80112a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	e8 9d ff ff ff       	call   8010d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 2c             	sub    $0x2c,%esp
  801141:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801144:	89 d6                	mov    %edx,%esi
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80114f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801158:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80115b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80115e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801165:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801168:	72 0c                	jb     801176 <printnum+0x3e>
  80116a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80116d:	76 07                	jbe    801176 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116f:	4b                   	dec    %ebx
  801170:	85 db                	test   %ebx,%ebx
  801172:	7f 31                	jg     8011a5 <printnum+0x6d>
  801174:	eb 3f                	jmp    8011b5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	57                   	push   %edi
  80117a:	4b                   	dec    %ebx
  80117b:	53                   	push   %ebx
  80117c:	50                   	push   %eax
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	ff 75 d4             	pushl  -0x2c(%ebp)
  801183:	ff 75 d0             	pushl  -0x30(%ebp)
  801186:	ff 75 dc             	pushl  -0x24(%ebp)
  801189:	ff 75 d8             	pushl  -0x28(%ebp)
  80118c:	e8 8f 0a 00 00       	call   801c20 <__udivdi3>
  801191:	83 c4 18             	add    $0x18,%esp
  801194:	52                   	push   %edx
  801195:	50                   	push   %eax
  801196:	89 f2                	mov    %esi,%edx
  801198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119b:	e8 98 ff ff ff       	call   801138 <printnum>
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	eb 10                	jmp    8011b5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	56                   	push   %esi
  8011a9:	57                   	push   %edi
  8011aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ad:	4b                   	dec    %ebx
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 db                	test   %ebx,%ebx
  8011b3:	7f f0                	jg     8011a5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	56                   	push   %esi
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8011c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c8:	e8 6f 0b 00 00       	call   801d3c <__umoddi3>
  8011cd:	83 c4 14             	add    $0x14,%esp
  8011d0:	0f be 80 c7 1f 80 00 	movsbl 0x801fc7(%eax),%eax
  8011d7:	50                   	push   %eax
  8011d8:	ff 55 e4             	call   *-0x1c(%ebp)
  8011db:	83 c4 10             	add    $0x10,%esp
}
  8011de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e9:	83 fa 01             	cmp    $0x1,%edx
  8011ec:	7e 0e                	jle    8011fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	8b 52 04             	mov    0x4(%edx),%edx
  8011fa:	eb 22                	jmp    80121e <getuint+0x38>
	else if (lflag)
  8011fc:	85 d2                	test   %edx,%edx
  8011fe:	74 10                	je     801210 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 04             	lea    0x4(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	ba 00 00 00 00       	mov    $0x0,%edx
  80120e:	eb 0e                	jmp    80121e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801210:	8b 10                	mov    (%eax),%edx
  801212:	8d 4a 04             	lea    0x4(%edx),%ecx
  801215:	89 08                	mov    %ecx,(%eax)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801223:	83 fa 01             	cmp    $0x1,%edx
  801226:	7e 0e                	jle    801236 <getint+0x16>
		return va_arg(*ap, long long);
  801228:	8b 10                	mov    (%eax),%edx
  80122a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122d:	89 08                	mov    %ecx,(%eax)
  80122f:	8b 02                	mov    (%edx),%eax
  801231:	8b 52 04             	mov    0x4(%edx),%edx
  801234:	eb 1a                	jmp    801250 <getint+0x30>
	else if (lflag)
  801236:	85 d2                	test   %edx,%edx
  801238:	74 0c                	je     801246 <getint+0x26>
		return va_arg(*ap, long);
  80123a:	8b 10                	mov    (%eax),%edx
  80123c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123f:	89 08                	mov    %ecx,(%eax)
  801241:	8b 02                	mov    (%edx),%eax
  801243:	99                   	cltd   
  801244:	eb 0a                	jmp    801250 <getint+0x30>
	else
		return va_arg(*ap, int);
  801246:	8b 10                	mov    (%eax),%edx
  801248:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124b:	89 08                	mov    %ecx,(%eax)
  80124d:	8b 02                	mov    (%edx),%eax
  80124f:	99                   	cltd   
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801258:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	3b 50 04             	cmp    0x4(%eax),%edx
  801260:	73 08                	jae    80126a <sprintputch+0x18>
		*b->buf++ = ch;
  801262:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801265:	88 0a                	mov    %cl,(%edx)
  801267:	42                   	inc    %edx
  801268:	89 10                	mov    %edx,(%eax)
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801275:	50                   	push   %eax
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 05 00 00 00       	call   801289 <vprintfmt>
	va_end(ap);
  801284:	83 c4 10             	add    $0x10,%esp
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 2c             	sub    $0x2c,%esp
  801292:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801295:	8b 75 10             	mov    0x10(%ebp),%esi
  801298:	eb 13                	jmp    8012ad <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129a:	85 c0                	test   %eax,%eax
  80129c:	0f 84 6d 03 00 00    	je     80160f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	57                   	push   %edi
  8012a6:	50                   	push   %eax
  8012a7:	ff 55 08             	call   *0x8(%ebp)
  8012aa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ad:	0f b6 06             	movzbl (%esi),%eax
  8012b0:	46                   	inc    %esi
  8012b1:	83 f8 25             	cmp    $0x25,%eax
  8012b4:	75 e4                	jne    80129a <vprintfmt+0x11>
  8012b6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8012ba:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8012c1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8012c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8012cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d4:	eb 28                	jmp    8012fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012d8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012dc:	eb 20                	jmp    8012fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012de:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012e4:	eb 18                	jmp    8012fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012ef:	eb 0d                	jmp    8012fe <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fe:	8a 06                	mov    (%esi),%al
  801300:	0f b6 d0             	movzbl %al,%edx
  801303:	8d 5e 01             	lea    0x1(%esi),%ebx
  801306:	83 e8 23             	sub    $0x23,%eax
  801309:	3c 55                	cmp    $0x55,%al
  80130b:	0f 87 e0 02 00 00    	ja     8015f1 <vprintfmt+0x368>
  801311:	0f b6 c0             	movzbl %al,%eax
  801314:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80131b:	83 ea 30             	sub    $0x30,%edx
  80131e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801321:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801324:	8d 50 d0             	lea    -0x30(%eax),%edx
  801327:	83 fa 09             	cmp    $0x9,%edx
  80132a:	77 44                	ja     801370 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132c:	89 de                	mov    %ebx,%esi
  80132e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801331:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801332:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801335:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801339:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80133c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80133f:	83 fb 09             	cmp    $0x9,%ebx
  801342:	76 ed                	jbe    801331 <vprintfmt+0xa8>
  801344:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801347:	eb 29                	jmp    801372 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801349:	8b 45 14             	mov    0x14(%ebp),%eax
  80134c:	8d 50 04             	lea    0x4(%eax),%edx
  80134f:	89 55 14             	mov    %edx,0x14(%ebp)
  801352:	8b 00                	mov    (%eax),%eax
  801354:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801357:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801359:	eb 17                	jmp    801372 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80135b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80135f:	78 85                	js     8012e6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	89 de                	mov    %ebx,%esi
  801363:	eb 99                	jmp    8012fe <vprintfmt+0x75>
  801365:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801367:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80136e:	eb 8e                	jmp    8012fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801370:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801372:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801376:	79 86                	jns    8012fe <vprintfmt+0x75>
  801378:	e9 74 ff ff ff       	jmp    8012f1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80137d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	89 de                	mov    %ebx,%esi
  801380:	e9 79 ff ff ff       	jmp    8012fe <vprintfmt+0x75>
  801385:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801388:	8b 45 14             	mov    0x14(%ebp),%eax
  80138b:	8d 50 04             	lea    0x4(%eax),%edx
  80138e:	89 55 14             	mov    %edx,0x14(%ebp)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	57                   	push   %edi
  801395:	ff 30                	pushl  (%eax)
  801397:	ff 55 08             	call   *0x8(%ebp)
			break;
  80139a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a0:	e9 08 ff ff ff       	jmp    8012ad <vprintfmt+0x24>
  8013a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ab:	8d 50 04             	lea    0x4(%eax),%edx
  8013ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b1:	8b 00                	mov    (%eax),%eax
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	79 02                	jns    8013b9 <vprintfmt+0x130>
  8013b7:	f7 d8                	neg    %eax
  8013b9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bb:	83 f8 0f             	cmp    $0xf,%eax
  8013be:	7f 0b                	jg     8013cb <vprintfmt+0x142>
  8013c0:	8b 04 85 60 22 80 00 	mov    0x802260(,%eax,4),%eax
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	75 1a                	jne    8013e5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8013cb:	52                   	push   %edx
  8013cc:	68 df 1f 80 00       	push   $0x801fdf
  8013d1:	57                   	push   %edi
  8013d2:	ff 75 08             	pushl  0x8(%ebp)
  8013d5:	e8 92 fe ff ff       	call   80126c <printfmt>
  8013da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013e0:	e9 c8 fe ff ff       	jmp    8012ad <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013e5:	50                   	push   %eax
  8013e6:	68 5d 1f 80 00       	push   $0x801f5d
  8013eb:	57                   	push   %edi
  8013ec:	ff 75 08             	pushl  0x8(%ebp)
  8013ef:	e8 78 fe ff ff       	call   80126c <printfmt>
  8013f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013fa:	e9 ae fe ff ff       	jmp    8012ad <vprintfmt+0x24>
  8013ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801402:	89 de                	mov    %ebx,%esi
  801404:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801407:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80140a:	8b 45 14             	mov    0x14(%ebp),%eax
  80140d:	8d 50 04             	lea    0x4(%eax),%edx
  801410:	89 55 14             	mov    %edx,0x14(%ebp)
  801413:	8b 00                	mov    (%eax),%eax
  801415:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801418:	85 c0                	test   %eax,%eax
  80141a:	75 07                	jne    801423 <vprintfmt+0x19a>
				p = "(null)";
  80141c:	c7 45 d0 d8 1f 80 00 	movl   $0x801fd8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801423:	85 db                	test   %ebx,%ebx
  801425:	7e 42                	jle    801469 <vprintfmt+0x1e0>
  801427:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80142b:	74 3c                	je     801469 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	51                   	push   %ecx
  801431:	ff 75 d0             	pushl  -0x30(%ebp)
  801434:	e8 6f 02 00 00       	call   8016a8 <strnlen>
  801439:	29 c3                	sub    %eax,%ebx
  80143b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	85 db                	test   %ebx,%ebx
  801443:	7e 24                	jle    801469 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801445:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801449:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80144c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	57                   	push   %edi
  801453:	53                   	push   %ebx
  801454:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801457:	4e                   	dec    %esi
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 f6                	test   %esi,%esi
  80145d:	7f f0                	jg     80144f <vprintfmt+0x1c6>
  80145f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801462:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801469:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80146c:	0f be 02             	movsbl (%edx),%eax
  80146f:	85 c0                	test   %eax,%eax
  801471:	75 47                	jne    8014ba <vprintfmt+0x231>
  801473:	eb 37                	jmp    8014ac <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801479:	74 16                	je     801491 <vprintfmt+0x208>
  80147b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80147e:	83 fa 5e             	cmp    $0x5e,%edx
  801481:	76 0e                	jbe    801491 <vprintfmt+0x208>
					putch('?', putdat);
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	57                   	push   %edi
  801487:	6a 3f                	push   $0x3f
  801489:	ff 55 08             	call   *0x8(%ebp)
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	eb 0b                	jmp    80149c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	57                   	push   %edi
  801495:	50                   	push   %eax
  801496:	ff 55 08             	call   *0x8(%ebp)
  801499:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80149c:	ff 4d e4             	decl   -0x1c(%ebp)
  80149f:	0f be 03             	movsbl (%ebx),%eax
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	74 03                	je     8014a9 <vprintfmt+0x220>
  8014a6:	43                   	inc    %ebx
  8014a7:	eb 1b                	jmp    8014c4 <vprintfmt+0x23b>
  8014a9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014b0:	7f 1e                	jg     8014d0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8014b5:	e9 f3 fd ff ff       	jmp    8012ad <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ba:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8014bd:	43                   	inc    %ebx
  8014be:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8014c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8014c4:	85 f6                	test   %esi,%esi
  8014c6:	78 ad                	js     801475 <vprintfmt+0x1ec>
  8014c8:	4e                   	dec    %esi
  8014c9:	79 aa                	jns    801475 <vprintfmt+0x1ec>
  8014cb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8014ce:	eb dc                	jmp    8014ac <vprintfmt+0x223>
  8014d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	57                   	push   %edi
  8014d7:	6a 20                	push   $0x20
  8014d9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014dc:	4b                   	dec    %ebx
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 db                	test   %ebx,%ebx
  8014e2:	7f ef                	jg     8014d3 <vprintfmt+0x24a>
  8014e4:	e9 c4 fd ff ff       	jmp    8012ad <vprintfmt+0x24>
  8014e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014ec:	89 ca                	mov    %ecx,%edx
  8014ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f1:	e8 2a fd ff ff       	call   801220 <getint>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014fa:	85 d2                	test   %edx,%edx
  8014fc:	78 0a                	js     801508 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801503:	e9 b0 00 00 00       	jmp    8015b8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	57                   	push   %edi
  80150c:	6a 2d                	push   $0x2d
  80150e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801511:	f7 db                	neg    %ebx
  801513:	83 d6 00             	adc    $0x0,%esi
  801516:	f7 de                	neg    %esi
  801518:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801520:	e9 93 00 00 00       	jmp    8015b8 <vprintfmt+0x32f>
  801525:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801528:	89 ca                	mov    %ecx,%edx
  80152a:	8d 45 14             	lea    0x14(%ebp),%eax
  80152d:	e8 b4 fc ff ff       	call   8011e6 <getuint>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	89 d6                	mov    %edx,%esi
			base = 10;
  801536:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80153b:	eb 7b                	jmp    8015b8 <vprintfmt+0x32f>
  80153d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801540:	89 ca                	mov    %ecx,%edx
  801542:	8d 45 14             	lea    0x14(%ebp),%eax
  801545:	e8 d6 fc ff ff       	call   801220 <getint>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80154e:	85 d2                	test   %edx,%edx
  801550:	78 07                	js     801559 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801552:	b8 08 00 00 00       	mov    $0x8,%eax
  801557:	eb 5f                	jmp    8015b8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	57                   	push   %edi
  80155d:	6a 2d                	push   $0x2d
  80155f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801562:	f7 db                	neg    %ebx
  801564:	83 d6 00             	adc    $0x0,%esi
  801567:	f7 de                	neg    %esi
  801569:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80156c:	b8 08 00 00 00       	mov    $0x8,%eax
  801571:	eb 45                	jmp    8015b8 <vprintfmt+0x32f>
  801573:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	57                   	push   %edi
  80157a:	6a 30                	push   $0x30
  80157c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	57                   	push   %edi
  801583:	6a 78                	push   $0x78
  801585:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8d 50 04             	lea    0x4(%eax),%edx
  80158e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801591:	8b 18                	mov    (%eax),%ebx
  801593:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801598:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80159b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015a0:	eb 16                	jmp    8015b8 <vprintfmt+0x32f>
  8015a2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a5:	89 ca                	mov    %ecx,%edx
  8015a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015aa:	e8 37 fc ff ff       	call   8011e6 <getuint>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	89 d6                	mov    %edx,%esi
			base = 16;
  8015b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8015bf:	52                   	push   %edx
  8015c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c3:	50                   	push   %eax
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	89 fa                	mov    %edi,%edx
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	e8 68 fb ff ff       	call   801138 <printnum>
			break;
  8015d0:	83 c4 20             	add    $0x20,%esp
  8015d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015d6:	e9 d2 fc ff ff       	jmp    8012ad <vprintfmt+0x24>
  8015db:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	57                   	push   %edi
  8015e2:	52                   	push   %edx
  8015e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ec:	e9 bc fc ff ff       	jmp    8012ad <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	57                   	push   %edi
  8015f5:	6a 25                	push   $0x25
  8015f7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 02                	jmp    801601 <vprintfmt+0x378>
  8015ff:	89 c6                	mov    %eax,%esi
  801601:	8d 46 ff             	lea    -0x1(%esi),%eax
  801604:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801608:	75 f5                	jne    8015ff <vprintfmt+0x376>
  80160a:	e9 9e fc ff ff       	jmp    8012ad <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 18             	sub    $0x18,%esp
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801626:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801634:	85 c0                	test   %eax,%eax
  801636:	74 26                	je     80165e <vsnprintf+0x47>
  801638:	85 d2                	test   %edx,%edx
  80163a:	7e 29                	jle    801665 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163c:	ff 75 14             	pushl  0x14(%ebp)
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	68 52 12 80 00       	push   $0x801252
  80164b:	e8 39 fc ff ff       	call   801289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 0c                	jmp    80166a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801663:	eb 05                	jmp    80166a <vsnprintf+0x53>
  801665:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801672:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801675:	50                   	push   %eax
  801676:	ff 75 10             	pushl  0x10(%ebp)
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 93 ff ff ff       	call   801617 <vsnprintf>
	va_end(ap);

	return rc;
}
  801684:	c9                   	leave  
  801685:	c3                   	ret    
	...

00801688 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168e:	80 3a 00             	cmpb   $0x0,(%edx)
  801691:	74 0e                	je     8016a1 <strlen+0x19>
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801698:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801699:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169d:	75 f9                	jne    801698 <strlen+0x10>
  80169f:	eb 05                	jmp    8016a6 <strlen+0x1e>
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	74 17                	je     8016cc <strnlen+0x24>
  8016b5:	80 39 00             	cmpb   $0x0,(%ecx)
  8016b8:	74 19                	je     8016d3 <strnlen+0x2b>
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8016bf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c0:	39 d0                	cmp    %edx,%eax
  8016c2:	74 14                	je     8016d8 <strnlen+0x30>
  8016c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016c8:	75 f5                	jne    8016bf <strnlen+0x17>
  8016ca:	eb 0c                	jmp    8016d8 <strnlen+0x30>
  8016cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d1:	eb 05                	jmp    8016d8 <strnlen+0x30>
  8016d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016ef:	42                   	inc    %edx
  8016f0:	84 c9                	test   %cl,%cl
  8016f2:	75 f5                	jne    8016e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016f4:	5b                   	pop    %ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fe:	53                   	push   %ebx
  8016ff:	e8 84 ff ff ff       	call   801688 <strlen>
  801704:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80170d:	50                   	push   %eax
  80170e:	e8 c7 ff ff ff       	call   8016da <strcpy>
	return dst;
}
  801713:	89 d8                	mov    %ebx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	8b 55 0c             	mov    0xc(%ebp),%edx
  801725:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801728:	85 f6                	test   %esi,%esi
  80172a:	74 15                	je     801741 <strncpy+0x27>
  80172c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801731:	8a 1a                	mov    (%edx),%bl
  801733:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801736:	80 3a 01             	cmpb   $0x1,(%edx)
  801739:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173c:	41                   	inc    %ecx
  80173d:	39 ce                	cmp    %ecx,%esi
  80173f:	77 f0                	ja     801731 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	57                   	push   %edi
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80174e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801751:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801754:	85 f6                	test   %esi,%esi
  801756:	74 32                	je     80178a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  801758:	83 fe 01             	cmp    $0x1,%esi
  80175b:	74 22                	je     80177f <strlcpy+0x3a>
  80175d:	8a 0b                	mov    (%ebx),%cl
  80175f:	84 c9                	test   %cl,%cl
  801761:	74 20                	je     801783 <strlcpy+0x3e>
  801763:	89 f8                	mov    %edi,%eax
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80176a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176d:	88 08                	mov    %cl,(%eax)
  80176f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801770:	39 f2                	cmp    %esi,%edx
  801772:	74 11                	je     801785 <strlcpy+0x40>
  801774:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  801778:	42                   	inc    %edx
  801779:	84 c9                	test   %cl,%cl
  80177b:	75 f0                	jne    80176d <strlcpy+0x28>
  80177d:	eb 06                	jmp    801785 <strlcpy+0x40>
  80177f:	89 f8                	mov    %edi,%eax
  801781:	eb 02                	jmp    801785 <strlcpy+0x40>
  801783:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801785:	c6 00 00             	movb   $0x0,(%eax)
  801788:	eb 02                	jmp    80178c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80178c:	29 f8                	sub    %edi,%eax
}
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5f                   	pop    %edi
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801799:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179c:	8a 01                	mov    (%ecx),%al
  80179e:	84 c0                	test   %al,%al
  8017a0:	74 10                	je     8017b2 <strcmp+0x1f>
  8017a2:	3a 02                	cmp    (%edx),%al
  8017a4:	75 0c                	jne    8017b2 <strcmp+0x1f>
		p++, q++;
  8017a6:	41                   	inc    %ecx
  8017a7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a8:	8a 01                	mov    (%ecx),%al
  8017aa:	84 c0                	test   %al,%al
  8017ac:	74 04                	je     8017b2 <strcmp+0x1f>
  8017ae:	3a 02                	cmp    (%edx),%al
  8017b0:	74 f4                	je     8017a6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b2:	0f b6 c0             	movzbl %al,%eax
  8017b5:	0f b6 12             	movzbl (%edx),%edx
  8017b8:	29 d0                	sub    %edx,%eax
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	74 1b                	je     8017e8 <strncmp+0x2c>
  8017cd:	8a 1a                	mov    (%edx),%bl
  8017cf:	84 db                	test   %bl,%bl
  8017d1:	74 24                	je     8017f7 <strncmp+0x3b>
  8017d3:	3a 19                	cmp    (%ecx),%bl
  8017d5:	75 20                	jne    8017f7 <strncmp+0x3b>
  8017d7:	48                   	dec    %eax
  8017d8:	74 15                	je     8017ef <strncmp+0x33>
		n--, p++, q++;
  8017da:	42                   	inc    %edx
  8017db:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017dc:	8a 1a                	mov    (%edx),%bl
  8017de:	84 db                	test   %bl,%bl
  8017e0:	74 15                	je     8017f7 <strncmp+0x3b>
  8017e2:	3a 19                	cmp    (%ecx),%bl
  8017e4:	74 f1                	je     8017d7 <strncmp+0x1b>
  8017e6:	eb 0f                	jmp    8017f7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ed:	eb 05                	jmp    8017f4 <strncmp+0x38>
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017f4:	5b                   	pop    %ebx
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f7:	0f b6 02             	movzbl (%edx),%eax
  8017fa:	0f b6 11             	movzbl (%ecx),%edx
  8017fd:	29 d0                	sub    %edx,%eax
  8017ff:	eb f3                	jmp    8017f4 <strncmp+0x38>

00801801 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80180a:	8a 10                	mov    (%eax),%dl
  80180c:	84 d2                	test   %dl,%dl
  80180e:	74 18                	je     801828 <strchr+0x27>
		if (*s == c)
  801810:	38 ca                	cmp    %cl,%dl
  801812:	75 06                	jne    80181a <strchr+0x19>
  801814:	eb 17                	jmp    80182d <strchr+0x2c>
  801816:	38 ca                	cmp    %cl,%dl
  801818:	74 13                	je     80182d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80181a:	40                   	inc    %eax
  80181b:	8a 10                	mov    (%eax),%dl
  80181d:	84 d2                	test   %dl,%dl
  80181f:	75 f5                	jne    801816 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
  801826:	eb 05                	jmp    80182d <strchr+0x2c>
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801838:	8a 10                	mov    (%eax),%dl
  80183a:	84 d2                	test   %dl,%dl
  80183c:	74 11                	je     80184f <strfind+0x20>
		if (*s == c)
  80183e:	38 ca                	cmp    %cl,%dl
  801840:	75 06                	jne    801848 <strfind+0x19>
  801842:	eb 0b                	jmp    80184f <strfind+0x20>
  801844:	38 ca                	cmp    %cl,%dl
  801846:	74 07                	je     80184f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801848:	40                   	inc    %eax
  801849:	8a 10                	mov    (%eax),%dl
  80184b:	84 d2                	test   %dl,%dl
  80184d:	75 f5                	jne    801844 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	57                   	push   %edi
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801860:	85 c9                	test   %ecx,%ecx
  801862:	74 30                	je     801894 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801864:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80186a:	75 25                	jne    801891 <memset+0x40>
  80186c:	f6 c1 03             	test   $0x3,%cl
  80186f:	75 20                	jne    801891 <memset+0x40>
		c &= 0xFF;
  801871:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801874:	89 d3                	mov    %edx,%ebx
  801876:	c1 e3 08             	shl    $0x8,%ebx
  801879:	89 d6                	mov    %edx,%esi
  80187b:	c1 e6 18             	shl    $0x18,%esi
  80187e:	89 d0                	mov    %edx,%eax
  801880:	c1 e0 10             	shl    $0x10,%eax
  801883:	09 f0                	or     %esi,%eax
  801885:	09 d0                	or     %edx,%eax
  801887:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801889:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80188c:	fc                   	cld    
  80188d:	f3 ab                	rep stos %eax,%es:(%edi)
  80188f:	eb 03                	jmp    801894 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801891:	fc                   	cld    
  801892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801894:	89 f8                	mov    %edi,%eax
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	5f                   	pop    %edi
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	57                   	push   %edi
  80189f:	56                   	push   %esi
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a9:	39 c6                	cmp    %eax,%esi
  8018ab:	73 34                	jae    8018e1 <memmove+0x46>
  8018ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b0:	39 d0                	cmp    %edx,%eax
  8018b2:	73 2d                	jae    8018e1 <memmove+0x46>
		s += n;
		d += n;
  8018b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b7:	f6 c2 03             	test   $0x3,%dl
  8018ba:	75 1b                	jne    8018d7 <memmove+0x3c>
  8018bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018c2:	75 13                	jne    8018d7 <memmove+0x3c>
  8018c4:	f6 c1 03             	test   $0x3,%cl
  8018c7:	75 0e                	jne    8018d7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018c9:	83 ef 04             	sub    $0x4,%edi
  8018cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018cf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018d2:	fd                   	std    
  8018d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d5:	eb 07                	jmp    8018de <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018d7:	4f                   	dec    %edi
  8018d8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018db:	fd                   	std    
  8018dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018de:	fc                   	cld    
  8018df:	eb 20                	jmp    801901 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018e7:	75 13                	jne    8018fc <memmove+0x61>
  8018e9:	a8 03                	test   $0x3,%al
  8018eb:	75 0f                	jne    8018fc <memmove+0x61>
  8018ed:	f6 c1 03             	test   $0x3,%cl
  8018f0:	75 0a                	jne    8018fc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018f5:	89 c7                	mov    %eax,%edi
  8018f7:	fc                   	cld    
  8018f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fa:	eb 05                	jmp    801901 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018fc:	89 c7                	mov    %eax,%edi
  8018fe:	fc                   	cld    
  8018ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801901:	5e                   	pop    %esi
  801902:	5f                   	pop    %edi
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801908:	ff 75 10             	pushl  0x10(%ebp)
  80190b:	ff 75 0c             	pushl  0xc(%ebp)
  80190e:	ff 75 08             	pushl  0x8(%ebp)
  801911:	e8 85 ff ff ff       	call   80189b <memmove>
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801921:	8b 75 0c             	mov    0xc(%ebp),%esi
  801924:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801927:	85 ff                	test   %edi,%edi
  801929:	74 32                	je     80195d <memcmp+0x45>
		if (*s1 != *s2)
  80192b:	8a 03                	mov    (%ebx),%al
  80192d:	8a 0e                	mov    (%esi),%cl
  80192f:	38 c8                	cmp    %cl,%al
  801931:	74 19                	je     80194c <memcmp+0x34>
  801933:	eb 0d                	jmp    801942 <memcmp+0x2a>
  801935:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801939:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80193d:	42                   	inc    %edx
  80193e:	38 c8                	cmp    %cl,%al
  801940:	74 10                	je     801952 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801942:	0f b6 c0             	movzbl %al,%eax
  801945:	0f b6 c9             	movzbl %cl,%ecx
  801948:	29 c8                	sub    %ecx,%eax
  80194a:	eb 16                	jmp    801962 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194c:	4f                   	dec    %edi
  80194d:	ba 00 00 00 00       	mov    $0x0,%edx
  801952:	39 fa                	cmp    %edi,%edx
  801954:	75 df                	jne    801935 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
  80195b:	eb 05                	jmp    801962 <memcmp+0x4a>
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	5f                   	pop    %edi
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80196d:	89 c2                	mov    %eax,%edx
  80196f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801972:	39 d0                	cmp    %edx,%eax
  801974:	73 12                	jae    801988 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  801976:	8a 4d 0c             	mov    0xc(%ebp),%cl
  801979:	38 08                	cmp    %cl,(%eax)
  80197b:	75 06                	jne    801983 <memfind+0x1c>
  80197d:	eb 09                	jmp    801988 <memfind+0x21>
  80197f:	38 08                	cmp    %cl,(%eax)
  801981:	74 05                	je     801988 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801983:	40                   	inc    %eax
  801984:	39 c2                	cmp    %eax,%edx
  801986:	77 f7                	ja     80197f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	8b 55 08             	mov    0x8(%ebp),%edx
  801993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801996:	eb 01                	jmp    801999 <strtol+0xf>
		s++;
  801998:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801999:	8a 02                	mov    (%edx),%al
  80199b:	3c 20                	cmp    $0x20,%al
  80199d:	74 f9                	je     801998 <strtol+0xe>
  80199f:	3c 09                	cmp    $0x9,%al
  8019a1:	74 f5                	je     801998 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a3:	3c 2b                	cmp    $0x2b,%al
  8019a5:	75 08                	jne    8019af <strtol+0x25>
		s++;
  8019a7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ad:	eb 13                	jmp    8019c2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019af:	3c 2d                	cmp    $0x2d,%al
  8019b1:	75 0a                	jne    8019bd <strtol+0x33>
		s++, neg = 1;
  8019b3:	8d 52 01             	lea    0x1(%edx),%edx
  8019b6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019bb:	eb 05                	jmp    8019c2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c2:	85 db                	test   %ebx,%ebx
  8019c4:	74 05                	je     8019cb <strtol+0x41>
  8019c6:	83 fb 10             	cmp    $0x10,%ebx
  8019c9:	75 28                	jne    8019f3 <strtol+0x69>
  8019cb:	8a 02                	mov    (%edx),%al
  8019cd:	3c 30                	cmp    $0x30,%al
  8019cf:	75 10                	jne    8019e1 <strtol+0x57>
  8019d1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8019d5:	75 0a                	jne    8019e1 <strtol+0x57>
		s += 2, base = 16;
  8019d7:	83 c2 02             	add    $0x2,%edx
  8019da:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019df:	eb 12                	jmp    8019f3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019e1:	85 db                	test   %ebx,%ebx
  8019e3:	75 0e                	jne    8019f3 <strtol+0x69>
  8019e5:	3c 30                	cmp    $0x30,%al
  8019e7:	75 05                	jne    8019ee <strtol+0x64>
		s++, base = 8;
  8019e9:	42                   	inc    %edx
  8019ea:	b3 08                	mov    $0x8,%bl
  8019ec:	eb 05                	jmp    8019f3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019fa:	8a 0a                	mov    (%edx),%cl
  8019fc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019ff:	80 fb 09             	cmp    $0x9,%bl
  801a02:	77 08                	ja     801a0c <strtol+0x82>
			dig = *s - '0';
  801a04:	0f be c9             	movsbl %cl,%ecx
  801a07:	83 e9 30             	sub    $0x30,%ecx
  801a0a:	eb 1e                	jmp    801a2a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801a0c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801a0f:	80 fb 19             	cmp    $0x19,%bl
  801a12:	77 08                	ja     801a1c <strtol+0x92>
			dig = *s - 'a' + 10;
  801a14:	0f be c9             	movsbl %cl,%ecx
  801a17:	83 e9 57             	sub    $0x57,%ecx
  801a1a:	eb 0e                	jmp    801a2a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801a1c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801a1f:	80 fb 19             	cmp    $0x19,%bl
  801a22:	77 13                	ja     801a37 <strtol+0xad>
			dig = *s - 'A' + 10;
  801a24:	0f be c9             	movsbl %cl,%ecx
  801a27:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801a2a:	39 f1                	cmp    %esi,%ecx
  801a2c:	7d 0d                	jge    801a3b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a2e:	42                   	inc    %edx
  801a2f:	0f af c6             	imul   %esi,%eax
  801a32:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801a35:	eb c3                	jmp    8019fa <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801a37:	89 c1                	mov    %eax,%ecx
  801a39:	eb 02                	jmp    801a3d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a3b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a41:	74 05                	je     801a48 <strtol+0xbe>
		*endptr = (char *) s;
  801a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a46:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a48:	85 ff                	test   %edi,%edi
  801a4a:	74 04                	je     801a50 <strtol+0xc6>
  801a4c:	89 c8                	mov    %ecx,%eax
  801a4e:	f7 d8                	neg    %eax
}
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5f                   	pop    %edi
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    
  801a55:	00 00                	add    %al,(%eax)
	...

00801a58 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a5e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a65:	75 52                	jne    801ab9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	6a 07                	push   $0x7
  801a6c:	68 00 f0 bf ee       	push   $0xeebff000
  801a71:	6a 00                	push   $0x0
  801a73:	e8 4c e7 ff ff       	call   8001c4 <sys_page_alloc>
		if (r < 0) {
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	79 12                	jns    801a91 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801a7f:	50                   	push   %eax
  801a80:	68 bf 22 80 00       	push   $0x8022bf
  801a85:	6a 24                	push   $0x24
  801a87:	68 da 22 80 00       	push   $0x8022da
  801a8c:	e8 bb f5 ff ff       	call   80104c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801a91:	83 ec 08             	sub    $0x8,%esp
  801a94:	68 70 03 80 00       	push   $0x800370
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 d7 e7 ff ff       	call   800277 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	79 12                	jns    801ab9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801aa7:	50                   	push   %eax
  801aa8:	68 e8 22 80 00       	push   $0x8022e8
  801aad:	6a 2a                	push   $0x2a
  801aaf:	68 da 22 80 00       	push   $0x8022da
  801ab4:	e8 93 f5 ff ff       	call   80104c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    
	...

00801ac4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	8b 75 08             	mov    0x8(%ebp),%esi
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	74 0e                	je     801ae4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	50                   	push   %eax
  801ada:	e8 e0 e7 ff ff       	call   8002bf <sys_ipc_recv>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	eb 10                	jmp    801af4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	68 00 00 c0 ee       	push   $0xeec00000
  801aec:	e8 ce e7 ff ff       	call   8002bf <sys_ipc_recv>
  801af1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801af4:	85 c0                	test   %eax,%eax
  801af6:	75 26                	jne    801b1e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801af8:	85 f6                	test   %esi,%esi
  801afa:	74 0a                	je     801b06 <ipc_recv+0x42>
  801afc:	a1 04 40 80 00       	mov    0x804004,%eax
  801b01:	8b 40 74             	mov    0x74(%eax),%eax
  801b04:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b06:	85 db                	test   %ebx,%ebx
  801b08:	74 0a                	je     801b14 <ipc_recv+0x50>
  801b0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0f:	8b 40 78             	mov    0x78(%eax),%eax
  801b12:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b14:	a1 04 40 80 00       	mov    0x804004,%eax
  801b19:	8b 40 70             	mov    0x70(%eax),%eax
  801b1c:	eb 14                	jmp    801b32 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b1e:	85 f6                	test   %esi,%esi
  801b20:	74 06                	je     801b28 <ipc_recv+0x64>
  801b22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	74 06                	je     801b32 <ipc_recv+0x6e>
  801b2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b48:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	75 25                	jne    801b74 <ipc_send+0x3b>
  801b4f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b54:	eb 1e                	jmp    801b74 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b59:	75 07                	jne    801b62 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b5b:	e8 3d e6 ff ff       	call   80019d <sys_yield>
  801b60:	eb 12                	jmp    801b74 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b62:	50                   	push   %eax
  801b63:	68 10 23 80 00       	push   $0x802310
  801b68:	6a 43                	push   $0x43
  801b6a:	68 23 23 80 00       	push   $0x802323
  801b6f:	e8 d8 f4 ff ff       	call   80104c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	57                   	push   %edi
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	e8 1b e7 ff ff       	call   80029a <sys_ipc_try_send>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	75 d0                	jne    801b56 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5f                   	pop    %edi
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b94:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801b9a:	74 1a                	je     801bb6 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b9c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ba1:	89 c2                	mov    %eax,%edx
  801ba3:	c1 e2 07             	shl    $0x7,%edx
  801ba6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801bad:	8b 52 50             	mov    0x50(%edx),%edx
  801bb0:	39 ca                	cmp    %ecx,%edx
  801bb2:	75 18                	jne    801bcc <ipc_find_env+0x3e>
  801bb4:	eb 05                	jmp    801bbb <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	c1 e2 07             	shl    $0x7,%edx
  801bc0:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801bc7:	8b 40 40             	mov    0x40(%eax),%eax
  801bca:	eb 0c                	jmp    801bd8 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bcc:	40                   	inc    %eax
  801bcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd2:	75 cd                	jne    801ba1 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bd4:	66 b8 00 00          	mov    $0x0,%ax
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    
	...

00801bdc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	c1 ea 16             	shr    $0x16,%edx
  801be7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bee:	f6 c2 01             	test   $0x1,%dl
  801bf1:	74 1e                	je     801c11 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf3:	c1 e8 0c             	shr    $0xc,%eax
  801bf6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bfd:	a8 01                	test   $0x1,%al
  801bff:	74 17                	je     801c18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c01:	c1 e8 0c             	shr    $0xc,%eax
  801c04:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c0b:	ef 
  801c0c:	0f b7 c0             	movzwl %ax,%eax
  801c0f:	eb 0c                	jmp    801c1d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
  801c16:	eb 05                	jmp    801c1d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    
	...

00801c20 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	57                   	push   %edi
  801c24:	56                   	push   %esi
  801c25:	83 ec 10             	sub    $0x10,%esp
  801c28:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c2e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c31:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c34:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c37:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 2e                	jne    801c6c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c3e:	39 f1                	cmp    %esi,%ecx
  801c40:	77 5a                	ja     801c9c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c42:	85 c9                	test   %ecx,%ecx
  801c44:	75 0b                	jne    801c51 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c46:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4b:	31 d2                	xor    %edx,%edx
  801c4d:	f7 f1                	div    %ecx
  801c4f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c51:	31 d2                	xor    %edx,%edx
  801c53:	89 f0                	mov    %esi,%eax
  801c55:	f7 f1                	div    %ecx
  801c57:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c59:	89 f8                	mov    %edi,%eax
  801c5b:	f7 f1                	div    %ecx
  801c5d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c6c:	39 f0                	cmp    %esi,%eax
  801c6e:	77 1c                	ja     801c8c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c70:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c73:	83 f7 1f             	xor    $0x1f,%edi
  801c76:	75 3c                	jne    801cb4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c78:	39 f0                	cmp    %esi,%eax
  801c7a:	0f 82 90 00 00 00    	jb     801d10 <__udivdi3+0xf0>
  801c80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c83:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c86:	0f 86 84 00 00 00    	jbe    801d10 <__udivdi3+0xf0>
  801c8c:	31 f6                	xor    %esi,%esi
  801c8e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c90:	89 f8                	mov    %edi,%eax
  801c92:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	5e                   	pop    %esi
  801c98:	5f                   	pop    %edi
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    
  801c9b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c9c:	89 f2                	mov    %esi,%edx
  801c9e:	89 f8                	mov    %edi,%eax
  801ca0:	f7 f1                	div    %ecx
  801ca2:	89 c7                	mov    %eax,%edi
  801ca4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ca6:	89 f8                	mov    %edi,%eax
  801ca8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    
  801cb1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cb4:	89 f9                	mov    %edi,%ecx
  801cb6:	d3 e0                	shl    %cl,%eax
  801cb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cbb:	b8 20 00 00 00       	mov    $0x20,%eax
  801cc0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc5:	88 c1                	mov    %al,%cl
  801cc7:	d3 ea                	shr    %cl,%edx
  801cc9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ccc:	09 ca                	or     %ecx,%edx
  801cce:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd4:	89 f9                	mov    %edi,%ecx
  801cd6:	d3 e2                	shl    %cl,%edx
  801cd8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cdb:	89 f2                	mov    %esi,%edx
  801cdd:	88 c1                	mov    %al,%cl
  801cdf:	d3 ea                	shr    %cl,%edx
  801ce1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801ce4:	89 f2                	mov    %esi,%edx
  801ce6:	89 f9                	mov    %edi,%ecx
  801ce8:	d3 e2                	shl    %cl,%edx
  801cea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ced:	88 c1                	mov    %al,%cl
  801cef:	d3 ee                	shr    %cl,%esi
  801cf1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cf3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cf6:	89 f0                	mov    %esi,%eax
  801cf8:	89 ca                	mov    %ecx,%edx
  801cfa:	f7 75 ec             	divl   -0x14(%ebp)
  801cfd:	89 d1                	mov    %edx,%ecx
  801cff:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d01:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d04:	39 d1                	cmp    %edx,%ecx
  801d06:	72 28                	jb     801d30 <__udivdi3+0x110>
  801d08:	74 1a                	je     801d24 <__udivdi3+0x104>
  801d0a:	89 f7                	mov    %esi,%edi
  801d0c:	31 f6                	xor    %esi,%esi
  801d0e:	eb 80                	jmp    801c90 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d10:	31 f6                	xor    %esi,%esi
  801d12:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d17:	89 f8                	mov    %edi,%eax
  801d19:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    
  801d22:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d27:	89 f9                	mov    %edi,%ecx
  801d29:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d2b:	39 c2                	cmp    %eax,%edx
  801d2d:	73 db                	jae    801d0a <__udivdi3+0xea>
  801d2f:	90                   	nop
		{
		  q0--;
  801d30:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d33:	31 f6                	xor    %esi,%esi
  801d35:	e9 56 ff ff ff       	jmp    801c90 <__udivdi3+0x70>
	...

00801d3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	83 ec 20             	sub    $0x20,%esp
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d50:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d59:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d5b:	85 ff                	test   %edi,%edi
  801d5d:	75 15                	jne    801d74 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d5f:	39 f1                	cmp    %esi,%ecx
  801d61:	0f 86 99 00 00 00    	jbe    801e00 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d67:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d69:	89 d0                	mov    %edx,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d6d:	83 c4 20             	add    $0x20,%esp
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d74:	39 f7                	cmp    %esi,%edi
  801d76:	0f 87 a4 00 00 00    	ja     801e20 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d7c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d7f:	83 f0 1f             	xor    $0x1f,%eax
  801d82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d85:	0f 84 a1 00 00 00    	je     801e2c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d8b:	89 f8                	mov    %edi,%eax
  801d8d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d90:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d92:	bf 20 00 00 00       	mov    $0x20,%edi
  801d97:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d9d:	89 f9                	mov    %edi,%ecx
  801d9f:	d3 ea                	shr    %cl,%edx
  801da1:	09 c2                	or     %eax,%edx
  801da3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801db1:	89 f2                	mov    %esi,%edx
  801db3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db8:	d3 e0                	shl    %cl,%eax
  801dba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dc0:	89 f9                	mov    %edi,%ecx
  801dc2:	d3 e8                	shr    %cl,%eax
  801dc4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dc6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	f7 75 f0             	divl   -0x10(%ebp)
  801dcd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dcf:	f7 65 f4             	mull   -0xc(%ebp)
  801dd2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801dd5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd7:	39 d6                	cmp    %edx,%esi
  801dd9:	72 71                	jb     801e4c <__umoddi3+0x110>
  801ddb:	74 7f                	je     801e5c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de0:	29 c8                	sub    %ecx,%eax
  801de2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801de4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 f2                	mov    %esi,%edx
  801deb:	89 f9                	mov    %edi,%ecx
  801ded:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801def:	09 d0                	or     %edx,%eax
  801df1:	89 f2                	mov    %esi,%edx
  801df3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801df6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df8:	83 c4 20             	add    $0x20,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e00:	85 c9                	test   %ecx,%ecx
  801e02:	75 0b                	jne    801e0f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e04:	b8 01 00 00 00       	mov    $0x1,%eax
  801e09:	31 d2                	xor    %edx,%edx
  801e0b:	f7 f1                	div    %ecx
  801e0d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	31 d2                	xor    %edx,%edx
  801e13:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e18:	f7 f1                	div    %ecx
  801e1a:	e9 4a ff ff ff       	jmp    801d69 <__umoddi3+0x2d>
  801e1f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e20:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e22:	83 c4 20             	add    $0x20,%esp
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    
  801e29:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e2c:	39 f7                	cmp    %esi,%edi
  801e2e:	72 05                	jb     801e35 <__umoddi3+0xf9>
  801e30:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e33:	77 0c                	ja     801e41 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e35:	89 f2                	mov    %esi,%edx
  801e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3a:	29 c8                	sub    %ecx,%eax
  801e3c:	19 fa                	sbb    %edi,%edx
  801e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e44:	83 c4 20             	add    $0x20,%esp
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    
  801e4b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e4c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e4f:	89 c1                	mov    %eax,%ecx
  801e51:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e54:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e57:	eb 84                	jmp    801ddd <__umoddi3+0xa1>
  801e59:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e5c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e5f:	72 eb                	jb     801e4c <__umoddi3+0x110>
  801e61:	89 f2                	mov    %esi,%edx
  801e63:	e9 75 ff ff ff       	jmp    801ddd <__umoddi3+0xa1>
