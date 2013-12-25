
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004f:	e8 11 01 00 00       	call   800165 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	89 c2                	mov    %eax,%edx
  80005b:	c1 e2 07             	shl    $0x7,%edx
  80005e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800065:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 f6                	test   %esi,%esi
  80006c:	7e 07                	jle    800075 <libmain+0x31>
		binaryname = argv[0];
  80006e:	8b 03                	mov    (%ebx),%eax
  800070:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	53                   	push   %ebx
  800079:	56                   	push   %esi
  80007a:	e8 b5 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0c 00 00 00       	call   800090 <exit>
  800084:	83 c4 10             	add    $0x10,%esp
}
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 cb 04 00 00       	call   800566 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 9e 00 00 00       	call   800143 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 1c             	sub    $0x1c,%esp
  8000b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c9:	cd 30                	int    $0x30
  8000cb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d1:	74 1c                	je     8000ef <syscall+0x43>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7e 18                	jle    8000ef <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000de:	68 ca 1d 80 00       	push   $0x801dca
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 e7 1d 80 00       	push   $0x801de7
  8000ea:	e8 21 0f 00 00       	call   801010 <_panic>

	return ret;
}
  8000ef:	89 d0                	mov    %edx,%eax
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ff:	6a 00                	push   $0x0
  800101:	6a 00                	push   $0x0
  800103:	6a 00                	push   $0x0
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010b:	ba 00 00 00 00       	mov    $0x0,%edx
  800110:	b8 00 00 00 00       	mov    $0x0,%eax
  800115:	e8 92 ff ff ff       	call   8000ac <syscall>
  80011a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <sys_cgetc>:

int
sys_cgetc(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 01 00 00 00       	mov    $0x1,%eax
  80013c:	e8 6b ff ff ff       	call   8000ac <syscall>
}
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800154:	ba 01 00 00 00       	mov    $0x1,%edx
  800159:	b8 03 00 00 00       	mov    $0x3,%eax
  80015e:	e8 49 ff ff ff       	call   8000ac <syscall>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	b9 00 00 00 00       	mov    $0x0,%ecx
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	e8 25 ff ff ff       	call   8000ac <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_yield>:

void
sys_yield(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a6:	e8 01 ff ff ff       	call   8000ac <syscall>
  8001ab:	83 c4 10             	add    $0x10,%esp
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b6:	6a 00                	push   $0x0
  8001b8:	6a 00                	push   $0x0
  8001ba:	ff 75 10             	pushl  0x10(%ebp)
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cd:	e8 da fe ff ff       	call   8000ac <syscall>
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	ff 75 14             	pushl  0x14(%ebp)
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	e8 b4 fe ff ff       	call   8000ac <syscall>
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800200:	6a 00                	push   $0x0
  800202:	6a 00                	push   $0x0
  800204:	6a 00                	push   $0x0
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020c:	ba 01 00 00 00       	mov    $0x1,%edx
  800211:	b8 06 00 00 00       	mov    $0x6,%eax
  800216:	e8 91 fe ff ff       	call   8000ac <syscall>
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800223:	6a 00                	push   $0x0
  800225:	6a 00                	push   $0x0
  800227:	6a 00                	push   $0x0
  800229:	ff 75 0c             	pushl  0xc(%ebp)
  80022c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022f:	ba 01 00 00 00       	mov    $0x1,%edx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	e8 6e fe ff ff       	call   8000ac <syscall>
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800246:	6a 00                	push   $0x0
  800248:	6a 00                	push   $0x0
  80024a:	6a 00                	push   $0x0
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800252:	ba 01 00 00 00       	mov    $0x1,%edx
  800257:	b8 09 00 00 00       	mov    $0x9,%eax
  80025c:	e8 4b fe ff ff       	call   8000ac <syscall>
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800269:	6a 00                	push   $0x0
  80026b:	6a 00                	push   $0x0
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 0c             	pushl  0xc(%ebp)
  800272:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800275:	ba 01 00 00 00       	mov    $0x1,%edx
  80027a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027f:	e8 28 fe ff ff       	call   8000ac <syscall>
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80028c:	6a 00                	push   $0x0
  80028e:	ff 75 14             	pushl  0x14(%ebp)
  800291:	ff 75 10             	pushl  0x10(%ebp)
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a4:	e8 03 fe ff ff       	call   8000ac <syscall>
}
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b1:	6a 00                	push   $0x0
  8002b3:	6a 00                	push   $0x0
  8002b5:	6a 00                	push   $0x0
  8002b7:	6a 00                	push   $0x0
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c6:	e8 e1 fd ff ff       	call   8000ac <syscall>
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002d3:	6a 00                	push   $0x0
  8002d5:	6a 00                	push   $0x0
  8002d7:	6a 00                	push   $0x0
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002e9:	e8 be fd ff ff       	call   8000ac <syscall>
}
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  8002f6:	6a 00                	push   $0x0
  8002f8:	ff 75 14             	pushl  0x14(%ebp)
  8002fb:	ff 75 10             	pushl  0x10(%ebp)
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
  800309:	b8 0f 00 00 00       	mov    $0xf,%eax
  80030e:	e8 99 fd ff ff       	call   8000ac <syscall>
} 
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80031b:	6a 00                	push   $0x0
  80031d:	6a 00                	push   $0x0
  80031f:	6a 00                	push   $0x0
  800321:	6a 00                	push   $0x0
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
  80032b:	b8 11 00 00 00       	mov    $0x11,%eax
  800330:	e8 77 fd ff ff       	call   8000ac <syscall>
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  80033d:	6a 00                	push   $0x0
  80033f:	6a 00                	push   $0x0
  800341:	6a 00                	push   $0x0
  800343:	6a 00                	push   $0x0
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	b8 10 00 00 00       	mov    $0x10,%eax
  800354:	e8 53 fd ff ff       	call   8000ac <syscall>
  800359:	c9                   	leave  
  80035a:	c3                   	ret    
	...

0080035c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	05 00 00 00 30       	add    $0x30000000,%eax
  800367:	c1 e8 0c             	shr    $0xc,%eax
}
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036f:	ff 75 08             	pushl  0x8(%ebp)
  800372:	e8 e5 ff ff ff       	call   80035c <fd2num>
  800377:	83 c4 04             	add    $0x4,%esp
  80037a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80037f:	c1 e0 0c             	shl    $0xc,%eax
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800390:	a8 01                	test   $0x1,%al
  800392:	74 34                	je     8003c8 <fd_alloc+0x44>
  800394:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800399:	a8 01                	test   $0x1,%al
  80039b:	74 32                	je     8003cf <fd_alloc+0x4b>
  80039d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8003a2:	89 c1                	mov    %eax,%ecx
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 1f                	je     8003d4 <fd_alloc+0x50>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 17                	jne    8003dd <fd_alloc+0x59>
  8003c6:	eb 0c                	jmp    8003d4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003c8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003cd:	eb 05                	jmp    8003d4 <fd_alloc+0x50>
  8003cf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8003d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003db:	eb 17                	jmp    8003f4 <fd_alloc+0x70>
  8003dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e7:	75 b9                	jne    8003a2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8003ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f4:	5b                   	pop    %ebx
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003fd:	83 f8 1f             	cmp    $0x1f,%eax
  800400:	77 36                	ja     800438 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800402:	05 00 00 0d 00       	add    $0xd0000,%eax
  800407:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040a:	89 c2                	mov    %eax,%edx
  80040c:	c1 ea 16             	shr    $0x16,%edx
  80040f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800416:	f6 c2 01             	test   $0x1,%dl
  800419:	74 24                	je     80043f <fd_lookup+0x48>
  80041b:	89 c2                	mov    %eax,%edx
  80041d:	c1 ea 0c             	shr    $0xc,%edx
  800420:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800427:	f6 c2 01             	test   $0x1,%dl
  80042a:	74 1a                	je     800446 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80042c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042f:	89 02                	mov    %eax,(%edx)
	return 0;
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	eb 13                	jmp    80044b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 0c                	jmp    80044b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800444:	eb 05                	jmp    80044b <fd_lookup+0x54>
  800446:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044b:	c9                   	leave  
  80044c:	c3                   	ret    

0080044d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	53                   	push   %ebx
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80045a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800460:	74 0d                	je     80046f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb 14                	jmp    80047d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800469:	39 0a                	cmp    %ecx,(%edx)
  80046b:	75 10                	jne    80047d <dev_lookup+0x30>
  80046d:	eb 05                	jmp    800474 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80046f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800474:	89 13                	mov    %edx,(%ebx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 31                	jmp    8004ae <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047d:	40                   	inc    %eax
  80047e:	8b 14 85 74 1e 80 00 	mov    0x801e74(,%eax,4),%edx
  800485:	85 d2                	test   %edx,%edx
  800487:	75 e0                	jne    800469 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800489:	a1 04 40 80 00       	mov    0x804004,%eax
  80048e:	8b 40 48             	mov    0x48(%eax),%eax
  800491:	83 ec 04             	sub    $0x4,%esp
  800494:	51                   	push   %ecx
  800495:	50                   	push   %eax
  800496:	68 f8 1d 80 00       	push   $0x801df8
  80049b:	e8 48 0c 00 00       	call   8010e8 <cprintf>
	*dev = 0;
  8004a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    

008004b3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	83 ec 20             	sub    $0x20,%esp
  8004bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004be:	8a 45 0c             	mov    0xc(%ebp),%al
  8004c1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c4:	56                   	push   %esi
  8004c5:	e8 92 fe ff ff       	call   80035c <fd2num>
  8004ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8004cd:	89 14 24             	mov    %edx,(%esp)
  8004d0:	50                   	push   %eax
  8004d1:	e8 21 ff ff ff       	call   8003f7 <fd_lookup>
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	83 c4 08             	add    $0x8,%esp
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	78 05                	js     8004e4 <fd_close+0x31>
	    || fd != fd2)
  8004df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e2:	74 0d                	je     8004f1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8004e4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8004e8:	75 48                	jne    800532 <fd_close+0x7f>
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ef:	eb 41                	jmp    800532 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f7:	50                   	push   %eax
  8004f8:	ff 36                	pushl  (%esi)
  8004fa:	e8 4e ff ff ff       	call   80044d <dev_lookup>
  8004ff:	89 c3                	mov    %eax,%ebx
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 1c                	js     800524 <fd_close+0x71>
		if (dev->dev_close)
  800508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050b:	8b 40 10             	mov    0x10(%eax),%eax
  80050e:	85 c0                	test   %eax,%eax
  800510:	74 0d                	je     80051f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800512:	83 ec 0c             	sub    $0xc,%esp
  800515:	56                   	push   %esi
  800516:	ff d0                	call   *%eax
  800518:	89 c3                	mov    %eax,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 05                	jmp    800524 <fd_close+0x71>
		else
			r = 0;
  80051f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	56                   	push   %esi
  800528:	6a 00                	push   $0x0
  80052a:	e8 cb fc ff ff       	call   8001fa <sys_page_unmap>
	return r;
  80052f:	83 c4 10             	add    $0x10,%esp
}
  800532:	89 d8                	mov    %ebx,%eax
  800534:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800541:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	e8 aa fe ff ff       	call   8003f7 <fd_lookup>
  80054d:	83 c4 08             	add    $0x8,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	78 10                	js     800564 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	6a 01                	push   $0x1
  800559:	ff 75 f4             	pushl  -0xc(%ebp)
  80055c:	e8 52 ff ff ff       	call   8004b3 <fd_close>
  800561:	83 c4 10             	add    $0x10,%esp
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    

00800566 <close_all>:

void
close_all(void)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	53                   	push   %ebx
  80056a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800572:	83 ec 0c             	sub    $0xc,%esp
  800575:	53                   	push   %ebx
  800576:	e8 c0 ff ff ff       	call   80053b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057b:	43                   	inc    %ebx
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	83 fb 20             	cmp    $0x20,%ebx
  800582:	75 ee                	jne    800572 <close_all+0xc>
		close(i);
}
  800584:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800587:	c9                   	leave  
  800588:	c3                   	ret    

00800589 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	57                   	push   %edi
  80058d:	56                   	push   %esi
  80058e:	53                   	push   %ebx
  80058f:	83 ec 2c             	sub    $0x2c,%esp
  800592:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800595:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	ff 75 08             	pushl  0x8(%ebp)
  80059c:	e8 56 fe ff ff       	call   8003f7 <fd_lookup>
  8005a1:	89 c3                	mov    %eax,%ebx
  8005a3:	83 c4 08             	add    $0x8,%esp
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	0f 88 c0 00 00 00    	js     80066e <dup+0xe5>
		return r;
	close(newfdnum);
  8005ae:	83 ec 0c             	sub    $0xc,%esp
  8005b1:	57                   	push   %edi
  8005b2:	e8 84 ff ff ff       	call   80053b <close>

	newfd = INDEX2FD(newfdnum);
  8005b7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8005bd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8005c0:	83 c4 04             	add    $0x4,%esp
  8005c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c6:	e8 a1 fd ff ff       	call   80036c <fd2data>
  8005cb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005cd:	89 34 24             	mov    %esi,(%esp)
  8005d0:	e8 97 fd ff ff       	call   80036c <fd2data>
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005db:	89 d8                	mov    %ebx,%eax
  8005dd:	c1 e8 16             	shr    $0x16,%eax
  8005e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e7:	a8 01                	test   $0x1,%al
  8005e9:	74 37                	je     800622 <dup+0x99>
  8005eb:	89 d8                	mov    %ebx,%eax
  8005ed:	c1 e8 0c             	shr    $0xc,%eax
  8005f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f7:	f6 c2 01             	test   $0x1,%dl
  8005fa:	74 26                	je     800622 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 bb fb ff ff       	call   8001d4 <sys_page_map>
  800619:	89 c3                	mov    %eax,%ebx
  80061b:	83 c4 20             	add    $0x20,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	78 2d                	js     80064f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800625:	89 c2                	mov    %eax,%edx
  800627:	c1 ea 0c             	shr    $0xc,%edx
  80062a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800631:	83 ec 0c             	sub    $0xc,%esp
  800634:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80063a:	52                   	push   %edx
  80063b:	56                   	push   %esi
  80063c:	6a 00                	push   $0x0
  80063e:	50                   	push   %eax
  80063f:	6a 00                	push   $0x0
  800641:	e8 8e fb ff ff       	call   8001d4 <sys_page_map>
  800646:	89 c3                	mov    %eax,%ebx
  800648:	83 c4 20             	add    $0x20,%esp
  80064b:	85 c0                	test   %eax,%eax
  80064d:	79 1d                	jns    80066c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	56                   	push   %esi
  800653:	6a 00                	push   $0x0
  800655:	e8 a0 fb ff ff       	call   8001fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800660:	6a 00                	push   $0x0
  800662:	e8 93 fb ff ff       	call   8001fa <sys_page_unmap>
	return r;
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	eb 02                	jmp    80066e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80066c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80066e:	89 d8                	mov    %ebx,%eax
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	c9                   	leave  
  800677:	c3                   	ret    

00800678 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	53                   	push   %ebx
  80067c:	83 ec 14             	sub    $0x14,%esp
  80067f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800682:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	53                   	push   %ebx
  800687:	e8 6b fd ff ff       	call   8003f7 <fd_lookup>
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	85 c0                	test   %eax,%eax
  800691:	78 67                	js     8006fa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069d:	ff 30                	pushl  (%eax)
  80069f:	e8 a9 fd ff ff       	call   80044d <dev_lookup>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	78 4f                	js     8006fa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ae:	8b 50 08             	mov    0x8(%eax),%edx
  8006b1:	83 e2 03             	and    $0x3,%edx
  8006b4:	83 fa 01             	cmp    $0x1,%edx
  8006b7:	75 21                	jne    8006da <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8006be:	8b 40 48             	mov    0x48(%eax),%eax
  8006c1:	83 ec 04             	sub    $0x4,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	50                   	push   %eax
  8006c6:	68 39 1e 80 00       	push   $0x801e39
  8006cb:	e8 18 0a 00 00       	call   8010e8 <cprintf>
		return -E_INVAL;
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d8:	eb 20                	jmp    8006fa <read+0x82>
	}
	if (!dev->dev_read)
  8006da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006dd:	8b 52 08             	mov    0x8(%edx),%edx
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	74 11                	je     8006f5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	50                   	push   %eax
  8006ee:	ff d2                	call   *%edx
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 05                	jmp    8006fa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	83 ec 0c             	sub    $0xc,%esp
  800708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070e:	85 f6                	test   %esi,%esi
  800710:	74 31                	je     800743 <readn+0x44>
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071c:	83 ec 04             	sub    $0x4,%esp
  80071f:	89 f2                	mov    %esi,%edx
  800721:	29 c2                	sub    %eax,%edx
  800723:	52                   	push   %edx
  800724:	03 45 0c             	add    0xc(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	57                   	push   %edi
  800729:	e8 4a ff ff ff       	call   800678 <read>
		if (m < 0)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	85 c0                	test   %eax,%eax
  800733:	78 17                	js     80074c <readn+0x4d>
			return m;
		if (m == 0)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 11                	je     80074a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800739:	01 c3                	add    %eax,%ebx
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	39 f3                	cmp    %esi,%ebx
  80073f:	72 db                	jb     80071c <readn+0x1d>
  800741:	eb 09                	jmp    80074c <readn+0x4d>
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 02                	jmp    80074c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80074a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	83 ec 14             	sub    $0x14,%esp
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	53                   	push   %ebx
  800763:	e8 8f fc ff ff       	call   8003f7 <fd_lookup>
  800768:	83 c4 08             	add    $0x8,%esp
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 62                	js     8007d1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800779:	ff 30                	pushl  (%eax)
  80077b:	e8 cd fc ff ff       	call   80044d <dev_lookup>
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	85 c0                	test   %eax,%eax
  800785:	78 4a                	js     8007d1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078e:	75 21                	jne    8007b1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800790:	a1 04 40 80 00       	mov    0x804004,%eax
  800795:	8b 40 48             	mov    0x48(%eax),%eax
  800798:	83 ec 04             	sub    $0x4,%esp
  80079b:	53                   	push   %ebx
  80079c:	50                   	push   %eax
  80079d:	68 55 1e 80 00       	push   $0x801e55
  8007a2:	e8 41 09 00 00       	call   8010e8 <cprintf>
		return -E_INVAL;
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007af:	eb 20                	jmp    8007d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 11                	je     8007cc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bb:	83 ec 04             	sub    $0x4,%esp
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	50                   	push   %eax
  8007c5:	ff d2                	call   *%edx
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb 05                	jmp    8007d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	ff 75 08             	pushl  0x8(%ebp)
  8007e3:	e8 0f fc ff ff       	call   8003f7 <fd_lookup>
  8007e8:	83 c4 08             	add    $0x8,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 0e                	js     8007fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	83 ec 14             	sub    $0x14,%esp
  800806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800809:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	53                   	push   %ebx
  80080e:	e8 e4 fb ff ff       	call   8003f7 <fd_lookup>
  800813:	83 c4 08             	add    $0x8,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 5f                	js     800879 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800824:	ff 30                	pushl  (%eax)
  800826:	e8 22 fc ff ff       	call   80044d <dev_lookup>
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	85 c0                	test   %eax,%eax
  800830:	78 47                	js     800879 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800835:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800839:	75 21                	jne    80085c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800840:	8b 40 48             	mov    0x48(%eax),%eax
  800843:	83 ec 04             	sub    $0x4,%esp
  800846:	53                   	push   %ebx
  800847:	50                   	push   %eax
  800848:	68 18 1e 80 00       	push   $0x801e18
  80084d:	e8 96 08 00 00       	call   8010e8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085a:	eb 1d                	jmp    800879 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80085c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085f:	8b 52 18             	mov    0x18(%edx),%edx
  800862:	85 d2                	test   %edx,%edx
  800864:	74 0e                	je     800874 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	50                   	push   %eax
  80086d:	ff d2                	call   *%edx
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	eb 05                	jmp    800879 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800874:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	83 ec 14             	sub    $0x14,%esp
  800885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	ff 75 08             	pushl  0x8(%ebp)
  80088f:	e8 63 fb ff ff       	call   8003f7 <fd_lookup>
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	85 c0                	test   %eax,%eax
  800899:	78 52                	js     8008ed <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a5:	ff 30                	pushl  (%eax)
  8008a7:	e8 a1 fb ff ff       	call   80044d <dev_lookup>
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	78 3a                	js     8008ed <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ba:	74 2c                	je     8008e8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c6:	00 00 00 
	stat->st_isdir = 0;
  8008c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d0:	00 00 00 
	stat->st_dev = dev;
  8008d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e0:	ff 50 14             	call   *0x14(%eax)
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	eb 05                	jmp    8008ed <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	6a 00                	push   $0x0
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 78 01 00 00       	call   800a7c <open>
  800904:	89 c3                	mov    %eax,%ebx
  800906:	83 c4 10             	add    $0x10,%esp
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 1b                	js     800928 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	ff 75 0c             	pushl  0xc(%ebp)
  800913:	50                   	push   %eax
  800914:	e8 65 ff ff ff       	call   80087e <fstat>
  800919:	89 c6                	mov    %eax,%esi
	close(fd);
  80091b:	89 1c 24             	mov    %ebx,(%esp)
  80091e:	e8 18 fc ff ff       	call   80053b <close>
	return r;
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	89 f3                	mov    %esi,%ebx
}
  800928:	89 d8                	mov    %ebx,%eax
  80092a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	c9                   	leave  
  800930:	c3                   	ret    
  800931:	00 00                	add    %al,(%eax)
	...

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c3                	mov    %eax,%ebx
  80093b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 96 11 00 00       	call   801ae6 <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	53                   	push   %ebx
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 26 11 00 00       	call   801a91 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	56                   	push   %esi
  800971:	6a 00                	push   $0x0
  800973:	e8 a4 10 00 00       	call   801a1c <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	83 ec 04             	sub    $0x4,%esp
  800986:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 40 0c             	mov    0xc(%eax),%eax
  80098f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800994:	ba 00 00 00 00       	mov    $0x0,%edx
  800999:	b8 05 00 00 00       	mov    $0x5,%eax
  80099e:	e8 91 ff ff ff       	call   800934 <fsipc>
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 2c                	js     8009d3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	68 00 50 80 00       	push   $0x805000
  8009af:	53                   	push   %ebx
  8009b0:	e8 e9 0c 00 00       	call   80169e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f3:	e8 3c ff ff ff       	call   800934 <fsipc>
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 40 0c             	mov    0xc(%eax),%eax
  800a08:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a0d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a13:	ba 00 00 00 00       	mov    $0x0,%edx
  800a18:	b8 03 00 00 00       	mov    $0x3,%eax
  800a1d:	e8 12 ff ff ff       	call   800934 <fsipc>
  800a22:	89 c3                	mov    %eax,%ebx
  800a24:	85 c0                	test   %eax,%eax
  800a26:	78 4b                	js     800a73 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a28:	39 c6                	cmp    %eax,%esi
  800a2a:	73 16                	jae    800a42 <devfile_read+0x48>
  800a2c:	68 84 1e 80 00       	push   $0x801e84
  800a31:	68 8b 1e 80 00       	push   $0x801e8b
  800a36:	6a 7d                	push   $0x7d
  800a38:	68 a0 1e 80 00       	push   $0x801ea0
  800a3d:	e8 ce 05 00 00       	call   801010 <_panic>
	assert(r <= PGSIZE);
  800a42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a47:	7e 16                	jle    800a5f <devfile_read+0x65>
  800a49:	68 ab 1e 80 00       	push   $0x801eab
  800a4e:	68 8b 1e 80 00       	push   $0x801e8b
  800a53:	6a 7e                	push   $0x7e
  800a55:	68 a0 1e 80 00       	push   $0x801ea0
  800a5a:	e8 b1 05 00 00       	call   801010 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	50                   	push   %eax
  800a63:	68 00 50 80 00       	push   $0x805000
  800a68:	ff 75 0c             	pushl  0xc(%ebp)
  800a6b:	e8 ef 0d 00 00       	call   80185f <memmove>
	return r;
  800a70:	83 c4 10             	add    $0x10,%esp
}
  800a73:	89 d8                	mov    %ebx,%eax
  800a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 1c             	sub    $0x1c,%esp
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a87:	56                   	push   %esi
  800a88:	e8 bf 0b 00 00       	call   80164c <strlen>
  800a8d:	83 c4 10             	add    $0x10,%esp
  800a90:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a95:	7f 65                	jg     800afc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a97:	83 ec 0c             	sub    $0xc,%esp
  800a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9d:	50                   	push   %eax
  800a9e:	e8 e1 f8 ff ff       	call   800384 <fd_alloc>
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	83 c4 10             	add    $0x10,%esp
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	78 55                	js     800b01 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	56                   	push   %esi
  800ab0:	68 00 50 80 00       	push   $0x805000
  800ab5:	e8 e4 0b 00 00       	call   80169e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aca:	e8 65 fe ff ff       	call   800934 <fsipc>
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	85 c0                	test   %eax,%eax
  800ad6:	79 12                	jns    800aea <open+0x6e>
		fd_close(fd, 0);
  800ad8:	83 ec 08             	sub    $0x8,%esp
  800adb:	6a 00                	push   $0x0
  800add:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae0:	e8 ce f9 ff ff       	call   8004b3 <fd_close>
		return r;
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	eb 17                	jmp    800b01 <open+0x85>
	}

	return fd2num(fd);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	ff 75 f4             	pushl  -0xc(%ebp)
  800af0:	e8 67 f8 ff ff       	call   80035c <fd2num>
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	eb 05                	jmp    800b01 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800afc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    
	...

00800b0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	ff 75 08             	pushl  0x8(%ebp)
  800b1a:	e8 4d f8 ff ff       	call   80036c <fd2data>
  800b1f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800b21:	83 c4 08             	add    $0x8,%esp
  800b24:	68 b7 1e 80 00       	push   $0x801eb7
  800b29:	56                   	push   %esi
  800b2a:	e8 6f 0b 00 00       	call   80169e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b2f:	8b 43 04             	mov    0x4(%ebx),%eax
  800b32:	2b 03                	sub    (%ebx),%eax
  800b34:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800b3a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800b41:	00 00 00 
	stat->st_dev = &devpipe;
  800b44:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800b4b:	30 80 00 
	return 0;
}
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b64:	53                   	push   %ebx
  800b65:	6a 00                	push   $0x0
  800b67:	e8 8e f6 ff ff       	call   8001fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b6c:	89 1c 24             	mov    %ebx,(%esp)
  800b6f:	e8 f8 f7 ff ff       	call   80036c <fd2data>
  800b74:	83 c4 08             	add    $0x8,%esp
  800b77:	50                   	push   %eax
  800b78:	6a 00                	push   $0x0
  800b7a:	e8 7b f6 ff ff       	call   8001fa <sys_page_unmap>
}
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 1c             	sub    $0x1c,%esp
  800b8d:	89 c7                	mov    %eax,%edi
  800b8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b92:	a1 04 40 80 00       	mov    0x804004,%eax
  800b97:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	57                   	push   %edi
  800b9e:	e8 91 0f 00 00       	call   801b34 <pageref>
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	83 c4 04             	add    $0x4,%esp
  800ba8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bab:	e8 84 0f 00 00       	call   801b34 <pageref>
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	39 c6                	cmp    %eax,%esi
  800bb5:	0f 94 c0             	sete   %al
  800bb8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800bbb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bc1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bc4:	39 cb                	cmp    %ecx,%ebx
  800bc6:	75 08                	jne    800bd0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800bd0:	83 f8 01             	cmp    $0x1,%eax
  800bd3:	75 bd                	jne    800b92 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bd5:	8b 42 58             	mov    0x58(%edx),%eax
  800bd8:	6a 01                	push   $0x1
  800bda:	50                   	push   %eax
  800bdb:	53                   	push   %ebx
  800bdc:	68 be 1e 80 00       	push   $0x801ebe
  800be1:	e8 02 05 00 00       	call   8010e8 <cprintf>
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	eb a7                	jmp    800b92 <_pipeisclosed+0xe>

00800beb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 28             	sub    $0x28,%esp
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bf7:	56                   	push   %esi
  800bf8:	e8 6f f7 ff ff       	call   80036c <fd2data>
  800bfd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c06:	75 4a                	jne    800c52 <devpipe_write+0x67>
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0d:	eb 56                	jmp    800c65 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c0f:	89 da                	mov    %ebx,%edx
  800c11:	89 f0                	mov    %esi,%eax
  800c13:	e8 6c ff ff ff       	call   800b84 <_pipeisclosed>
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	75 4d                	jne    800c69 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c1c:	e8 68 f5 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c21:	8b 43 04             	mov    0x4(%ebx),%eax
  800c24:	8b 13                	mov    (%ebx),%edx
  800c26:	83 c2 20             	add    $0x20,%edx
  800c29:	39 d0                	cmp    %edx,%eax
  800c2b:	73 e2                	jae    800c0f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800c35:	79 05                	jns    800c3c <devpipe_write+0x51>
  800c37:	4a                   	dec    %edx
  800c38:	83 ca e0             	or     $0xffffffe0,%edx
  800c3b:	42                   	inc    %edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800c42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c46:	40                   	inc    %eax
  800c47:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	47                   	inc    %edi
  800c4b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c4e:	77 07                	ja     800c57 <devpipe_write+0x6c>
  800c50:	eb 13                	jmp    800c65 <devpipe_write+0x7a>
  800c52:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c57:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5a:	8b 13                	mov    (%ebx),%edx
  800c5c:	83 c2 20             	add    $0x20,%edx
  800c5f:	39 d0                	cmp    %edx,%eax
  800c61:	73 ac                	jae    800c0f <devpipe_write+0x24>
  800c63:	eb c8                	jmp    800c2d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c65:	89 f8                	mov    %edi,%eax
  800c67:	eb 05                	jmp    800c6e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 18             	sub    $0x18,%esp
  800c7f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c82:	57                   	push   %edi
  800c83:	e8 e4 f6 ff ff       	call   80036c <fd2data>
  800c88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c91:	75 44                	jne    800cd7 <devpipe_read+0x61>
  800c93:	be 00 00 00 00       	mov    $0x0,%esi
  800c98:	eb 4f                	jmp    800ce9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c9a:	89 f0                	mov    %esi,%eax
  800c9c:	eb 54                	jmp    800cf2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c9e:	89 da                	mov    %ebx,%edx
  800ca0:	89 f8                	mov    %edi,%eax
  800ca2:	e8 dd fe ff ff       	call   800b84 <_pipeisclosed>
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	75 42                	jne    800ced <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cab:	e8 d9 f4 ff ff       	call   800189 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cb0:	8b 03                	mov    (%ebx),%eax
  800cb2:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb5:	74 e7                	je     800c9e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cb7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cbc:	79 05                	jns    800cc3 <devpipe_read+0x4d>
  800cbe:	48                   	dec    %eax
  800cbf:	83 c8 e0             	or     $0xffffffe0,%eax
  800cc2:	40                   	inc    %eax
  800cc3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ccd:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccf:	46                   	inc    %esi
  800cd0:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cd3:	77 07                	ja     800cdc <devpipe_read+0x66>
  800cd5:	eb 12                	jmp    800ce9 <devpipe_read+0x73>
  800cd7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800cdc:	8b 03                	mov    (%ebx),%eax
  800cde:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ce1:	75 d4                	jne    800cb7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce3:	85 f6                	test   %esi,%esi
  800ce5:	75 b3                	jne    800c9a <devpipe_read+0x24>
  800ce7:	eb b5                	jmp    800c9e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ce9:	89 f0                	mov    %esi,%eax
  800ceb:	eb 05                	jmp    800cf2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 28             	sub    $0x28,%esp
  800d03:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d06:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d09:	50                   	push   %eax
  800d0a:	e8 75 f6 ff ff       	call   800384 <fd_alloc>
  800d0f:	89 c3                	mov    %eax,%ebx
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	85 c0                	test   %eax,%eax
  800d16:	0f 88 24 01 00 00    	js     800e40 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1c:	83 ec 04             	sub    $0x4,%esp
  800d1f:	68 07 04 00 00       	push   $0x407
  800d24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d27:	6a 00                	push   $0x0
  800d29:	e8 82 f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	0f 88 05 01 00 00    	js     800e40 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800d41:	50                   	push   %eax
  800d42:	e8 3d f6 ff ff       	call   800384 <fd_alloc>
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	83 c4 10             	add    $0x10,%esp
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	0f 88 dc 00 00 00    	js     800e30 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	68 07 04 00 00       	push   $0x407
  800d5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d5f:	6a 00                	push   $0x0
  800d61:	e8 4a f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d66:	89 c3                	mov    %eax,%ebx
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	0f 88 bd 00 00 00    	js     800e30 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d79:	e8 ee f5 ff ff       	call   80036c <fd2data>
  800d7e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d80:	83 c4 0c             	add    $0xc,%esp
  800d83:	68 07 04 00 00       	push   $0x407
  800d88:	50                   	push   %eax
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 20 f4 ff ff       	call   8001b0 <sys_page_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 83 00 00 00    	js     800e20 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	ff 75 e0             	pushl  -0x20(%ebp)
  800da3:	e8 c4 f5 ff ff       	call   80036c <fd2data>
  800da8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800daf:	50                   	push   %eax
  800db0:	6a 00                	push   $0x0
  800db2:	56                   	push   %esi
  800db3:	6a 00                	push   $0x0
  800db5:	e8 1a f4 ff ff       	call   8001d4 <sys_page_map>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	78 4f                	js     800e12 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800de1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800de6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800df3:	e8 64 f5 ff ff       	call   80035c <fd2num>
  800df8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800dfa:	83 c4 04             	add    $0x4,%esp
  800dfd:	ff 75 e0             	pushl  -0x20(%ebp)
  800e00:	e8 57 f5 ff ff       	call   80035c <fd2num>
  800e05:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	eb 2e                	jmp    800e40 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	56                   	push   %esi
  800e16:	6a 00                	push   $0x0
  800e18:	e8 dd f3 ff ff       	call   8001fa <sys_page_unmap>
  800e1d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	ff 75 e0             	pushl  -0x20(%ebp)
  800e26:	6a 00                	push   $0x0
  800e28:	e8 cd f3 ff ff       	call   8001fa <sys_page_unmap>
  800e2d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e36:	6a 00                	push   $0x0
  800e38:	e8 bd f3 ff ff       	call   8001fa <sys_page_unmap>
  800e3d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e53:	50                   	push   %eax
  800e54:	ff 75 08             	pushl  0x8(%ebp)
  800e57:	e8 9b f5 ff ff       	call   8003f7 <fd_lookup>
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 18                	js     800e7b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	e8 fe f4 ff ff       	call   80036c <fd2data>
	return _pipeisclosed(fd, p);
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e73:	e8 0c fd ff ff       	call   800b84 <_pipeisclosed>
  800e78:	83 c4 10             	add    $0x10,%esp
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    
  800e7d:	00 00                	add    %al,(%eax)
	...

00800e80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e90:	68 d6 1e 80 00       	push   $0x801ed6
  800e95:	ff 75 0c             	pushl  0xc(%ebp)
  800e98:	e8 01 08 00 00       	call   80169e <strcpy>
	return 0;
}
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb4:	74 45                	je     800efb <devcons_write+0x57>
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ecb:	83 fb 7f             	cmp    $0x7f,%ebx
  800ece:	76 05                	jbe    800ed5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ed0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	53                   	push   %ebx
  800ed9:	03 45 0c             	add    0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	57                   	push   %edi
  800ede:	e8 7c 09 00 00       	call   80185f <memmove>
		sys_cputs(buf, m);
  800ee3:	83 c4 08             	add    $0x8,%esp
  800ee6:	53                   	push   %ebx
  800ee7:	57                   	push   %edi
  800ee8:	e8 0c f2 ff ff       	call   8000f9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eed:	01 de                	add    %ebx,%esi
  800eef:	89 f0                	mov    %esi,%eax
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef7:	72 cd                	jb     800ec6 <devcons_write+0x22>
  800ef9:	eb 05                	jmp    800f00 <devcons_write+0x5c>
  800efb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f14:	75 07                	jne    800f1d <devcons_read+0x13>
  800f16:	eb 25                	jmp    800f3d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f18:	e8 6c f2 ff ff       	call   800189 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f1d:	e8 fd f1 ff ff       	call   80011f <sys_cgetc>
  800f22:	85 c0                	test   %eax,%eax
  800f24:	74 f2                	je     800f18 <devcons_read+0xe>
  800f26:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	78 1d                	js     800f49 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f2c:	83 f8 04             	cmp    $0x4,%eax
  800f2f:	74 13                	je     800f44 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800f31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f34:	88 10                	mov    %dl,(%eax)
	return 1;
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	eb 0c                	jmp    800f49 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 05                	jmp    800f49 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f57:	6a 01                	push   $0x1
  800f59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5c:	50                   	push   %eax
  800f5d:	e8 97 f1 ff ff       	call   8000f9 <sys_cputs>
  800f62:	83 c4 10             	add    $0x10,%esp
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <getchar>:

int
getchar(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f6d:	6a 01                	push   $0x1
  800f6f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	6a 00                	push   $0x0
  800f75:	e8 fe f6 ff ff       	call   800678 <read>
	if (r < 0)
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 0f                	js     800f90 <getchar+0x29>
		return r;
	if (r < 1)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	7e 06                	jle    800f8b <getchar+0x24>
		return -E_EOF;
	return c;
  800f85:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f89:	eb 05                	jmp    800f90 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f8b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	ff 75 08             	pushl  0x8(%ebp)
  800f9f:	e8 53 f4 ff ff       	call   8003f7 <fd_lookup>
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 11                	js     800fbc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb4:	39 10                	cmp    %edx,(%eax)
  800fb6:	0f 94 c0             	sete   %al
  800fb9:	0f b6 c0             	movzbl %al,%eax
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <opencons>:

int
opencons(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc7:	50                   	push   %eax
  800fc8:	e8 b7 f3 ff ff       	call   800384 <fd_alloc>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 3a                	js     80100e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 07 04 00 00       	push   $0x407
  800fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 ca f1 ff ff       	call   8001b0 <sys_page_alloc>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 21                	js     80100e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fed:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	50                   	push   %eax
  801006:	e8 51 f3 ff ff       	call   80035c <fd2num>
  80100b:	83 c4 10             	add    $0x10,%esp
}
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    

00801010 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801015:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801018:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80101e:	e8 42 f1 ff ff       	call   800165 <sys_getenvid>
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	ff 75 08             	pushl  0x8(%ebp)
  80102c:	53                   	push   %ebx
  80102d:	50                   	push   %eax
  80102e:	68 e4 1e 80 00       	push   $0x801ee4
  801033:	e8 b0 00 00 00       	call   8010e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801038:	83 c4 18             	add    $0x18,%esp
  80103b:	56                   	push   %esi
  80103c:	ff 75 10             	pushl  0x10(%ebp)
  80103f:	e8 53 00 00 00       	call   801097 <vcprintf>
	cprintf("\n");
  801044:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80104b:	e8 98 00 00 00       	call   8010e8 <cprintf>
  801050:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801053:	cc                   	int3   
  801054:	eb fd                	jmp    801053 <_panic+0x43>
	...

00801058 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801062:	8b 03                	mov    (%ebx),%eax
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80106b:	40                   	inc    %eax
  80106c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80106e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801073:	75 1a                	jne    80108f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	68 ff 00 00 00       	push   $0xff
  80107d:	8d 43 08             	lea    0x8(%ebx),%eax
  801080:	50                   	push   %eax
  801081:	e8 73 f0 ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  801086:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80108f:	ff 43 04             	incl   0x4(%ebx)
}
  801092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a7:	00 00 00 
	b.cnt = 0;
  8010aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b4:	ff 75 0c             	pushl  0xc(%ebp)
  8010b7:	ff 75 08             	pushl  0x8(%ebp)
  8010ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	68 58 10 80 00       	push   $0x801058
  8010c6:	e8 82 01 00 00       	call   80124d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010cb:	83 c4 08             	add    $0x8,%esp
  8010ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010da:	50                   	push   %eax
  8010db:	e8 19 f0 ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  8010e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f1:	50                   	push   %eax
  8010f2:	ff 75 08             	pushl  0x8(%ebp)
  8010f5:	e8 9d ff ff ff       	call   801097 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 2c             	sub    $0x2c,%esp
  801105:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801108:	89 d6                	mov    %edx,%esi
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801110:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801113:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801116:	8b 45 10             	mov    0x10(%ebp),%eax
  801119:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80111c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801122:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801129:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80112c:	72 0c                	jb     80113a <printnum+0x3e>
  80112e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801131:	76 07                	jbe    80113a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801133:	4b                   	dec    %ebx
  801134:	85 db                	test   %ebx,%ebx
  801136:	7f 31                	jg     801169 <printnum+0x6d>
  801138:	eb 3f                	jmp    801179 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	57                   	push   %edi
  80113e:	4b                   	dec    %ebx
  80113f:	53                   	push   %ebx
  801140:	50                   	push   %eax
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	ff 75 d4             	pushl  -0x2c(%ebp)
  801147:	ff 75 d0             	pushl  -0x30(%ebp)
  80114a:	ff 75 dc             	pushl  -0x24(%ebp)
  80114d:	ff 75 d8             	pushl  -0x28(%ebp)
  801150:	e8 23 0a 00 00       	call   801b78 <__udivdi3>
  801155:	83 c4 18             	add    $0x18,%esp
  801158:	52                   	push   %edx
  801159:	50                   	push   %eax
  80115a:	89 f2                	mov    %esi,%edx
  80115c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80115f:	e8 98 ff ff ff       	call   8010fc <printnum>
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	eb 10                	jmp    801179 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	56                   	push   %esi
  80116d:	57                   	push   %edi
  80116e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801171:	4b                   	dec    %ebx
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 db                	test   %ebx,%ebx
  801177:	7f f0                	jg     801169 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	56                   	push   %esi
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	ff 75 d4             	pushl  -0x2c(%ebp)
  801183:	ff 75 d0             	pushl  -0x30(%ebp)
  801186:	ff 75 dc             	pushl  -0x24(%ebp)
  801189:	ff 75 d8             	pushl  -0x28(%ebp)
  80118c:	e8 03 0b 00 00       	call   801c94 <__umoddi3>
  801191:	83 c4 14             	add    $0x14,%esp
  801194:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  80119b:	50                   	push   %eax
  80119c:	ff 55 e4             	call   *-0x1c(%ebp)
  80119f:	83 c4 10             	add    $0x10,%esp
}
  8011a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ad:	83 fa 01             	cmp    $0x1,%edx
  8011b0:	7e 0e                	jle    8011c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b2:	8b 10                	mov    (%eax),%edx
  8011b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b7:	89 08                	mov    %ecx,(%eax)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	8b 52 04             	mov    0x4(%edx),%edx
  8011be:	eb 22                	jmp    8011e2 <getuint+0x38>
	else if (lflag)
  8011c0:	85 d2                	test   %edx,%edx
  8011c2:	74 10                	je     8011d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c4:	8b 10                	mov    (%eax),%edx
  8011c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c9:	89 08                	mov    %ecx,(%eax)
  8011cb:	8b 02                	mov    (%edx),%eax
  8011cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d2:	eb 0e                	jmp    8011e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d4:	8b 10                	mov    (%eax),%edx
  8011d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d9:	89 08                	mov    %ecx,(%eax)
  8011db:	8b 02                	mov    (%edx),%eax
  8011dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e7:	83 fa 01             	cmp    $0x1,%edx
  8011ea:	7e 0e                	jle    8011fa <getint+0x16>
		return va_arg(*ap, long long);
  8011ec:	8b 10                	mov    (%eax),%edx
  8011ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f1:	89 08                	mov    %ecx,(%eax)
  8011f3:	8b 02                	mov    (%edx),%eax
  8011f5:	8b 52 04             	mov    0x4(%edx),%edx
  8011f8:	eb 1a                	jmp    801214 <getint+0x30>
	else if (lflag)
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	74 0c                	je     80120a <getint+0x26>
		return va_arg(*ap, long);
  8011fe:	8b 10                	mov    (%eax),%edx
  801200:	8d 4a 04             	lea    0x4(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	99                   	cltd   
  801208:	eb 0a                	jmp    801214 <getint+0x30>
	else
		return va_arg(*ap, int);
  80120a:	8b 10                	mov    (%eax),%edx
  80120c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120f:	89 08                	mov    %ecx,(%eax)
  801211:	8b 02                	mov    (%edx),%eax
  801213:	99                   	cltd   
}
  801214:	c9                   	leave  
  801215:	c3                   	ret    

00801216 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80121c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80121f:	8b 10                	mov    (%eax),%edx
  801221:	3b 50 04             	cmp    0x4(%eax),%edx
  801224:	73 08                	jae    80122e <sprintputch+0x18>
		*b->buf++ = ch;
  801226:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801229:	88 0a                	mov    %cl,(%edx)
  80122b:	42                   	inc    %edx
  80122c:	89 10                	mov    %edx,(%eax)
}
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801236:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801239:	50                   	push   %eax
  80123a:	ff 75 10             	pushl  0x10(%ebp)
  80123d:	ff 75 0c             	pushl  0xc(%ebp)
  801240:	ff 75 08             	pushl  0x8(%ebp)
  801243:	e8 05 00 00 00       	call   80124d <vprintfmt>
	va_end(ap);
  801248:	83 c4 10             	add    $0x10,%esp
}
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 2c             	sub    $0x2c,%esp
  801256:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801259:	8b 75 10             	mov    0x10(%ebp),%esi
  80125c:	eb 13                	jmp    801271 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125e:	85 c0                	test   %eax,%eax
  801260:	0f 84 6d 03 00 00    	je     8015d3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	57                   	push   %edi
  80126a:	50                   	push   %eax
  80126b:	ff 55 08             	call   *0x8(%ebp)
  80126e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801271:	0f b6 06             	movzbl (%esi),%eax
  801274:	46                   	inc    %esi
  801275:	83 f8 25             	cmp    $0x25,%eax
  801278:	75 e4                	jne    80125e <vprintfmt+0x11>
  80127a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80127e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801285:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80128c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801293:	b9 00 00 00 00       	mov    $0x0,%ecx
  801298:	eb 28                	jmp    8012c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8012a0:	eb 20                	jmp    8012c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012a4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8012a8:	eb 18                	jmp    8012c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012aa:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8012ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012b3:	eb 0d                	jmp    8012c2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8012b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8a 06                	mov    (%esi),%al
  8012c4:	0f b6 d0             	movzbl %al,%edx
  8012c7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8012ca:	83 e8 23             	sub    $0x23,%eax
  8012cd:	3c 55                	cmp    $0x55,%al
  8012cf:	0f 87 e0 02 00 00    	ja     8015b5 <vprintfmt+0x368>
  8012d5:	0f b6 c0             	movzbl %al,%eax
  8012d8:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012df:	83 ea 30             	sub    $0x30,%edx
  8012e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8012e5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8012e8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012eb:	83 fa 09             	cmp    $0x9,%edx
  8012ee:	77 44                	ja     801334 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	89 de                	mov    %ebx,%esi
  8012f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012f6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8012f9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8012fd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801300:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801303:	83 fb 09             	cmp    $0x9,%ebx
  801306:	76 ed                	jbe    8012f5 <vprintfmt+0xa8>
  801308:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80130b:	eb 29                	jmp    801336 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130d:	8b 45 14             	mov    0x14(%ebp),%eax
  801310:	8d 50 04             	lea    0x4(%eax),%edx
  801313:	89 55 14             	mov    %edx,0x14(%ebp)
  801316:	8b 00                	mov    (%eax),%eax
  801318:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80131d:	eb 17                	jmp    801336 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80131f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801323:	78 85                	js     8012aa <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	89 de                	mov    %ebx,%esi
  801327:	eb 99                	jmp    8012c2 <vprintfmt+0x75>
  801329:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801332:	eb 8e                	jmp    8012c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801334:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801336:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80133a:	79 86                	jns    8012c2 <vprintfmt+0x75>
  80133c:	e9 74 ff ff ff       	jmp    8012b5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801341:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801342:	89 de                	mov    %ebx,%esi
  801344:	e9 79 ff ff ff       	jmp    8012c2 <vprintfmt+0x75>
  801349:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134c:	8b 45 14             	mov    0x14(%ebp),%eax
  80134f:	8d 50 04             	lea    0x4(%eax),%edx
  801352:	89 55 14             	mov    %edx,0x14(%ebp)
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	57                   	push   %edi
  801359:	ff 30                	pushl  (%eax)
  80135b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80135e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801364:	e9 08 ff ff ff       	jmp    801271 <vprintfmt+0x24>
  801369:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136c:	8b 45 14             	mov    0x14(%ebp),%eax
  80136f:	8d 50 04             	lea    0x4(%eax),%edx
  801372:	89 55 14             	mov    %edx,0x14(%ebp)
  801375:	8b 00                	mov    (%eax),%eax
  801377:	85 c0                	test   %eax,%eax
  801379:	79 02                	jns    80137d <vprintfmt+0x130>
  80137b:	f7 d8                	neg    %eax
  80137d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137f:	83 f8 0f             	cmp    $0xf,%eax
  801382:	7f 0b                	jg     80138f <vprintfmt+0x142>
  801384:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  80138b:	85 c0                	test   %eax,%eax
  80138d:	75 1a                	jne    8013a9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80138f:	52                   	push   %edx
  801390:	68 1f 1f 80 00       	push   $0x801f1f
  801395:	57                   	push   %edi
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 92 fe ff ff       	call   801230 <printfmt>
  80139e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a4:	e9 c8 fe ff ff       	jmp    801271 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8013a9:	50                   	push   %eax
  8013aa:	68 9d 1e 80 00       	push   $0x801e9d
  8013af:	57                   	push   %edi
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 78 fe ff ff       	call   801230 <printfmt>
  8013b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013be:	e9 ae fe ff ff       	jmp    801271 <vprintfmt+0x24>
  8013c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013c6:	89 de                	mov    %ebx,%esi
  8013c8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d1:	8d 50 04             	lea    0x4(%eax),%edx
  8013d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d7:	8b 00                	mov    (%eax),%eax
  8013d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	75 07                	jne    8013e7 <vprintfmt+0x19a>
				p = "(null)";
  8013e0:	c7 45 d0 18 1f 80 00 	movl   $0x801f18,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8013e7:	85 db                	test   %ebx,%ebx
  8013e9:	7e 42                	jle    80142d <vprintfmt+0x1e0>
  8013eb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8013ef:	74 3c                	je     80142d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	51                   	push   %ecx
  8013f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f8:	e8 6f 02 00 00       	call   80166c <strnlen>
  8013fd:	29 c3                	sub    %eax,%ebx
  8013ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 db                	test   %ebx,%ebx
  801407:	7e 24                	jle    80142d <vprintfmt+0x1e0>
					putch(padc, putdat);
  801409:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80140d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801410:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	57                   	push   %edi
  801417:	53                   	push   %ebx
  801418:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141b:	4e                   	dec    %esi
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 f6                	test   %esi,%esi
  801421:	7f f0                	jg     801413 <vprintfmt+0x1c6>
  801423:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801426:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80142d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801430:	0f be 02             	movsbl (%edx),%eax
  801433:	85 c0                	test   %eax,%eax
  801435:	75 47                	jne    80147e <vprintfmt+0x231>
  801437:	eb 37                	jmp    801470 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801439:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80143d:	74 16                	je     801455 <vprintfmt+0x208>
  80143f:	8d 50 e0             	lea    -0x20(%eax),%edx
  801442:	83 fa 5e             	cmp    $0x5e,%edx
  801445:	76 0e                	jbe    801455 <vprintfmt+0x208>
					putch('?', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	57                   	push   %edi
  80144b:	6a 3f                	push   $0x3f
  80144d:	ff 55 08             	call   *0x8(%ebp)
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 0b                	jmp    801460 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	57                   	push   %edi
  801459:	50                   	push   %eax
  80145a:	ff 55 08             	call   *0x8(%ebp)
  80145d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801460:	ff 4d e4             	decl   -0x1c(%ebp)
  801463:	0f be 03             	movsbl (%ebx),%eax
  801466:	85 c0                	test   %eax,%eax
  801468:	74 03                	je     80146d <vprintfmt+0x220>
  80146a:	43                   	inc    %ebx
  80146b:	eb 1b                	jmp    801488 <vprintfmt+0x23b>
  80146d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801474:	7f 1e                	jg     801494 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801476:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801479:	e9 f3 fd ff ff       	jmp    801271 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801481:	43                   	inc    %ebx
  801482:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801485:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801488:	85 f6                	test   %esi,%esi
  80148a:	78 ad                	js     801439 <vprintfmt+0x1ec>
  80148c:	4e                   	dec    %esi
  80148d:	79 aa                	jns    801439 <vprintfmt+0x1ec>
  80148f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801492:	eb dc                	jmp    801470 <vprintfmt+0x223>
  801494:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	57                   	push   %edi
  80149b:	6a 20                	push   $0x20
  80149d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a0:	4b                   	dec    %ebx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 db                	test   %ebx,%ebx
  8014a6:	7f ef                	jg     801497 <vprintfmt+0x24a>
  8014a8:	e9 c4 fd ff ff       	jmp    801271 <vprintfmt+0x24>
  8014ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b0:	89 ca                	mov    %ecx,%edx
  8014b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014b5:	e8 2a fd ff ff       	call   8011e4 <getint>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8014be:	85 d2                	test   %edx,%edx
  8014c0:	78 0a                	js     8014cc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c7:	e9 b0 00 00 00       	jmp    80157c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	57                   	push   %edi
  8014d0:	6a 2d                	push   $0x2d
  8014d2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014d5:	f7 db                	neg    %ebx
  8014d7:	83 d6 00             	adc    $0x0,%esi
  8014da:	f7 de                	neg    %esi
  8014dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e4:	e9 93 00 00 00       	jmp    80157c <vprintfmt+0x32f>
  8014e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014ec:	89 ca                	mov    %ecx,%edx
  8014ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f1:	e8 b4 fc ff ff       	call   8011aa <getuint>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	89 d6                	mov    %edx,%esi
			base = 10;
  8014fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8014ff:	eb 7b                	jmp    80157c <vprintfmt+0x32f>
  801501:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801504:	89 ca                	mov    %ecx,%edx
  801506:	8d 45 14             	lea    0x14(%ebp),%eax
  801509:	e8 d6 fc ff ff       	call   8011e4 <getint>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801512:	85 d2                	test   %edx,%edx
  801514:	78 07                	js     80151d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801516:	b8 08 00 00 00       	mov    $0x8,%eax
  80151b:	eb 5f                	jmp    80157c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	57                   	push   %edi
  801521:	6a 2d                	push   $0x2d
  801523:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801526:	f7 db                	neg    %ebx
  801528:	83 d6 00             	adc    $0x0,%esi
  80152b:	f7 de                	neg    %esi
  80152d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801530:	b8 08 00 00 00       	mov    $0x8,%eax
  801535:	eb 45                	jmp    80157c <vprintfmt+0x32f>
  801537:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	57                   	push   %edi
  80153e:	6a 30                	push   $0x30
  801540:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801543:	83 c4 08             	add    $0x8,%esp
  801546:	57                   	push   %edi
  801547:	6a 78                	push   $0x78
  801549:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8d 50 04             	lea    0x4(%eax),%edx
  801552:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801555:	8b 18                	mov    (%eax),%ebx
  801557:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80155c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80155f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801564:	eb 16                	jmp    80157c <vprintfmt+0x32f>
  801566:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801569:	89 ca                	mov    %ecx,%edx
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 37 fc ff ff       	call   8011aa <getuint>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	89 d6                	mov    %edx,%esi
			base = 16;
  801577:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  801583:	52                   	push   %edx
  801584:	ff 75 e4             	pushl  -0x1c(%ebp)
  801587:	50                   	push   %eax
  801588:	56                   	push   %esi
  801589:	53                   	push   %ebx
  80158a:	89 fa                	mov    %edi,%edx
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	e8 68 fb ff ff       	call   8010fc <printnum>
			break;
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80159a:	e9 d2 fc ff ff       	jmp    801271 <vprintfmt+0x24>
  80159f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	57                   	push   %edi
  8015a6:	52                   	push   %edx
  8015a7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8015aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015b0:	e9 bc fc ff ff       	jmp    801271 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	57                   	push   %edi
  8015b9:	6a 25                	push   $0x25
  8015bb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	eb 02                	jmp    8015c5 <vprintfmt+0x378>
  8015c3:	89 c6                	mov    %eax,%esi
  8015c5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015c8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015cc:	75 f5                	jne    8015c3 <vprintfmt+0x376>
  8015ce:	e9 9e fc ff ff       	jmp    801271 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8015d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 18             	sub    $0x18,%esp
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	74 26                	je     801622 <vsnprintf+0x47>
  8015fc:	85 d2                	test   %edx,%edx
  8015fe:	7e 29                	jle    801629 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801600:	ff 75 14             	pushl  0x14(%ebp)
  801603:	ff 75 10             	pushl  0x10(%ebp)
  801606:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	68 16 12 80 00       	push   $0x801216
  80160f:	e8 39 fc ff ff       	call   80124d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801614:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801617:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80161a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 0c                	jmp    80162e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801627:	eb 05                	jmp    80162e <vsnprintf+0x53>
  801629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801636:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801639:	50                   	push   %eax
  80163a:	ff 75 10             	pushl  0x10(%ebp)
  80163d:	ff 75 0c             	pushl  0xc(%ebp)
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 93 ff ff ff       	call   8015db <vsnprintf>
	va_end(ap);

	return rc;
}
  801648:	c9                   	leave  
  801649:	c3                   	ret    
	...

0080164c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801652:	80 3a 00             	cmpb   $0x0,(%edx)
  801655:	74 0e                	je     801665 <strlen+0x19>
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80165c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80165d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801661:	75 f9                	jne    80165c <strlen+0x10>
  801663:	eb 05                	jmp    80166a <strlen+0x1e>
  801665:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801672:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801675:	85 d2                	test   %edx,%edx
  801677:	74 17                	je     801690 <strnlen+0x24>
  801679:	80 39 00             	cmpb   $0x0,(%ecx)
  80167c:	74 19                	je     801697 <strnlen+0x2b>
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801683:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801684:	39 d0                	cmp    %edx,%eax
  801686:	74 14                	je     80169c <strnlen+0x30>
  801688:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80168c:	75 f5                	jne    801683 <strnlen+0x17>
  80168e:	eb 0c                	jmp    80169c <strnlen+0x30>
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
  801695:	eb 05                	jmp    80169c <strnlen+0x30>
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ad:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8016b0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8016b3:	42                   	inc    %edx
  8016b4:	84 c9                	test   %cl,%cl
  8016b6:	75 f5                	jne    8016ad <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016b8:	5b                   	pop    %ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c2:	53                   	push   %ebx
  8016c3:	e8 84 ff ff ff       	call   80164c <strlen>
  8016c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8016d1:	50                   	push   %eax
  8016d2:	e8 c7 ff ff ff       	call   80169e <strcpy>
	return dst;
}
  8016d7:	89 d8                	mov    %ebx,%eax
  8016d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ec:	85 f6                	test   %esi,%esi
  8016ee:	74 15                	je     801705 <strncpy+0x27>
  8016f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8016f5:	8a 1a                	mov    (%edx),%bl
  8016f7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8016fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801700:	41                   	inc    %ecx
  801701:	39 ce                	cmp    %ecx,%esi
  801703:	77 f0                	ja     8016f5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	57                   	push   %edi
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801715:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801718:	85 f6                	test   %esi,%esi
  80171a:	74 32                	je     80174e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80171c:	83 fe 01             	cmp    $0x1,%esi
  80171f:	74 22                	je     801743 <strlcpy+0x3a>
  801721:	8a 0b                	mov    (%ebx),%cl
  801723:	84 c9                	test   %cl,%cl
  801725:	74 20                	je     801747 <strlcpy+0x3e>
  801727:	89 f8                	mov    %edi,%eax
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80172e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801731:	88 08                	mov    %cl,(%eax)
  801733:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801734:	39 f2                	cmp    %esi,%edx
  801736:	74 11                	je     801749 <strlcpy+0x40>
  801738:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80173c:	42                   	inc    %edx
  80173d:	84 c9                	test   %cl,%cl
  80173f:	75 f0                	jne    801731 <strlcpy+0x28>
  801741:	eb 06                	jmp    801749 <strlcpy+0x40>
  801743:	89 f8                	mov    %edi,%eax
  801745:	eb 02                	jmp    801749 <strlcpy+0x40>
  801747:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801749:	c6 00 00             	movb   $0x0,(%eax)
  80174c:	eb 02                	jmp    801750 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  801750:	29 f8                	sub    %edi,%eax
}
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5f                   	pop    %edi
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801760:	8a 01                	mov    (%ecx),%al
  801762:	84 c0                	test   %al,%al
  801764:	74 10                	je     801776 <strcmp+0x1f>
  801766:	3a 02                	cmp    (%edx),%al
  801768:	75 0c                	jne    801776 <strcmp+0x1f>
		p++, q++;
  80176a:	41                   	inc    %ecx
  80176b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176c:	8a 01                	mov    (%ecx),%al
  80176e:	84 c0                	test   %al,%al
  801770:	74 04                	je     801776 <strcmp+0x1f>
  801772:	3a 02                	cmp    (%edx),%al
  801774:	74 f4                	je     80176a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801776:	0f b6 c0             	movzbl %al,%eax
  801779:	0f b6 12             	movzbl (%edx),%edx
  80177c:	29 d0                	sub    %edx,%eax
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	8b 55 08             	mov    0x8(%ebp),%edx
  801787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	74 1b                	je     8017ac <strncmp+0x2c>
  801791:	8a 1a                	mov    (%edx),%bl
  801793:	84 db                	test   %bl,%bl
  801795:	74 24                	je     8017bb <strncmp+0x3b>
  801797:	3a 19                	cmp    (%ecx),%bl
  801799:	75 20                	jne    8017bb <strncmp+0x3b>
  80179b:	48                   	dec    %eax
  80179c:	74 15                	je     8017b3 <strncmp+0x33>
		n--, p++, q++;
  80179e:	42                   	inc    %edx
  80179f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a0:	8a 1a                	mov    (%edx),%bl
  8017a2:	84 db                	test   %bl,%bl
  8017a4:	74 15                	je     8017bb <strncmp+0x3b>
  8017a6:	3a 19                	cmp    (%ecx),%bl
  8017a8:	74 f1                	je     80179b <strncmp+0x1b>
  8017aa:	eb 0f                	jmp    8017bb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b1:	eb 05                	jmp    8017b8 <strncmp+0x38>
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b8:	5b                   	pop    %ebx
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017bb:	0f b6 02             	movzbl (%edx),%eax
  8017be:	0f b6 11             	movzbl (%ecx),%edx
  8017c1:	29 d0                	sub    %edx,%eax
  8017c3:	eb f3                	jmp    8017b8 <strncmp+0x38>

008017c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017ce:	8a 10                	mov    (%eax),%dl
  8017d0:	84 d2                	test   %dl,%dl
  8017d2:	74 18                	je     8017ec <strchr+0x27>
		if (*s == c)
  8017d4:	38 ca                	cmp    %cl,%dl
  8017d6:	75 06                	jne    8017de <strchr+0x19>
  8017d8:	eb 17                	jmp    8017f1 <strchr+0x2c>
  8017da:	38 ca                	cmp    %cl,%dl
  8017dc:	74 13                	je     8017f1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017de:	40                   	inc    %eax
  8017df:	8a 10                	mov    (%eax),%dl
  8017e1:	84 d2                	test   %dl,%dl
  8017e3:	75 f5                	jne    8017da <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ea:	eb 05                	jmp    8017f1 <strchr+0x2c>
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8017fc:	8a 10                	mov    (%eax),%dl
  8017fe:	84 d2                	test   %dl,%dl
  801800:	74 11                	je     801813 <strfind+0x20>
		if (*s == c)
  801802:	38 ca                	cmp    %cl,%dl
  801804:	75 06                	jne    80180c <strfind+0x19>
  801806:	eb 0b                	jmp    801813 <strfind+0x20>
  801808:	38 ca                	cmp    %cl,%dl
  80180a:	74 07                	je     801813 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80180c:	40                   	inc    %eax
  80180d:	8a 10                	mov    (%eax),%dl
  80180f:	84 d2                	test   %dl,%dl
  801811:	75 f5                	jne    801808 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	57                   	push   %edi
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801821:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801824:	85 c9                	test   %ecx,%ecx
  801826:	74 30                	je     801858 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801828:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80182e:	75 25                	jne    801855 <memset+0x40>
  801830:	f6 c1 03             	test   $0x3,%cl
  801833:	75 20                	jne    801855 <memset+0x40>
		c &= 0xFF;
  801835:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801838:	89 d3                	mov    %edx,%ebx
  80183a:	c1 e3 08             	shl    $0x8,%ebx
  80183d:	89 d6                	mov    %edx,%esi
  80183f:	c1 e6 18             	shl    $0x18,%esi
  801842:	89 d0                	mov    %edx,%eax
  801844:	c1 e0 10             	shl    $0x10,%eax
  801847:	09 f0                	or     %esi,%eax
  801849:	09 d0                	or     %edx,%eax
  80184b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80184d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801850:	fc                   	cld    
  801851:	f3 ab                	rep stos %eax,%es:(%edi)
  801853:	eb 03                	jmp    801858 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801855:	fc                   	cld    
  801856:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801858:	89 f8                	mov    %edi,%eax
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 75 0c             	mov    0xc(%ebp),%esi
  80186a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80186d:	39 c6                	cmp    %eax,%esi
  80186f:	73 34                	jae    8018a5 <memmove+0x46>
  801871:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801874:	39 d0                	cmp    %edx,%eax
  801876:	73 2d                	jae    8018a5 <memmove+0x46>
		s += n;
		d += n;
  801878:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187b:	f6 c2 03             	test   $0x3,%dl
  80187e:	75 1b                	jne    80189b <memmove+0x3c>
  801880:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801886:	75 13                	jne    80189b <memmove+0x3c>
  801888:	f6 c1 03             	test   $0x3,%cl
  80188b:	75 0e                	jne    80189b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80188d:	83 ef 04             	sub    $0x4,%edi
  801890:	8d 72 fc             	lea    -0x4(%edx),%esi
  801893:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801896:	fd                   	std    
  801897:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801899:	eb 07                	jmp    8018a2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80189b:	4f                   	dec    %edi
  80189c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80189f:	fd                   	std    
  8018a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a2:	fc                   	cld    
  8018a3:	eb 20                	jmp    8018c5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ab:	75 13                	jne    8018c0 <memmove+0x61>
  8018ad:	a8 03                	test   $0x3,%al
  8018af:	75 0f                	jne    8018c0 <memmove+0x61>
  8018b1:	f6 c1 03             	test   $0x3,%cl
  8018b4:	75 0a                	jne    8018c0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018b6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018b9:	89 c7                	mov    %eax,%edi
  8018bb:	fc                   	cld    
  8018bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018be:	eb 05                	jmp    8018c5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c0:	89 c7                	mov    %eax,%edi
  8018c2:	fc                   	cld    
  8018c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c5:	5e                   	pop    %esi
  8018c6:	5f                   	pop    %edi
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018cc:	ff 75 10             	pushl  0x10(%ebp)
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	ff 75 08             	pushl  0x8(%ebp)
  8018d5:	e8 85 ff ff ff       	call   80185f <memmove>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018eb:	85 ff                	test   %edi,%edi
  8018ed:	74 32                	je     801921 <memcmp+0x45>
		if (*s1 != *s2)
  8018ef:	8a 03                	mov    (%ebx),%al
  8018f1:	8a 0e                	mov    (%esi),%cl
  8018f3:	38 c8                	cmp    %cl,%al
  8018f5:	74 19                	je     801910 <memcmp+0x34>
  8018f7:	eb 0d                	jmp    801906 <memcmp+0x2a>
  8018f9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8018fd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  801901:	42                   	inc    %edx
  801902:	38 c8                	cmp    %cl,%al
  801904:	74 10                	je     801916 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  801906:	0f b6 c0             	movzbl %al,%eax
  801909:	0f b6 c9             	movzbl %cl,%ecx
  80190c:	29 c8                	sub    %ecx,%eax
  80190e:	eb 16                	jmp    801926 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801910:	4f                   	dec    %edi
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	39 fa                	cmp    %edi,%edx
  801918:	75 df                	jne    8018f9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	eb 05                	jmp    801926 <memcmp+0x4a>
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5f                   	pop    %edi
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801931:	89 c2                	mov    %eax,%edx
  801933:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801936:	39 d0                	cmp    %edx,%eax
  801938:	73 12                	jae    80194c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80193d:	38 08                	cmp    %cl,(%eax)
  80193f:	75 06                	jne    801947 <memfind+0x1c>
  801941:	eb 09                	jmp    80194c <memfind+0x21>
  801943:	38 08                	cmp    %cl,(%eax)
  801945:	74 05                	je     80194c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801947:	40                   	inc    %eax
  801948:	39 c2                	cmp    %eax,%edx
  80194a:	77 f7                	ja     801943 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	8b 55 08             	mov    0x8(%ebp),%edx
  801957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195a:	eb 01                	jmp    80195d <strtol+0xf>
		s++;
  80195c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195d:	8a 02                	mov    (%edx),%al
  80195f:	3c 20                	cmp    $0x20,%al
  801961:	74 f9                	je     80195c <strtol+0xe>
  801963:	3c 09                	cmp    $0x9,%al
  801965:	74 f5                	je     80195c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801967:	3c 2b                	cmp    $0x2b,%al
  801969:	75 08                	jne    801973 <strtol+0x25>
		s++;
  80196b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196c:	bf 00 00 00 00       	mov    $0x0,%edi
  801971:	eb 13                	jmp    801986 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801973:	3c 2d                	cmp    $0x2d,%al
  801975:	75 0a                	jne    801981 <strtol+0x33>
		s++, neg = 1;
  801977:	8d 52 01             	lea    0x1(%edx),%edx
  80197a:	bf 01 00 00 00       	mov    $0x1,%edi
  80197f:	eb 05                	jmp    801986 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801981:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801986:	85 db                	test   %ebx,%ebx
  801988:	74 05                	je     80198f <strtol+0x41>
  80198a:	83 fb 10             	cmp    $0x10,%ebx
  80198d:	75 28                	jne    8019b7 <strtol+0x69>
  80198f:	8a 02                	mov    (%edx),%al
  801991:	3c 30                	cmp    $0x30,%al
  801993:	75 10                	jne    8019a5 <strtol+0x57>
  801995:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801999:	75 0a                	jne    8019a5 <strtol+0x57>
		s += 2, base = 16;
  80199b:	83 c2 02             	add    $0x2,%edx
  80199e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a3:	eb 12                	jmp    8019b7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8019a5:	85 db                	test   %ebx,%ebx
  8019a7:	75 0e                	jne    8019b7 <strtol+0x69>
  8019a9:	3c 30                	cmp    $0x30,%al
  8019ab:	75 05                	jne    8019b2 <strtol+0x64>
		s++, base = 8;
  8019ad:	42                   	inc    %edx
  8019ae:	b3 08                	mov    $0x8,%bl
  8019b0:	eb 05                	jmp    8019b7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8019b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019be:	8a 0a                	mov    (%edx),%cl
  8019c0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019c3:	80 fb 09             	cmp    $0x9,%bl
  8019c6:	77 08                	ja     8019d0 <strtol+0x82>
			dig = *s - '0';
  8019c8:	0f be c9             	movsbl %cl,%ecx
  8019cb:	83 e9 30             	sub    $0x30,%ecx
  8019ce:	eb 1e                	jmp    8019ee <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8019d0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8019d3:	80 fb 19             	cmp    $0x19,%bl
  8019d6:	77 08                	ja     8019e0 <strtol+0x92>
			dig = *s - 'a' + 10;
  8019d8:	0f be c9             	movsbl %cl,%ecx
  8019db:	83 e9 57             	sub    $0x57,%ecx
  8019de:	eb 0e                	jmp    8019ee <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8019e0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 13                	ja     8019fb <strtol+0xad>
			dig = *s - 'A' + 10;
  8019e8:	0f be c9             	movsbl %cl,%ecx
  8019eb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019ee:	39 f1                	cmp    %esi,%ecx
  8019f0:	7d 0d                	jge    8019ff <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8019f2:	42                   	inc    %edx
  8019f3:	0f af c6             	imul   %esi,%eax
  8019f6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019f9:	eb c3                	jmp    8019be <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8019fb:	89 c1                	mov    %eax,%ecx
  8019fd:	eb 02                	jmp    801a01 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ff:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a05:	74 05                	je     801a0c <strtol+0xbe>
		*endptr = (char *) s;
  801a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a0a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801a0c:	85 ff                	test   %edi,%edi
  801a0e:	74 04                	je     801a14 <strtol+0xc6>
  801a10:	89 c8                	mov    %ecx,%eax
  801a12:	f7 d8                	neg    %eax
}
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5f                   	pop    %edi
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    
  801a19:	00 00                	add    %al,(%eax)
	...

00801a1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 75 08             	mov    0x8(%ebp),%esi
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	74 0e                	je     801a3c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	50                   	push   %eax
  801a32:	e8 74 e8 ff ff       	call   8002ab <sys_ipc_recv>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	eb 10                	jmp    801a4c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	68 00 00 c0 ee       	push   $0xeec00000
  801a44:	e8 62 e8 ff ff       	call   8002ab <sys_ipc_recv>
  801a49:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	75 26                	jne    801a76 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a50:	85 f6                	test   %esi,%esi
  801a52:	74 0a                	je     801a5e <ipc_recv+0x42>
  801a54:	a1 04 40 80 00       	mov    0x804004,%eax
  801a59:	8b 40 74             	mov    0x74(%eax),%eax
  801a5c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a5e:	85 db                	test   %ebx,%ebx
  801a60:	74 0a                	je     801a6c <ipc_recv+0x50>
  801a62:	a1 04 40 80 00       	mov    0x804004,%eax
  801a67:	8b 40 78             	mov    0x78(%eax),%eax
  801a6a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 70             	mov    0x70(%eax),%eax
  801a74:	eb 14                	jmp    801a8a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a76:	85 f6                	test   %esi,%esi
  801a78:	74 06                	je     801a80 <ipc_recv+0x64>
  801a7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a80:	85 db                	test   %ebx,%ebx
  801a82:	74 06                	je     801a8a <ipc_recv+0x6e>
  801a84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	57                   	push   %edi
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	75 25                	jne    801acc <ipc_send+0x3b>
  801aa7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aac:	eb 1e                	jmp    801acc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801aae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab1:	75 07                	jne    801aba <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ab3:	e8 d1 e6 ff ff       	call   800189 <sys_yield>
  801ab8:	eb 12                	jmp    801acc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801aba:	50                   	push   %eax
  801abb:	68 00 22 80 00       	push   $0x802200
  801ac0:	6a 43                	push   $0x43
  801ac2:	68 13 22 80 00       	push   $0x802213
  801ac7:	e8 44 f5 ff ff       	call   801010 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	57                   	push   %edi
  801acf:	ff 75 08             	pushl  0x8(%ebp)
  801ad2:	e8 af e7 ff ff       	call   800286 <sys_ipc_try_send>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	75 d0                	jne    801aae <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801aec:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801af2:	74 1a                	je     801b0e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	c1 e2 07             	shl    $0x7,%edx
  801afe:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b05:	8b 52 50             	mov    0x50(%edx),%edx
  801b08:	39 ca                	cmp    %ecx,%edx
  801b0a:	75 18                	jne    801b24 <ipc_find_env+0x3e>
  801b0c:	eb 05                	jmp    801b13 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	c1 e2 07             	shl    $0x7,%edx
  801b18:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b1f:	8b 40 40             	mov    0x40(%eax),%eax
  801b22:	eb 0c                	jmp    801b30 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b24:	40                   	inc    %eax
  801b25:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2a:	75 cd                	jne    801af9 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b2c:	66 b8 00 00          	mov    $0x0,%ax
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    
	...

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
