
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 be 00 00 00       	call   800101 <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800053:	e8 15 01 00 00       	call   80016d <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800064:	c1 e0 07             	shl    $0x7,%eax
  800067:	29 d0                	sub    %edx,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 07                	jle    80007e <libmain+0x36>
		binaryname = argv[0];
  800077:	8b 03                	mov    (%ebx),%eax
  800079:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	53                   	push   %ebx
  800082:	56                   	push   %esi
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009e:	e8 5f 04 00 00       	call   800502 <close_all>
	sys_env_destroy(0);
  8000a3:	83 ec 0c             	sub    $0xc,%esp
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
  8000e6:	68 8a 1d 80 00       	push   $0x801d8a
  8000eb:	6a 42                	push   $0x42
  8000ed:	68 a7 1d 80 00       	push   $0x801da7
  8000f2:	e8 b5 0e 00 00       	call   800fac <_panic>

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
  8001a9:	b8 0b 00 00 00       	mov    $0xb,%eax
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

00800248 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800271:	6a 00                	push   $0x0
  800273:	6a 00                	push   $0x0
  800275:	6a 00                	push   $0x0
  800277:	ff 75 0c             	pushl  0xc(%ebp)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	ba 01 00 00 00       	mov    $0x1,%edx
  800282:	b8 0a 00 00 00       	mov    $0xa,%eax
  800287:	e8 28 fe ff ff       	call   8000b4 <syscall>
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800294:	6a 00                	push   $0x0
  800296:	ff 75 14             	pushl  0x14(%ebp)
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ac:	e8 03 fe ff ff       	call   8000b4 <syscall>
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002b9:	6a 00                	push   $0x0
  8002bb:	6a 00                	push   $0x0
  8002bd:	6a 00                	push   $0x0
  8002bf:	6a 00                	push   $0x0
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8002c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ce:	e8 e1 fd ff ff       	call   8000b4 <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002f1:	e8 be fd ff ff       	call   8000b4 <syscall>
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800303:	c1 e8 0c             	shr    $0xc,%eax
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	e8 e5 ff ff ff       	call   8002f8 <fd2num>
  800313:	83 c4 04             	add    $0x4,%esp
  800316:	05 20 00 0d 00       	add    $0xd0020,%eax
  80031b:	c1 e0 0c             	shl    $0xc,%eax
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	53                   	push   %ebx
  800324:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800327:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80032c:	a8 01                	test   $0x1,%al
  80032e:	74 34                	je     800364 <fd_alloc+0x44>
  800330:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800335:	a8 01                	test   $0x1,%al
  800337:	74 32                	je     80036b <fd_alloc+0x4b>
  800339:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80033e:	89 c1                	mov    %eax,%ecx
  800340:	89 c2                	mov    %eax,%edx
  800342:	c1 ea 16             	shr    $0x16,%edx
  800345:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80034c:	f6 c2 01             	test   $0x1,%dl
  80034f:	74 1f                	je     800370 <fd_alloc+0x50>
  800351:	89 c2                	mov    %eax,%edx
  800353:	c1 ea 0c             	shr    $0xc,%edx
  800356:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80035d:	f6 c2 01             	test   $0x1,%dl
  800360:	75 17                	jne    800379 <fd_alloc+0x59>
  800362:	eb 0c                	jmp    800370 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800364:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800369:	eb 05                	jmp    800370 <fd_alloc+0x50>
  80036b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800370:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800372:	b8 00 00 00 00       	mov    $0x0,%eax
  800377:	eb 17                	jmp    800390 <fd_alloc+0x70>
  800379:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80037e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800383:	75 b9                	jne    80033e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800385:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80038b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800390:	5b                   	pop    %ebx
  800391:	c9                   	leave  
  800392:	c3                   	ret    

00800393 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800399:	83 f8 1f             	cmp    $0x1f,%eax
  80039c:	77 36                	ja     8003d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80039e:	05 00 00 0d 00       	add    $0xd0000,%eax
  8003a3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003a6:	89 c2                	mov    %eax,%edx
  8003a8:	c1 ea 16             	shr    $0x16,%edx
  8003ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b2:	f6 c2 01             	test   $0x1,%dl
  8003b5:	74 24                	je     8003db <fd_lookup+0x48>
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 0c             	shr    $0xc,%edx
  8003bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 1a                	je     8003e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8003cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d2:	eb 13                	jmp    8003e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d9:	eb 0c                	jmp    8003e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e0:	eb 05                	jmp    8003e7 <fd_lookup+0x54>
  8003e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 04             	sub    $0x4,%esp
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8003f6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8003fc:	74 0d                	je     80040b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800403:	eb 14                	jmp    800419 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800405:	39 0a                	cmp    %ecx,(%edx)
  800407:	75 10                	jne    800419 <dev_lookup+0x30>
  800409:	eb 05                	jmp    800410 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80040b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800410:	89 13                	mov    %edx,(%ebx)
			return 0;
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	eb 31                	jmp    80044a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800419:	40                   	inc    %eax
  80041a:	8b 14 85 34 1e 80 00 	mov    0x801e34(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	75 e0                	jne    800405 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800425:	a1 04 40 80 00       	mov    0x804004,%eax
  80042a:	8b 40 48             	mov    0x48(%eax),%eax
  80042d:	83 ec 04             	sub    $0x4,%esp
  800430:	51                   	push   %ecx
  800431:	50                   	push   %eax
  800432:	68 b8 1d 80 00       	push   $0x801db8
  800437:	e8 48 0c 00 00       	call   801084 <cprintf>
	*dev = 0;
  80043c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80044a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
  800454:	83 ec 20             	sub    $0x20,%esp
  800457:	8b 75 08             	mov    0x8(%ebp),%esi
  80045a:	8a 45 0c             	mov    0xc(%ebp),%al
  80045d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800460:	56                   	push   %esi
  800461:	e8 92 fe ff ff       	call   8002f8 <fd2num>
  800466:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800469:	89 14 24             	mov    %edx,(%esp)
  80046c:	50                   	push   %eax
  80046d:	e8 21 ff ff ff       	call   800393 <fd_lookup>
  800472:	89 c3                	mov    %eax,%ebx
  800474:	83 c4 08             	add    $0x8,%esp
  800477:	85 c0                	test   %eax,%eax
  800479:	78 05                	js     800480 <fd_close+0x31>
	    || fd != fd2)
  80047b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80047e:	74 0d                	je     80048d <fd_close+0x3e>
		return (must_exist ? r : 0);
  800480:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800484:	75 48                	jne    8004ce <fd_close+0x7f>
  800486:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048b:	eb 41                	jmp    8004ce <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800493:	50                   	push   %eax
  800494:	ff 36                	pushl  (%esi)
  800496:	e8 4e ff ff ff       	call   8003e9 <dev_lookup>
  80049b:	89 c3                	mov    %eax,%ebx
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	78 1c                	js     8004c0 <fd_close+0x71>
		if (dev->dev_close)
  8004a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004a7:	8b 40 10             	mov    0x10(%eax),%eax
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	74 0d                	je     8004bb <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8004ae:	83 ec 0c             	sub    $0xc,%esp
  8004b1:	56                   	push   %esi
  8004b2:	ff d0                	call   *%eax
  8004b4:	89 c3                	mov    %eax,%ebx
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	eb 05                	jmp    8004c0 <fd_close+0x71>
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	56                   	push   %esi
  8004c4:	6a 00                	push   $0x0
  8004c6:	e8 37 fd ff ff       	call   800202 <sys_page_unmap>
	return r;
  8004cb:	83 c4 10             	add    $0x10,%esp
}
  8004ce:	89 d8                	mov    %ebx,%eax
  8004d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5e                   	pop    %esi
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff 75 08             	pushl  0x8(%ebp)
  8004e4:	e8 aa fe ff ff       	call   800393 <fd_lookup>
  8004e9:	83 c4 08             	add    $0x8,%esp
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	78 10                	js     800500 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	6a 01                	push   $0x1
  8004f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f8:	e8 52 ff ff ff       	call   80044f <fd_close>
  8004fd:	83 c4 10             	add    $0x10,%esp
}
  800500:	c9                   	leave  
  800501:	c3                   	ret    

00800502 <close_all>:

void
close_all(void)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	53                   	push   %ebx
  800506:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800509:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	53                   	push   %ebx
  800512:	e8 c0 ff ff ff       	call   8004d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800517:	43                   	inc    %ebx
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	83 fb 20             	cmp    $0x20,%ebx
  80051e:	75 ee                	jne    80050e <close_all+0xc>
		close(i);
}
  800520:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 2c             	sub    $0x2c,%esp
  80052e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800531:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800534:	50                   	push   %eax
  800535:	ff 75 08             	pushl  0x8(%ebp)
  800538:	e8 56 fe ff ff       	call   800393 <fd_lookup>
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	83 c4 08             	add    $0x8,%esp
  800542:	85 c0                	test   %eax,%eax
  800544:	0f 88 c0 00 00 00    	js     80060a <dup+0xe5>
		return r;
	close(newfdnum);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	57                   	push   %edi
  80054e:	e8 84 ff ff ff       	call   8004d7 <close>

	newfd = INDEX2FD(newfdnum);
  800553:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800559:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80055c:	83 c4 04             	add    $0x4,%esp
  80055f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800562:	e8 a1 fd ff ff       	call   800308 <fd2data>
  800567:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800569:	89 34 24             	mov    %esi,(%esp)
  80056c:	e8 97 fd ff ff       	call   800308 <fd2data>
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800577:	89 d8                	mov    %ebx,%eax
  800579:	c1 e8 16             	shr    $0x16,%eax
  80057c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800583:	a8 01                	test   $0x1,%al
  800585:	74 37                	je     8005be <dup+0x99>
  800587:	89 d8                	mov    %ebx,%eax
  800589:	c1 e8 0c             	shr    $0xc,%eax
  80058c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800593:	f6 c2 01             	test   $0x1,%dl
  800596:	74 26                	je     8005be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800598:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a7:	50                   	push   %eax
  8005a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ab:	6a 00                	push   $0x0
  8005ad:	53                   	push   %ebx
  8005ae:	6a 00                	push   $0x0
  8005b0:	e8 27 fc ff ff       	call   8001dc <sys_page_map>
  8005b5:	89 c3                	mov    %eax,%ebx
  8005b7:	83 c4 20             	add    $0x20,%esp
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	78 2d                	js     8005eb <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c1:	89 c2                	mov    %eax,%edx
  8005c3:	c1 ea 0c             	shr    $0xc,%edx
  8005c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8005d6:	52                   	push   %edx
  8005d7:	56                   	push   %esi
  8005d8:	6a 00                	push   $0x0
  8005da:	50                   	push   %eax
  8005db:	6a 00                	push   $0x0
  8005dd:	e8 fa fb ff ff       	call   8001dc <sys_page_map>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	83 c4 20             	add    $0x20,%esp
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 1d                	jns    800608 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 0c fc ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f6:	83 c4 08             	add    $0x8,%esp
  8005f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 ff fb ff ff       	call   800202 <sys_page_unmap>
	return r;
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	eb 02                	jmp    80060a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800608:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80060a:	89 d8                	mov    %ebx,%eax
  80060c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80060f:	5b                   	pop    %ebx
  800610:	5e                   	pop    %esi
  800611:	5f                   	pop    %edi
  800612:	c9                   	leave  
  800613:	c3                   	ret    

00800614 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	53                   	push   %ebx
  800618:	83 ec 14             	sub    $0x14,%esp
  80061b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80061e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800621:	50                   	push   %eax
  800622:	53                   	push   %ebx
  800623:	e8 6b fd ff ff       	call   800393 <fd_lookup>
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	85 c0                	test   %eax,%eax
  80062d:	78 67                	js     800696 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800635:	50                   	push   %eax
  800636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800639:	ff 30                	pushl  (%eax)
  80063b:	e8 a9 fd ff ff       	call   8003e9 <dev_lookup>
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	85 c0                	test   %eax,%eax
  800645:	78 4f                	js     800696 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	8b 50 08             	mov    0x8(%eax),%edx
  80064d:	83 e2 03             	and    $0x3,%edx
  800650:	83 fa 01             	cmp    $0x1,%edx
  800653:	75 21                	jne    800676 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800655:	a1 04 40 80 00       	mov    0x804004,%eax
  80065a:	8b 40 48             	mov    0x48(%eax),%eax
  80065d:	83 ec 04             	sub    $0x4,%esp
  800660:	53                   	push   %ebx
  800661:	50                   	push   %eax
  800662:	68 f9 1d 80 00       	push   $0x801df9
  800667:	e8 18 0a 00 00       	call   801084 <cprintf>
		return -E_INVAL;
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800674:	eb 20                	jmp    800696 <read+0x82>
	}
	if (!dev->dev_read)
  800676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800679:	8b 52 08             	mov    0x8(%edx),%edx
  80067c:	85 d2                	test   %edx,%edx
  80067e:	74 11                	je     800691 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800680:	83 ec 04             	sub    $0x4,%esp
  800683:	ff 75 10             	pushl  0x10(%ebp)
  800686:	ff 75 0c             	pushl  0xc(%ebp)
  800689:	50                   	push   %eax
  80068a:	ff d2                	call   *%edx
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	eb 05                	jmp    800696 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800696:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800699:	c9                   	leave  
  80069a:	c3                   	ret    

0080069b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	57                   	push   %edi
  80069f:	56                   	push   %esi
  8006a0:	53                   	push   %ebx
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006aa:	85 f6                	test   %esi,%esi
  8006ac:	74 31                	je     8006df <readn+0x44>
  8006ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	89 f2                	mov    %esi,%edx
  8006bd:	29 c2                	sub    %eax,%edx
  8006bf:	52                   	push   %edx
  8006c0:	03 45 0c             	add    0xc(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	57                   	push   %edi
  8006c5:	e8 4a ff ff ff       	call   800614 <read>
		if (m < 0)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	78 17                	js     8006e8 <readn+0x4d>
			return m;
		if (m == 0)
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 11                	je     8006e6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d5:	01 c3                	add    %eax,%ebx
  8006d7:	89 d8                	mov    %ebx,%eax
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	72 db                	jb     8006b8 <readn+0x1d>
  8006dd:	eb 09                	jmp    8006e8 <readn+0x4d>
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 02                	jmp    8006e8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8006e6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	c9                   	leave  
  8006ef:	c3                   	ret    

008006f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 14             	sub    $0x14,%esp
  8006f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	53                   	push   %ebx
  8006ff:	e8 8f fc ff ff       	call   800393 <fd_lookup>
  800704:	83 c4 08             	add    $0x8,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	78 62                	js     80076d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800715:	ff 30                	pushl  (%eax)
  800717:	e8 cd fc ff ff       	call   8003e9 <dev_lookup>
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 4a                	js     80076d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800723:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800726:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072a:	75 21                	jne    80074d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80072c:	a1 04 40 80 00       	mov    0x804004,%eax
  800731:	8b 40 48             	mov    0x48(%eax),%eax
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	53                   	push   %ebx
  800738:	50                   	push   %eax
  800739:	68 15 1e 80 00       	push   $0x801e15
  80073e:	e8 41 09 00 00       	call   801084 <cprintf>
		return -E_INVAL;
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 20                	jmp    80076d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80074d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800750:	8b 52 0c             	mov    0xc(%edx),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 11                	je     800768 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	50                   	push   %eax
  800761:	ff d2                	call   *%edx
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	eb 05                	jmp    80076d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800768:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80076d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <seek>:

int
seek(int fdnum, off_t offset)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800778:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	ff 75 08             	pushl  0x8(%ebp)
  80077f:	e8 0f fc ff ff       	call   800393 <fd_lookup>
  800784:	83 c4 08             	add    $0x8,%esp
  800787:	85 c0                	test   %eax,%eax
  800789:	78 0e                	js     800799 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80078b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	83 ec 14             	sub    $0x14,%esp
  8007a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a8:	50                   	push   %eax
  8007a9:	53                   	push   %ebx
  8007aa:	e8 e4 fb ff ff       	call   800393 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 5f                	js     800815 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c0:	ff 30                	pushl  (%eax)
  8007c2:	e8 22 fc ff ff       	call   8003e9 <dev_lookup>
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 47                	js     800815 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d5:	75 21                	jne    8007f8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007d7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007dc:	8b 40 48             	mov    0x48(%eax),%eax
  8007df:	83 ec 04             	sub    $0x4,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	50                   	push   %eax
  8007e4:	68 d8 1d 80 00       	push   $0x801dd8
  8007e9:	e8 96 08 00 00       	call   801084 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f6:	eb 1d                	jmp    800815 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8007f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fb:	8b 52 18             	mov    0x18(%edx),%edx
  8007fe:	85 d2                	test   %edx,%edx
  800800:	74 0e                	je     800810 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	50                   	push   %eax
  800809:	ff d2                	call   *%edx
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	eb 05                	jmp    800815 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800810:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	83 ec 14             	sub    $0x14,%esp
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	ff 75 08             	pushl  0x8(%ebp)
  80082b:	e8 63 fb ff ff       	call   800393 <fd_lookup>
  800830:	83 c4 08             	add    $0x8,%esp
  800833:	85 c0                	test   %eax,%eax
  800835:	78 52                	js     800889 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800841:	ff 30                	pushl  (%eax)
  800843:	e8 a1 fb ff ff       	call   8003e9 <dev_lookup>
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	85 c0                	test   %eax,%eax
  80084d:	78 3a                	js     800889 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80084f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800852:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800856:	74 2c                	je     800884 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800858:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800862:	00 00 00 
	stat->st_isdir = 0;
  800865:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086c:	00 00 00 
	stat->st_dev = dev;
  80086f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	ff 75 f0             	pushl  -0x10(%ebp)
  80087c:	ff 50 14             	call   *0x14(%eax)
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	eb 05                	jmp    800889 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	6a 00                	push   $0x0
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 78 01 00 00       	call   800a18 <open>
  8008a0:	89 c3                	mov    %eax,%ebx
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	78 1b                	js     8008c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	50                   	push   %eax
  8008b0:	e8 65 ff ff ff       	call   80081a <fstat>
  8008b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b7:	89 1c 24             	mov    %ebx,(%esp)
  8008ba:	e8 18 fc ff ff       	call   8004d7 <close>
	return r;
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	89 f3                	mov    %esi,%ebx
}
  8008c4:	89 d8                	mov    %ebx,%eax
  8008c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    
  8008cd:	00 00                	add    %al,(%eax)
	...

008008d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	89 c3                	mov    %eax,%ebx
  8008d7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8008d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e0:	75 12                	jne    8008f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008e2:	83 ec 0c             	sub    $0xc,%esp
  8008e5:	6a 01                	push   $0x1
  8008e7:	e8 96 11 00 00       	call   801a82 <ipc_find_env>
  8008ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8008f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f4:	6a 07                	push   $0x7
  8008f6:	68 00 50 80 00       	push   $0x805000
  8008fb:	53                   	push   %ebx
  8008fc:	ff 35 00 40 80 00    	pushl  0x804000
  800902:	e8 26 11 00 00       	call   801a2d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800907:	83 c4 0c             	add    $0xc,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	56                   	push   %esi
  80090d:	6a 00                	push   $0x0
  80090f:	e8 a4 10 00 00       	call   8019b8 <ipc_recv>
}
  800914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	83 ec 04             	sub    $0x4,%esp
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 40 0c             	mov    0xc(%eax),%eax
  80092b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800930:	ba 00 00 00 00       	mov    $0x0,%edx
  800935:	b8 05 00 00 00       	mov    $0x5,%eax
  80093a:	e8 91 ff ff ff       	call   8008d0 <fsipc>
  80093f:	85 c0                	test   %eax,%eax
  800941:	78 2c                	js     80096f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	68 00 50 80 00       	push   $0x805000
  80094b:	53                   	push   %ebx
  80094c:	e8 e9 0c 00 00       	call   80163a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800951:	a1 80 50 80 00       	mov    0x805080,%eax
  800956:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80095c:	a1 84 50 80 00       	mov    0x805084,%eax
  800961:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800967:	83 c4 10             	add    $0x10,%esp
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 40 0c             	mov    0xc(%eax),%eax
  800980:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 06 00 00 00       	mov    $0x6,%eax
  80098f:	e8 3c ff ff ff       	call   8008d0 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8009b9:	e8 12 ff ff ff       	call   8008d0 <fsipc>
  8009be:	89 c3                	mov    %eax,%ebx
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	78 4b                	js     800a0f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8009c4:	39 c6                	cmp    %eax,%esi
  8009c6:	73 16                	jae    8009de <devfile_read+0x48>
  8009c8:	68 44 1e 80 00       	push   $0x801e44
  8009cd:	68 4b 1e 80 00       	push   $0x801e4b
  8009d2:	6a 7d                	push   $0x7d
  8009d4:	68 60 1e 80 00       	push   $0x801e60
  8009d9:	e8 ce 05 00 00       	call   800fac <_panic>
	assert(r <= PGSIZE);
  8009de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8009e3:	7e 16                	jle    8009fb <devfile_read+0x65>
  8009e5:	68 6b 1e 80 00       	push   $0x801e6b
  8009ea:	68 4b 1e 80 00       	push   $0x801e4b
  8009ef:	6a 7e                	push   $0x7e
  8009f1:	68 60 1e 80 00       	push   $0x801e60
  8009f6:	e8 b1 05 00 00       	call   800fac <_panic>
	memmove(buf, &fsipcbuf, r);
  8009fb:	83 ec 04             	sub    $0x4,%esp
  8009fe:	50                   	push   %eax
  8009ff:	68 00 50 80 00       	push   $0x805000
  800a04:	ff 75 0c             	pushl  0xc(%ebp)
  800a07:	e8 ef 0d 00 00       	call   8017fb <memmove>
	return r;
  800a0c:	83 c4 10             	add    $0x10,%esp
}
  800a0f:	89 d8                	mov    %ebx,%eax
  800a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 1c             	sub    $0x1c,%esp
  800a20:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a23:	56                   	push   %esi
  800a24:	e8 bf 0b 00 00       	call   8015e8 <strlen>
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a31:	7f 65                	jg     800a98 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a33:	83 ec 0c             	sub    $0xc,%esp
  800a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a39:	50                   	push   %eax
  800a3a:	e8 e1 f8 ff ff       	call   800320 <fd_alloc>
  800a3f:	89 c3                	mov    %eax,%ebx
  800a41:	83 c4 10             	add    $0x10,%esp
  800a44:	85 c0                	test   %eax,%eax
  800a46:	78 55                	js     800a9d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	56                   	push   %esi
  800a4c:	68 00 50 80 00       	push   $0x805000
  800a51:	e8 e4 0b 00 00       	call   80163a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a61:	b8 01 00 00 00       	mov    $0x1,%eax
  800a66:	e8 65 fe ff ff       	call   8008d0 <fsipc>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	85 c0                	test   %eax,%eax
  800a72:	79 12                	jns    800a86 <open+0x6e>
		fd_close(fd, 0);
  800a74:	83 ec 08             	sub    $0x8,%esp
  800a77:	6a 00                	push   $0x0
  800a79:	ff 75 f4             	pushl  -0xc(%ebp)
  800a7c:	e8 ce f9 ff ff       	call   80044f <fd_close>
		return r;
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	eb 17                	jmp    800a9d <open+0x85>
	}

	return fd2num(fd);
  800a86:	83 ec 0c             	sub    $0xc,%esp
  800a89:	ff 75 f4             	pushl  -0xc(%ebp)
  800a8c:	e8 67 f8 ff ff       	call   8002f8 <fd2num>
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	83 c4 10             	add    $0x10,%esp
  800a96:	eb 05                	jmp    800a9d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800a98:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800a9d:	89 d8                	mov    %ebx,%eax
  800a9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    
	...

00800aa8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	ff 75 08             	pushl  0x8(%ebp)
  800ab6:	e8 4d f8 ff ff       	call   800308 <fd2data>
  800abb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800abd:	83 c4 08             	add    $0x8,%esp
  800ac0:	68 77 1e 80 00       	push   $0x801e77
  800ac5:	56                   	push   %esi
  800ac6:	e8 6f 0b 00 00       	call   80163a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800acb:	8b 43 04             	mov    0x4(%ebx),%eax
  800ace:	2b 03                	sub    (%ebx),%eax
  800ad0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800ad6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800add:	00 00 00 
	stat->st_dev = &devpipe;
  800ae0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800ae7:	30 80 00 
	return 0;
}
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 0c             	sub    $0xc,%esp
  800afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b00:	53                   	push   %ebx
  800b01:	6a 00                	push   $0x0
  800b03:	e8 fa f6 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b08:	89 1c 24             	mov    %ebx,(%esp)
  800b0b:	e8 f8 f7 ff ff       	call   800308 <fd2data>
  800b10:	83 c4 08             	add    $0x8,%esp
  800b13:	50                   	push   %eax
  800b14:	6a 00                	push   $0x0
  800b16:	e8 e7 f6 ff ff       	call   800202 <sys_page_unmap>
}
  800b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 1c             	sub    $0x1c,%esp
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b2e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b33:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	57                   	push   %edi
  800b3a:	e8 a1 0f 00 00       	call   801ae0 <pageref>
  800b3f:	89 c6                	mov    %eax,%esi
  800b41:	83 c4 04             	add    $0x4,%esp
  800b44:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b47:	e8 94 0f 00 00       	call   801ae0 <pageref>
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	39 c6                	cmp    %eax,%esi
  800b51:	0f 94 c0             	sete   %al
  800b54:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800b57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800b5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800b60:	39 cb                	cmp    %ecx,%ebx
  800b62:	75 08                	jne    800b6c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800b6c:	83 f8 01             	cmp    $0x1,%eax
  800b6f:	75 bd                	jne    800b2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800b71:	8b 42 58             	mov    0x58(%edx),%eax
  800b74:	6a 01                	push   $0x1
  800b76:	50                   	push   %eax
  800b77:	53                   	push   %ebx
  800b78:	68 7e 1e 80 00       	push   $0x801e7e
  800b7d:	e8 02 05 00 00       	call   801084 <cprintf>
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	eb a7                	jmp    800b2e <_pipeisclosed+0xe>

00800b87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	83 ec 28             	sub    $0x28,%esp
  800b90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800b93:	56                   	push   %esi
  800b94:	e8 6f f7 ff ff       	call   800308 <fd2data>
  800b99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba2:	75 4a                	jne    800bee <devpipe_write+0x67>
  800ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba9:	eb 56                	jmp    800c01 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bab:	89 da                	mov    %ebx,%edx
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	e8 6c ff ff ff       	call   800b20 <_pipeisclosed>
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	75 4d                	jne    800c05 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800bb8:	e8 d4 f5 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bbd:	8b 43 04             	mov    0x4(%ebx),%eax
  800bc0:	8b 13                	mov    (%ebx),%edx
  800bc2:	83 c2 20             	add    $0x20,%edx
  800bc5:	39 d0                	cmp    %edx,%eax
  800bc7:	73 e2                	jae    800bab <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800bd1:	79 05                	jns    800bd8 <devpipe_write+0x51>
  800bd3:	4a                   	dec    %edx
  800bd4:	83 ca e0             	or     $0xffffffe0,%edx
  800bd7:	42                   	inc    %edx
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  800bde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800be2:	40                   	inc    %eax
  800be3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800be6:	47                   	inc    %edi
  800be7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800bea:	77 07                	ja     800bf3 <devpipe_write+0x6c>
  800bec:	eb 13                	jmp    800c01 <devpipe_write+0x7a>
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800bf3:	8b 43 04             	mov    0x4(%ebx),%eax
  800bf6:	8b 13                	mov    (%ebx),%edx
  800bf8:	83 c2 20             	add    $0x20,%edx
  800bfb:	39 d0                	cmp    %edx,%eax
  800bfd:	73 ac                	jae    800bab <devpipe_write+0x24>
  800bff:	eb c8                	jmp    800bc9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	eb 05                	jmp    800c0a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 18             	sub    $0x18,%esp
  800c1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c1e:	57                   	push   %edi
  800c1f:	e8 e4 f6 ff ff       	call   800308 <fd2data>
  800c24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c2d:	75 44                	jne    800c73 <devpipe_read+0x61>
  800c2f:	be 00 00 00 00       	mov    $0x0,%esi
  800c34:	eb 4f                	jmp    800c85 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c36:	89 f0                	mov    %esi,%eax
  800c38:	eb 54                	jmp    800c8e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c3a:	89 da                	mov    %ebx,%edx
  800c3c:	89 f8                	mov    %edi,%eax
  800c3e:	e8 dd fe ff ff       	call   800b20 <_pipeisclosed>
  800c43:	85 c0                	test   %eax,%eax
  800c45:	75 42                	jne    800c89 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c47:	e8 45 f5 ff ff       	call   800191 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c4c:	8b 03                	mov    (%ebx),%eax
  800c4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c51:	74 e7                	je     800c3a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c53:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c58:	79 05                	jns    800c5f <devpipe_read+0x4d>
  800c5a:	48                   	dec    %eax
  800c5b:	83 c8 e0             	or     $0xffffffe0,%eax
  800c5e:	40                   	inc    %eax
  800c5f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c66:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800c69:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6b:	46                   	inc    %esi
  800c6c:	39 75 10             	cmp    %esi,0x10(%ebp)
  800c6f:	77 07                	ja     800c78 <devpipe_read+0x66>
  800c71:	eb 12                	jmp    800c85 <devpipe_read+0x73>
  800c73:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  800c78:	8b 03                	mov    (%ebx),%eax
  800c7a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c7d:	75 d4                	jne    800c53 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800c7f:	85 f6                	test   %esi,%esi
  800c81:	75 b3                	jne    800c36 <devpipe_read+0x24>
  800c83:	eb b5                	jmp    800c3a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800c85:	89 f0                	mov    %esi,%eax
  800c87:	eb 05                	jmp    800c8e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 28             	sub    $0x28,%esp
  800c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ca2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ca5:	50                   	push   %eax
  800ca6:	e8 75 f6 ff ff       	call   800320 <fd_alloc>
  800cab:	89 c3                	mov    %eax,%ebx
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	0f 88 24 01 00 00    	js     800ddc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cb8:	83 ec 04             	sub    $0x4,%esp
  800cbb:	68 07 04 00 00       	push   $0x407
  800cc0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cc3:	6a 00                	push   $0x0
  800cc5:	e8 ee f4 ff ff       	call   8001b8 <sys_page_alloc>
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	0f 88 05 01 00 00    	js     800ddc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800cdd:	50                   	push   %eax
  800cde:	e8 3d f6 ff ff       	call   800320 <fd_alloc>
  800ce3:	89 c3                	mov    %eax,%ebx
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	0f 88 dc 00 00 00    	js     800dcc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf0:	83 ec 04             	sub    $0x4,%esp
  800cf3:	68 07 04 00 00       	push   $0x407
  800cf8:	ff 75 e0             	pushl  -0x20(%ebp)
  800cfb:	6a 00                	push   $0x0
  800cfd:	e8 b6 f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d02:	89 c3                	mov    %eax,%ebx
  800d04:	83 c4 10             	add    $0x10,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	0f 88 bd 00 00 00    	js     800dcc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d15:	e8 ee f5 ff ff       	call   800308 <fd2data>
  800d1a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1c:	83 c4 0c             	add    $0xc,%esp
  800d1f:	68 07 04 00 00       	push   $0x407
  800d24:	50                   	push   %eax
  800d25:	6a 00                	push   $0x0
  800d27:	e8 8c f4 ff ff       	call   8001b8 <sys_page_alloc>
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	0f 88 83 00 00 00    	js     800dbc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d3f:	e8 c4 f5 ff ff       	call   800308 <fd2data>
  800d44:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d4b:	50                   	push   %eax
  800d4c:	6a 00                	push   $0x0
  800d4e:	56                   	push   %esi
  800d4f:	6a 00                	push   $0x0
  800d51:	e8 86 f4 ff ff       	call   8001dc <sys_page_map>
  800d56:	89 c3                	mov    %eax,%ebx
  800d58:	83 c4 20             	add    $0x20,%esp
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	78 4f                	js     800dae <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d68:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800d74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d7d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d8f:	e8 64 f5 ff ff       	call   8002f8 <fd2num>
  800d94:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800d96:	83 c4 04             	add    $0x4,%esp
  800d99:	ff 75 e0             	pushl  -0x20(%ebp)
  800d9c:	e8 57 f5 ff ff       	call   8002f8 <fd2num>
  800da1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dac:	eb 2e                	jmp    800ddc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dae:	83 ec 08             	sub    $0x8,%esp
  800db1:	56                   	push   %esi
  800db2:	6a 00                	push   $0x0
  800db4:	e8 49 f4 ff ff       	call   800202 <sys_page_unmap>
  800db9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dbc:	83 ec 08             	sub    $0x8,%esp
  800dbf:	ff 75 e0             	pushl  -0x20(%ebp)
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 39 f4 ff ff       	call   800202 <sys_page_unmap>
  800dc9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800dcc:	83 ec 08             	sub    $0x8,%esp
  800dcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 29 f4 ff ff       	call   800202 <sys_page_unmap>
  800dd9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    

00800de6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800dec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800def:	50                   	push   %eax
  800df0:	ff 75 08             	pushl  0x8(%ebp)
  800df3:	e8 9b f5 ff ff       	call   800393 <fd_lookup>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 18                	js     800e17 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	ff 75 f4             	pushl  -0xc(%ebp)
  800e05:	e8 fe f4 ff ff       	call   800308 <fd2data>
	return _pipeisclosed(fd, p);
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0f:	e8 0c fd ff ff       	call   800b20 <_pipeisclosed>
  800e14:	83 c4 10             	add    $0x10,%esp
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    
  800e19:	00 00                	add    %al,(%eax)
	...

00800e1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e2c:	68 96 1e 80 00       	push   $0x801e96
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	e8 01 08 00 00       	call   80163a <strcpy>
	return 0;
}
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e50:	74 45                	je     800e97 <devcons_write+0x57>
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e65:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800e67:	83 fb 7f             	cmp    $0x7f,%ebx
  800e6a:	76 05                	jbe    800e71 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800e6c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800e71:	83 ec 04             	sub    $0x4,%esp
  800e74:	53                   	push   %ebx
  800e75:	03 45 0c             	add    0xc(%ebp),%eax
  800e78:	50                   	push   %eax
  800e79:	57                   	push   %edi
  800e7a:	e8 7c 09 00 00       	call   8017fb <memmove>
		sys_cputs(buf, m);
  800e7f:	83 c4 08             	add    $0x8,%esp
  800e82:	53                   	push   %ebx
  800e83:	57                   	push   %edi
  800e84:	e8 78 f2 ff ff       	call   800101 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e89:	01 de                	add    %ebx,%esi
  800e8b:	89 f0                	mov    %esi,%eax
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e93:	72 cd                	jb     800e62 <devcons_write+0x22>
  800e95:	eb 05                	jmp    800e9c <devcons_write+0x5c>
  800e97:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800e9c:	89 f0                	mov    %esi,%eax
  800e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb0:	75 07                	jne    800eb9 <devcons_read+0x13>
  800eb2:	eb 25                	jmp    800ed9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eb4:	e8 d8 f2 ff ff       	call   800191 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800eb9:	e8 69 f2 ff ff       	call   800127 <sys_cgetc>
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	74 f2                	je     800eb4 <devcons_read+0xe>
  800ec2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 1d                	js     800ee5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800ec8:	83 f8 04             	cmp    $0x4,%eax
  800ecb:	74 13                	je     800ee0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed0:	88 10                	mov    %dl,(%eax)
	return 1;
  800ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed7:	eb 0c                	jmp    800ee5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	eb 05                	jmp    800ee5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ef3:	6a 01                	push   $0x1
  800ef5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	e8 03 f2 ff ff       	call   800101 <sys_cputs>
  800efe:	83 c4 10             	add    $0x10,%esp
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <getchar>:

int
getchar(void)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f09:	6a 01                	push   $0x1
  800f0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f0e:	50                   	push   %eax
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 fe f6 ff ff       	call   800614 <read>
	if (r < 0)
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 0f                	js     800f2c <getchar+0x29>
		return r;
	if (r < 1)
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	7e 06                	jle    800f27 <getchar+0x24>
		return -E_EOF;
	return c;
  800f21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f25:	eb 05                	jmp    800f2c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f37:	50                   	push   %eax
  800f38:	ff 75 08             	pushl  0x8(%ebp)
  800f3b:	e8 53 f4 ff ff       	call   800393 <fd_lookup>
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 11                	js     800f58 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f50:	39 10                	cmp    %edx,(%eax)
  800f52:	0f 94 c0             	sete   %al
  800f55:	0f b6 c0             	movzbl %al,%eax
}
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <opencons>:

int
opencons(void)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	e8 b7 f3 ff ff       	call   800320 <fd_alloc>
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 3a                	js     800faa <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	68 07 04 00 00       	push   $0x407
  800f78:	ff 75 f4             	pushl  -0xc(%ebp)
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 36 f2 ff ff       	call   8001b8 <sys_page_alloc>
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 21                	js     800faa <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800f89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f92:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f97:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	50                   	push   %eax
  800fa2:	e8 51 f3 ff ff       	call   8002f8 <fd2num>
  800fa7:	83 c4 10             	add    $0x10,%esp
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fb1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fb4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fba:	e8 ae f1 ff ff       	call   80016d <sys_getenvid>
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	ff 75 0c             	pushl  0xc(%ebp)
  800fc5:	ff 75 08             	pushl  0x8(%ebp)
  800fc8:	53                   	push   %ebx
  800fc9:	50                   	push   %eax
  800fca:	68 a4 1e 80 00       	push   $0x801ea4
  800fcf:	e8 b0 00 00 00       	call   801084 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd4:	83 c4 18             	add    $0x18,%esp
  800fd7:	56                   	push   %esi
  800fd8:	ff 75 10             	pushl  0x10(%ebp)
  800fdb:	e8 53 00 00 00       	call   801033 <vcprintf>
	cprintf("\n");
  800fe0:	c7 04 24 8f 1e 80 00 	movl   $0x801e8f,(%esp)
  800fe7:	e8 98 00 00 00       	call   801084 <cprintf>
  800fec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fef:	cc                   	int3   
  800ff0:	eb fd                	jmp    800fef <_panic+0x43>
	...

00800ff4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ffe:	8b 03                	mov    (%ebx),%eax
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801007:	40                   	inc    %eax
  801008:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80100a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80100f:	75 1a                	jne    80102b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	68 ff 00 00 00       	push   $0xff
  801019:	8d 43 08             	lea    0x8(%ebx),%eax
  80101c:	50                   	push   %eax
  80101d:	e8 df f0 ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  801022:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801028:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80102b:	ff 43 04             	incl   0x4(%ebx)
}
  80102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80103c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801043:	00 00 00 
	b.cnt = 0;
  801046:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80104d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801050:	ff 75 0c             	pushl  0xc(%ebp)
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	68 f4 0f 80 00       	push   $0x800ff4
  801062:	e8 82 01 00 00       	call   8011e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801067:	83 c4 08             	add    $0x8,%esp
  80106a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801070:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	e8 85 f0 ff ff       	call   800101 <sys_cputs>

	return b.cnt;
}
  80107c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80108a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80108d:	50                   	push   %eax
  80108e:	ff 75 08             	pushl  0x8(%ebp)
  801091:	e8 9d ff ff ff       	call   801033 <vcprintf>
	va_end(ap);

	return cnt;
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 2c             	sub    $0x2c,%esp
  8010a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a4:	89 d6                	mov    %edx,%esi
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8010b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010b8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8010be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8010c5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8010c8:	72 0c                	jb     8010d6 <printnum+0x3e>
  8010ca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8010cd:	76 07                	jbe    8010d6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8010cf:	4b                   	dec    %ebx
  8010d0:	85 db                	test   %ebx,%ebx
  8010d2:	7f 31                	jg     801105 <printnum+0x6d>
  8010d4:	eb 3f                	jmp    801115 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	57                   	push   %edi
  8010da:	4b                   	dec    %ebx
  8010db:	53                   	push   %ebx
  8010dc:	50                   	push   %eax
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8010e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8010e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8010ec:	e8 33 0a 00 00       	call   801b24 <__udivdi3>
  8010f1:	83 c4 18             	add    $0x18,%esp
  8010f4:	52                   	push   %edx
  8010f5:	50                   	push   %eax
  8010f6:	89 f2                	mov    %esi,%edx
  8010f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fb:	e8 98 ff ff ff       	call   801098 <printnum>
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	eb 10                	jmp    801115 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	56                   	push   %esi
  801109:	57                   	push   %edi
  80110a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80110d:	4b                   	dec    %ebx
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 db                	test   %ebx,%ebx
  801113:	7f f0                	jg     801105 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801115:	83 ec 08             	sub    $0x8,%esp
  801118:	56                   	push   %esi
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111f:	ff 75 d0             	pushl  -0x30(%ebp)
  801122:	ff 75 dc             	pushl  -0x24(%ebp)
  801125:	ff 75 d8             	pushl  -0x28(%ebp)
  801128:	e8 13 0b 00 00       	call   801c40 <__umoddi3>
  80112d:	83 c4 14             	add    $0x14,%esp
  801130:	0f be 80 c7 1e 80 00 	movsbl 0x801ec7(%eax),%eax
  801137:	50                   	push   %eax
  801138:	ff 55 e4             	call   *-0x1c(%ebp)
  80113b:	83 c4 10             	add    $0x10,%esp
}
  80113e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801149:	83 fa 01             	cmp    $0x1,%edx
  80114c:	7e 0e                	jle    80115c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80114e:	8b 10                	mov    (%eax),%edx
  801150:	8d 4a 08             	lea    0x8(%edx),%ecx
  801153:	89 08                	mov    %ecx,(%eax)
  801155:	8b 02                	mov    (%edx),%eax
  801157:	8b 52 04             	mov    0x4(%edx),%edx
  80115a:	eb 22                	jmp    80117e <getuint+0x38>
	else if (lflag)
  80115c:	85 d2                	test   %edx,%edx
  80115e:	74 10                	je     801170 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801160:	8b 10                	mov    (%eax),%edx
  801162:	8d 4a 04             	lea    0x4(%edx),%ecx
  801165:	89 08                	mov    %ecx,(%eax)
  801167:	8b 02                	mov    (%edx),%eax
  801169:	ba 00 00 00 00       	mov    $0x0,%edx
  80116e:	eb 0e                	jmp    80117e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801170:	8b 10                	mov    (%eax),%edx
  801172:	8d 4a 04             	lea    0x4(%edx),%ecx
  801175:	89 08                	mov    %ecx,(%eax)
  801177:	8b 02                	mov    (%edx),%eax
  801179:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801183:	83 fa 01             	cmp    $0x1,%edx
  801186:	7e 0e                	jle    801196 <getint+0x16>
		return va_arg(*ap, long long);
  801188:	8b 10                	mov    (%eax),%edx
  80118a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80118d:	89 08                	mov    %ecx,(%eax)
  80118f:	8b 02                	mov    (%edx),%eax
  801191:	8b 52 04             	mov    0x4(%edx),%edx
  801194:	eb 1a                	jmp    8011b0 <getint+0x30>
	else if (lflag)
  801196:	85 d2                	test   %edx,%edx
  801198:	74 0c                	je     8011a6 <getint+0x26>
		return va_arg(*ap, long);
  80119a:	8b 10                	mov    (%eax),%edx
  80119c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80119f:	89 08                	mov    %ecx,(%eax)
  8011a1:	8b 02                	mov    (%edx),%eax
  8011a3:	99                   	cltd   
  8011a4:	eb 0a                	jmp    8011b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8011a6:	8b 10                	mov    (%eax),%edx
  8011a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ab:	89 08                	mov    %ecx,(%eax)
  8011ad:	8b 02                	mov    (%edx),%eax
  8011af:	99                   	cltd   
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011bb:	8b 10                	mov    (%eax),%edx
  8011bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c0:	73 08                	jae    8011ca <sprintputch+0x18>
		*b->buf++ = ch;
  8011c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c5:	88 0a                	mov    %cl,(%edx)
  8011c7:	42                   	inc    %edx
  8011c8:	89 10                	mov    %edx,(%eax)
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d5:	50                   	push   %eax
  8011d6:	ff 75 10             	pushl  0x10(%ebp)
  8011d9:	ff 75 0c             	pushl  0xc(%ebp)
  8011dc:	ff 75 08             	pushl  0x8(%ebp)
  8011df:	e8 05 00 00 00       	call   8011e9 <vprintfmt>
	va_end(ap);
  8011e4:	83 c4 10             	add    $0x10,%esp
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 2c             	sub    $0x2c,%esp
  8011f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8011f8:	eb 13                	jmp    80120d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	0f 84 6d 03 00 00    	je     80156f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	57                   	push   %edi
  801206:	50                   	push   %eax
  801207:	ff 55 08             	call   *0x8(%ebp)
  80120a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80120d:	0f b6 06             	movzbl (%esi),%eax
  801210:	46                   	inc    %esi
  801211:	83 f8 25             	cmp    $0x25,%eax
  801214:	75 e4                	jne    8011fa <vprintfmt+0x11>
  801216:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80121a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801221:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801228:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80122f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801234:	eb 28                	jmp    80125e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801236:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801238:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80123c:	eb 20                	jmp    80125e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801240:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801244:	eb 18                	jmp    80125e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801246:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801248:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80124f:	eb 0d                	jmp    80125e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801251:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801254:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801257:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	8a 06                	mov    (%esi),%al
  801260:	0f b6 d0             	movzbl %al,%edx
  801263:	8d 5e 01             	lea    0x1(%esi),%ebx
  801266:	83 e8 23             	sub    $0x23,%eax
  801269:	3c 55                	cmp    $0x55,%al
  80126b:	0f 87 e0 02 00 00    	ja     801551 <vprintfmt+0x368>
  801271:	0f b6 c0             	movzbl %al,%eax
  801274:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80127b:	83 ea 30             	sub    $0x30,%edx
  80127e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801281:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801284:	8d 50 d0             	lea    -0x30(%eax),%edx
  801287:	83 fa 09             	cmp    $0x9,%edx
  80128a:	77 44                	ja     8012d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128c:	89 de                	mov    %ebx,%esi
  80128e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801291:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801292:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801295:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801299:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80129c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80129f:	83 fb 09             	cmp    $0x9,%ebx
  8012a2:	76 ed                	jbe    801291 <vprintfmt+0xa8>
  8012a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8012a7:	eb 29                	jmp    8012d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ac:	8d 50 04             	lea    0x4(%eax),%edx
  8012af:	89 55 14             	mov    %edx,0x14(%ebp)
  8012b2:	8b 00                	mov    (%eax),%eax
  8012b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012b9:	eb 17                	jmp    8012d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8012bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012bf:	78 85                	js     801246 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c1:	89 de                	mov    %ebx,%esi
  8012c3:	eb 99                	jmp    80125e <vprintfmt+0x75>
  8012c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8012ce:	eb 8e                	jmp    80125e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d6:	79 86                	jns    80125e <vprintfmt+0x75>
  8012d8:	e9 74 ff ff ff       	jmp    801251 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012de:	89 de                	mov    %ebx,%esi
  8012e0:	e9 79 ff ff ff       	jmp    80125e <vprintfmt+0x75>
  8012e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012eb:	8d 50 04             	lea    0x4(%eax),%edx
  8012ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	57                   	push   %edi
  8012f5:	ff 30                	pushl  (%eax)
  8012f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8012fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801300:	e9 08 ff ff ff       	jmp    80120d <vprintfmt+0x24>
  801305:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801308:	8b 45 14             	mov    0x14(%ebp),%eax
  80130b:	8d 50 04             	lea    0x4(%eax),%edx
  80130e:	89 55 14             	mov    %edx,0x14(%ebp)
  801311:	8b 00                	mov    (%eax),%eax
  801313:	85 c0                	test   %eax,%eax
  801315:	79 02                	jns    801319 <vprintfmt+0x130>
  801317:	f7 d8                	neg    %eax
  801319:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131b:	83 f8 0f             	cmp    $0xf,%eax
  80131e:	7f 0b                	jg     80132b <vprintfmt+0x142>
  801320:	8b 04 85 60 21 80 00 	mov    0x802160(,%eax,4),%eax
  801327:	85 c0                	test   %eax,%eax
  801329:	75 1a                	jne    801345 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80132b:	52                   	push   %edx
  80132c:	68 df 1e 80 00       	push   $0x801edf
  801331:	57                   	push   %edi
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 92 fe ff ff       	call   8011cc <printfmt>
  80133a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801340:	e9 c8 fe ff ff       	jmp    80120d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801345:	50                   	push   %eax
  801346:	68 5d 1e 80 00       	push   $0x801e5d
  80134b:	57                   	push   %edi
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 78 fe ff ff       	call   8011cc <printfmt>
  801354:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80135a:	e9 ae fe ff ff       	jmp    80120d <vprintfmt+0x24>
  80135f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801362:	89 de                	mov    %ebx,%esi
  801364:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801367:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80136a:	8b 45 14             	mov    0x14(%ebp),%eax
  80136d:	8d 50 04             	lea    0x4(%eax),%edx
  801370:	89 55 14             	mov    %edx,0x14(%ebp)
  801373:	8b 00                	mov    (%eax),%eax
  801375:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801378:	85 c0                	test   %eax,%eax
  80137a:	75 07                	jne    801383 <vprintfmt+0x19a>
				p = "(null)";
  80137c:	c7 45 d0 d8 1e 80 00 	movl   $0x801ed8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801383:	85 db                	test   %ebx,%ebx
  801385:	7e 42                	jle    8013c9 <vprintfmt+0x1e0>
  801387:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80138b:	74 3c                	je     8013c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	51                   	push   %ecx
  801391:	ff 75 d0             	pushl  -0x30(%ebp)
  801394:	e8 6f 02 00 00       	call   801608 <strnlen>
  801399:	29 c3                	sub    %eax,%ebx
  80139b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 db                	test   %ebx,%ebx
  8013a3:	7e 24                	jle    8013c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8013a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8013a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8013ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	57                   	push   %edi
  8013b3:	53                   	push   %ebx
  8013b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b7:	4e                   	dec    %esi
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 f6                	test   %esi,%esi
  8013bd:	7f f0                	jg     8013af <vprintfmt+0x1c6>
  8013bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8013c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8013cc:	0f be 02             	movsbl (%edx),%eax
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	75 47                	jne    80141a <vprintfmt+0x231>
  8013d3:	eb 37                	jmp    80140c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d9:	74 16                	je     8013f1 <vprintfmt+0x208>
  8013db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013de:	83 fa 5e             	cmp    $0x5e,%edx
  8013e1:	76 0e                	jbe    8013f1 <vprintfmt+0x208>
					putch('?', putdat);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	57                   	push   %edi
  8013e7:	6a 3f                	push   $0x3f
  8013e9:	ff 55 08             	call   *0x8(%ebp)
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	eb 0b                	jmp    8013fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	57                   	push   %edi
  8013f5:	50                   	push   %eax
  8013f6:	ff 55 08             	call   *0x8(%ebp)
  8013f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8013ff:	0f be 03             	movsbl (%ebx),%eax
  801402:	85 c0                	test   %eax,%eax
  801404:	74 03                	je     801409 <vprintfmt+0x220>
  801406:	43                   	inc    %ebx
  801407:	eb 1b                	jmp    801424 <vprintfmt+0x23b>
  801409:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80140c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801410:	7f 1e                	jg     801430 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801412:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801415:	e9 f3 fd ff ff       	jmp    80120d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80141a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80141d:	43                   	inc    %ebx
  80141e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801421:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801424:	85 f6                	test   %esi,%esi
  801426:	78 ad                	js     8013d5 <vprintfmt+0x1ec>
  801428:	4e                   	dec    %esi
  801429:	79 aa                	jns    8013d5 <vprintfmt+0x1ec>
  80142b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80142e:	eb dc                	jmp    80140c <vprintfmt+0x223>
  801430:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	57                   	push   %edi
  801437:	6a 20                	push   $0x20
  801439:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80143c:	4b                   	dec    %ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 db                	test   %ebx,%ebx
  801442:	7f ef                	jg     801433 <vprintfmt+0x24a>
  801444:	e9 c4 fd ff ff       	jmp    80120d <vprintfmt+0x24>
  801449:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80144c:	89 ca                	mov    %ecx,%edx
  80144e:	8d 45 14             	lea    0x14(%ebp),%eax
  801451:	e8 2a fd ff ff       	call   801180 <getint>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80145a:	85 d2                	test   %edx,%edx
  80145c:	78 0a                	js     801468 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80145e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801463:	e9 b0 00 00 00       	jmp    801518 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	57                   	push   %edi
  80146c:	6a 2d                	push   $0x2d
  80146e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801471:	f7 db                	neg    %ebx
  801473:	83 d6 00             	adc    $0x0,%esi
  801476:	f7 de                	neg    %esi
  801478:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80147b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801480:	e9 93 00 00 00       	jmp    801518 <vprintfmt+0x32f>
  801485:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801488:	89 ca                	mov    %ecx,%edx
  80148a:	8d 45 14             	lea    0x14(%ebp),%eax
  80148d:	e8 b4 fc ff ff       	call   801146 <getuint>
  801492:	89 c3                	mov    %eax,%ebx
  801494:	89 d6                	mov    %edx,%esi
			base = 10;
  801496:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80149b:	eb 7b                	jmp    801518 <vprintfmt+0x32f>
  80149d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8014a0:	89 ca                	mov    %ecx,%edx
  8014a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014a5:	e8 d6 fc ff ff       	call   801180 <getint>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8014ae:	85 d2                	test   %edx,%edx
  8014b0:	78 07                	js     8014b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8014b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014b7:	eb 5f                	jmp    801518 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	57                   	push   %edi
  8014bd:	6a 2d                	push   $0x2d
  8014bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8014c2:	f7 db                	neg    %ebx
  8014c4:	83 d6 00             	adc    $0x0,%esi
  8014c7:	f7 de                	neg    %esi
  8014c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8014cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d1:	eb 45                	jmp    801518 <vprintfmt+0x32f>
  8014d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	57                   	push   %edi
  8014da:	6a 30                	push   $0x30
  8014dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	57                   	push   %edi
  8014e3:	6a 78                	push   $0x78
  8014e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8d 50 04             	lea    0x4(%eax),%edx
  8014ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8014f1:	8b 18                	mov    (%eax),%ebx
  8014f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8014f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8014fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801500:	eb 16                	jmp    801518 <vprintfmt+0x32f>
  801502:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801505:	89 ca                	mov    %ecx,%edx
  801507:	8d 45 14             	lea    0x14(%ebp),%eax
  80150a:	e8 37 fc ff ff       	call   801146 <getuint>
  80150f:	89 c3                	mov    %eax,%ebx
  801511:	89 d6                	mov    %edx,%esi
			base = 16;
  801513:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80151f:	52                   	push   %edx
  801520:	ff 75 e4             	pushl  -0x1c(%ebp)
  801523:	50                   	push   %eax
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	89 fa                	mov    %edi,%edx
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	e8 68 fb ff ff       	call   801098 <printnum>
			break;
  801530:	83 c4 20             	add    $0x20,%esp
  801533:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801536:	e9 d2 fc ff ff       	jmp    80120d <vprintfmt+0x24>
  80153b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	57                   	push   %edi
  801542:	52                   	push   %edx
  801543:	ff 55 08             	call   *0x8(%ebp)
			break;
  801546:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801549:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80154c:	e9 bc fc ff ff       	jmp    80120d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	57                   	push   %edi
  801555:	6a 25                	push   $0x25
  801557:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	eb 02                	jmp    801561 <vprintfmt+0x378>
  80155f:	89 c6                	mov    %eax,%esi
  801561:	8d 46 ff             	lea    -0x1(%esi),%eax
  801564:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801568:	75 f5                	jne    80155f <vprintfmt+0x376>
  80156a:	e9 9e fc ff ff       	jmp    80120d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80156f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 18             	sub    $0x18,%esp
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801583:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801586:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80158a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80158d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801594:	85 c0                	test   %eax,%eax
  801596:	74 26                	je     8015be <vsnprintf+0x47>
  801598:	85 d2                	test   %edx,%edx
  80159a:	7e 29                	jle    8015c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80159c:	ff 75 14             	pushl  0x14(%ebp)
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	68 b2 11 80 00       	push   $0x8011b2
  8015ab:	e8 39 fc ff ff       	call   8011e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8015b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 0c                	jmp    8015ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c3:	eb 05                	jmp    8015ca <vsnprintf+0x53>
  8015c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8015d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8015d5:	50                   	push   %eax
  8015d6:	ff 75 10             	pushl  0x10(%ebp)
  8015d9:	ff 75 0c             	pushl  0xc(%ebp)
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 93 ff ff ff       	call   801577 <vsnprintf>
	va_end(ap);

	return rc;
}
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    
	...

008015e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015ee:	80 3a 00             	cmpb   $0x0,(%edx)
  8015f1:	74 0e                	je     801601 <strlen+0x19>
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015f8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8015fd:	75 f9                	jne    8015f8 <strlen+0x10>
  8015ff:	eb 05                	jmp    801606 <strlen+0x1e>
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80160e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801611:	85 d2                	test   %edx,%edx
  801613:	74 17                	je     80162c <strnlen+0x24>
  801615:	80 39 00             	cmpb   $0x0,(%ecx)
  801618:	74 19                	je     801633 <strnlen+0x2b>
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80161f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801620:	39 d0                	cmp    %edx,%eax
  801622:	74 14                	je     801638 <strnlen+0x30>
  801624:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801628:	75 f5                	jne    80161f <strnlen+0x17>
  80162a:	eb 0c                	jmp    801638 <strnlen+0x30>
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
  801631:	eb 05                	jmp    801638 <strnlen+0x30>
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	53                   	push   %ebx
  80163e:	8b 45 08             	mov    0x8(%ebp),%eax
  801641:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801644:	ba 00 00 00 00       	mov    $0x0,%edx
  801649:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80164c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80164f:	42                   	inc    %edx
  801650:	84 c9                	test   %cl,%cl
  801652:	75 f5                	jne    801649 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801654:	5b                   	pop    %ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80165e:	53                   	push   %ebx
  80165f:	e8 84 ff ff ff       	call   8015e8 <strlen>
  801664:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801667:	ff 75 0c             	pushl  0xc(%ebp)
  80166a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80166d:	50                   	push   %eax
  80166e:	e8 c7 ff ff ff       	call   80163a <strcpy>
	return dst;
}
  801673:	89 d8                	mov    %ebx,%eax
  801675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	56                   	push   %esi
  80167e:	53                   	push   %ebx
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 55 0c             	mov    0xc(%ebp),%edx
  801685:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801688:	85 f6                	test   %esi,%esi
  80168a:	74 15                	je     8016a1 <strncpy+0x27>
  80168c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801691:	8a 1a                	mov    (%edx),%bl
  801693:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801696:	80 3a 01             	cmpb   $0x1,(%edx)
  801699:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80169c:	41                   	inc    %ecx
  80169d:	39 ce                	cmp    %ecx,%esi
  80169f:	77 f0                	ja     801691 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	57                   	push   %edi
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016b4:	85 f6                	test   %esi,%esi
  8016b6:	74 32                	je     8016ea <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8016b8:	83 fe 01             	cmp    $0x1,%esi
  8016bb:	74 22                	je     8016df <strlcpy+0x3a>
  8016bd:	8a 0b                	mov    (%ebx),%cl
  8016bf:	84 c9                	test   %cl,%cl
  8016c1:	74 20                	je     8016e3 <strlcpy+0x3e>
  8016c3:	89 f8                	mov    %edi,%eax
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8016ca:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016cd:	88 08                	mov    %cl,(%eax)
  8016cf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016d0:	39 f2                	cmp    %esi,%edx
  8016d2:	74 11                	je     8016e5 <strlcpy+0x40>
  8016d4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8016d8:	42                   	inc    %edx
  8016d9:	84 c9                	test   %cl,%cl
  8016db:	75 f0                	jne    8016cd <strlcpy+0x28>
  8016dd:	eb 06                	jmp    8016e5 <strlcpy+0x40>
  8016df:	89 f8                	mov    %edi,%eax
  8016e1:	eb 02                	jmp    8016e5 <strlcpy+0x40>
  8016e3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016e5:	c6 00 00             	movb   $0x0,(%eax)
  8016e8:	eb 02                	jmp    8016ec <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ea:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8016ec:	29 f8                	sub    %edi,%eax
}
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5f                   	pop    %edi
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8016fc:	8a 01                	mov    (%ecx),%al
  8016fe:	84 c0                	test   %al,%al
  801700:	74 10                	je     801712 <strcmp+0x1f>
  801702:	3a 02                	cmp    (%edx),%al
  801704:	75 0c                	jne    801712 <strcmp+0x1f>
		p++, q++;
  801706:	41                   	inc    %ecx
  801707:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801708:	8a 01                	mov    (%ecx),%al
  80170a:	84 c0                	test   %al,%al
  80170c:	74 04                	je     801712 <strcmp+0x1f>
  80170e:	3a 02                	cmp    (%edx),%al
  801710:	74 f4                	je     801706 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801712:	0f b6 c0             	movzbl %al,%eax
  801715:	0f b6 12             	movzbl (%edx),%edx
  801718:	29 d0                	sub    %edx,%eax
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	8b 55 08             	mov    0x8(%ebp),%edx
  801723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801726:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801729:	85 c0                	test   %eax,%eax
  80172b:	74 1b                	je     801748 <strncmp+0x2c>
  80172d:	8a 1a                	mov    (%edx),%bl
  80172f:	84 db                	test   %bl,%bl
  801731:	74 24                	je     801757 <strncmp+0x3b>
  801733:	3a 19                	cmp    (%ecx),%bl
  801735:	75 20                	jne    801757 <strncmp+0x3b>
  801737:	48                   	dec    %eax
  801738:	74 15                	je     80174f <strncmp+0x33>
		n--, p++, q++;
  80173a:	42                   	inc    %edx
  80173b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80173c:	8a 1a                	mov    (%edx),%bl
  80173e:	84 db                	test   %bl,%bl
  801740:	74 15                	je     801757 <strncmp+0x3b>
  801742:	3a 19                	cmp    (%ecx),%bl
  801744:	74 f1                	je     801737 <strncmp+0x1b>
  801746:	eb 0f                	jmp    801757 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801748:	b8 00 00 00 00       	mov    $0x0,%eax
  80174d:	eb 05                	jmp    801754 <strncmp+0x38>
  80174f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801754:	5b                   	pop    %ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801757:	0f b6 02             	movzbl (%edx),%eax
  80175a:	0f b6 11             	movzbl (%ecx),%edx
  80175d:	29 d0                	sub    %edx,%eax
  80175f:	eb f3                	jmp    801754 <strncmp+0x38>

00801761 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80176a:	8a 10                	mov    (%eax),%dl
  80176c:	84 d2                	test   %dl,%dl
  80176e:	74 18                	je     801788 <strchr+0x27>
		if (*s == c)
  801770:	38 ca                	cmp    %cl,%dl
  801772:	75 06                	jne    80177a <strchr+0x19>
  801774:	eb 17                	jmp    80178d <strchr+0x2c>
  801776:	38 ca                	cmp    %cl,%dl
  801778:	74 13                	je     80178d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80177a:	40                   	inc    %eax
  80177b:	8a 10                	mov    (%eax),%dl
  80177d:	84 d2                	test   %dl,%dl
  80177f:	75 f5                	jne    801776 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  801781:	b8 00 00 00 00       	mov    $0x0,%eax
  801786:	eb 05                	jmp    80178d <strchr+0x2c>
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801798:	8a 10                	mov    (%eax),%dl
  80179a:	84 d2                	test   %dl,%dl
  80179c:	74 11                	je     8017af <strfind+0x20>
		if (*s == c)
  80179e:	38 ca                	cmp    %cl,%dl
  8017a0:	75 06                	jne    8017a8 <strfind+0x19>
  8017a2:	eb 0b                	jmp    8017af <strfind+0x20>
  8017a4:	38 ca                	cmp    %cl,%dl
  8017a6:	74 07                	je     8017af <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8017a8:	40                   	inc    %eax
  8017a9:	8a 10                	mov    (%eax),%dl
  8017ab:	84 d2                	test   %dl,%dl
  8017ad:	75 f5                	jne    8017a4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c0:	85 c9                	test   %ecx,%ecx
  8017c2:	74 30                	je     8017f4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ca:	75 25                	jne    8017f1 <memset+0x40>
  8017cc:	f6 c1 03             	test   $0x3,%cl
  8017cf:	75 20                	jne    8017f1 <memset+0x40>
		c &= 0xFF;
  8017d1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d4:	89 d3                	mov    %edx,%ebx
  8017d6:	c1 e3 08             	shl    $0x8,%ebx
  8017d9:	89 d6                	mov    %edx,%esi
  8017db:	c1 e6 18             	shl    $0x18,%esi
  8017de:	89 d0                	mov    %edx,%eax
  8017e0:	c1 e0 10             	shl    $0x10,%eax
  8017e3:	09 f0                	or     %esi,%eax
  8017e5:	09 d0                	or     %edx,%eax
  8017e7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8017e9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8017ec:	fc                   	cld    
  8017ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8017ef:	eb 03                	jmp    8017f4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f1:	fc                   	cld    
  8017f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017f4:	89 f8                	mov    %edi,%eax
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5f                   	pop    %edi
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
  801803:	8b 75 0c             	mov    0xc(%ebp),%esi
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801809:	39 c6                	cmp    %eax,%esi
  80180b:	73 34                	jae    801841 <memmove+0x46>
  80180d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801810:	39 d0                	cmp    %edx,%eax
  801812:	73 2d                	jae    801841 <memmove+0x46>
		s += n;
		d += n;
  801814:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801817:	f6 c2 03             	test   $0x3,%dl
  80181a:	75 1b                	jne    801837 <memmove+0x3c>
  80181c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801822:	75 13                	jne    801837 <memmove+0x3c>
  801824:	f6 c1 03             	test   $0x3,%cl
  801827:	75 0e                	jne    801837 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801829:	83 ef 04             	sub    $0x4,%edi
  80182c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80182f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801832:	fd                   	std    
  801833:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801835:	eb 07                	jmp    80183e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801837:	4f                   	dec    %edi
  801838:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80183b:	fd                   	std    
  80183c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80183e:	fc                   	cld    
  80183f:	eb 20                	jmp    801861 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801841:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801847:	75 13                	jne    80185c <memmove+0x61>
  801849:	a8 03                	test   $0x3,%al
  80184b:	75 0f                	jne    80185c <memmove+0x61>
  80184d:	f6 c1 03             	test   $0x3,%cl
  801850:	75 0a                	jne    80185c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801852:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801855:	89 c7                	mov    %eax,%edi
  801857:	fc                   	cld    
  801858:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185a:	eb 05                	jmp    801861 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80185c:	89 c7                	mov    %eax,%edi
  80185e:	fc                   	cld    
  80185f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801861:	5e                   	pop    %esi
  801862:	5f                   	pop    %edi
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	ff 75 08             	pushl  0x8(%ebp)
  801871:	e8 85 ff ff ff       	call   8017fb <memmove>
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801881:	8b 75 0c             	mov    0xc(%ebp),%esi
  801884:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801887:	85 ff                	test   %edi,%edi
  801889:	74 32                	je     8018bd <memcmp+0x45>
		if (*s1 != *s2)
  80188b:	8a 03                	mov    (%ebx),%al
  80188d:	8a 0e                	mov    (%esi),%cl
  80188f:	38 c8                	cmp    %cl,%al
  801891:	74 19                	je     8018ac <memcmp+0x34>
  801893:	eb 0d                	jmp    8018a2 <memcmp+0x2a>
  801895:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  801899:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  80189d:	42                   	inc    %edx
  80189e:	38 c8                	cmp    %cl,%al
  8018a0:	74 10                	je     8018b2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8018a2:	0f b6 c0             	movzbl %al,%eax
  8018a5:	0f b6 c9             	movzbl %cl,%ecx
  8018a8:	29 c8                	sub    %ecx,%eax
  8018aa:	eb 16                	jmp    8018c2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ac:	4f                   	dec    %edi
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	39 fa                	cmp    %edi,%edx
  8018b4:	75 df                	jne    801895 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	eb 05                	jmp    8018c2 <memcmp+0x4a>
  8018bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018cd:	89 c2                	mov    %eax,%edx
  8018cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018d2:	39 d0                	cmp    %edx,%eax
  8018d4:	73 12                	jae    8018e8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018d6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8018d9:	38 08                	cmp    %cl,(%eax)
  8018db:	75 06                	jne    8018e3 <memfind+0x1c>
  8018dd:	eb 09                	jmp    8018e8 <memfind+0x21>
  8018df:	38 08                	cmp    %cl,(%eax)
  8018e1:	74 05                	je     8018e8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e3:	40                   	inc    %eax
  8018e4:	39 c2                	cmp    %eax,%edx
  8018e6:	77 f7                	ja     8018df <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f6:	eb 01                	jmp    8018f9 <strtol+0xf>
		s++;
  8018f8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018f9:	8a 02                	mov    (%edx),%al
  8018fb:	3c 20                	cmp    $0x20,%al
  8018fd:	74 f9                	je     8018f8 <strtol+0xe>
  8018ff:	3c 09                	cmp    $0x9,%al
  801901:	74 f5                	je     8018f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801903:	3c 2b                	cmp    $0x2b,%al
  801905:	75 08                	jne    80190f <strtol+0x25>
		s++;
  801907:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801908:	bf 00 00 00 00       	mov    $0x0,%edi
  80190d:	eb 13                	jmp    801922 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80190f:	3c 2d                	cmp    $0x2d,%al
  801911:	75 0a                	jne    80191d <strtol+0x33>
		s++, neg = 1;
  801913:	8d 52 01             	lea    0x1(%edx),%edx
  801916:	bf 01 00 00 00       	mov    $0x1,%edi
  80191b:	eb 05                	jmp    801922 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80191d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801922:	85 db                	test   %ebx,%ebx
  801924:	74 05                	je     80192b <strtol+0x41>
  801926:	83 fb 10             	cmp    $0x10,%ebx
  801929:	75 28                	jne    801953 <strtol+0x69>
  80192b:	8a 02                	mov    (%edx),%al
  80192d:	3c 30                	cmp    $0x30,%al
  80192f:	75 10                	jne    801941 <strtol+0x57>
  801931:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801935:	75 0a                	jne    801941 <strtol+0x57>
		s += 2, base = 16;
  801937:	83 c2 02             	add    $0x2,%edx
  80193a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80193f:	eb 12                	jmp    801953 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801941:	85 db                	test   %ebx,%ebx
  801943:	75 0e                	jne    801953 <strtol+0x69>
  801945:	3c 30                	cmp    $0x30,%al
  801947:	75 05                	jne    80194e <strtol+0x64>
		s++, base = 8;
  801949:	42                   	inc    %edx
  80194a:	b3 08                	mov    $0x8,%bl
  80194c:	eb 05                	jmp    801953 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80194e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80195a:	8a 0a                	mov    (%edx),%cl
  80195c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80195f:	80 fb 09             	cmp    $0x9,%bl
  801962:	77 08                	ja     80196c <strtol+0x82>
			dig = *s - '0';
  801964:	0f be c9             	movsbl %cl,%ecx
  801967:	83 e9 30             	sub    $0x30,%ecx
  80196a:	eb 1e                	jmp    80198a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80196c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80196f:	80 fb 19             	cmp    $0x19,%bl
  801972:	77 08                	ja     80197c <strtol+0x92>
			dig = *s - 'a' + 10;
  801974:	0f be c9             	movsbl %cl,%ecx
  801977:	83 e9 57             	sub    $0x57,%ecx
  80197a:	eb 0e                	jmp    80198a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80197c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80197f:	80 fb 19             	cmp    $0x19,%bl
  801982:	77 13                	ja     801997 <strtol+0xad>
			dig = *s - 'A' + 10;
  801984:	0f be c9             	movsbl %cl,%ecx
  801987:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80198a:	39 f1                	cmp    %esi,%ecx
  80198c:	7d 0d                	jge    80199b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  80198e:	42                   	inc    %edx
  80198f:	0f af c6             	imul   %esi,%eax
  801992:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801995:	eb c3                	jmp    80195a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801997:	89 c1                	mov    %eax,%ecx
  801999:	eb 02                	jmp    80199d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80199b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80199d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019a1:	74 05                	je     8019a8 <strtol+0xbe>
		*endptr = (char *) s;
  8019a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019a6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019a8:	85 ff                	test   %edi,%edi
  8019aa:	74 04                	je     8019b0 <strtol+0xc6>
  8019ac:	89 c8                	mov    %ecx,%eax
  8019ae:	f7 d8                	neg    %eax
}
  8019b0:	5b                   	pop    %ebx
  8019b1:	5e                   	pop    %esi
  8019b2:	5f                   	pop    %edi
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    
  8019b5:	00 00                	add    %al,(%eax)
	...

008019b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	74 0e                	je     8019d8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8019ca:	83 ec 0c             	sub    $0xc,%esp
  8019cd:	50                   	push   %eax
  8019ce:	e8 e0 e8 ff ff       	call   8002b3 <sys_ipc_recv>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	eb 10                	jmp    8019e8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	68 00 00 c0 ee       	push   $0xeec00000
  8019e0:	e8 ce e8 ff ff       	call   8002b3 <sys_ipc_recv>
  8019e5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	75 26                	jne    801a12 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8019ec:	85 f6                	test   %esi,%esi
  8019ee:	74 0a                	je     8019fa <ipc_recv+0x42>
  8019f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f5:	8b 40 74             	mov    0x74(%eax),%eax
  8019f8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8019fa:	85 db                	test   %ebx,%ebx
  8019fc:	74 0a                	je     801a08 <ipc_recv+0x50>
  8019fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801a03:	8b 40 78             	mov    0x78(%eax),%eax
  801a06:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a08:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0d:	8b 40 70             	mov    0x70(%eax),%eax
  801a10:	eb 14                	jmp    801a26 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a12:	85 f6                	test   %esi,%esi
  801a14:	74 06                	je     801a1c <ipc_recv+0x64>
  801a16:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a1c:	85 db                	test   %ebx,%ebx
  801a1e:	74 06                	je     801a26 <ipc_recv+0x6e>
  801a20:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	57                   	push   %edi
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a3c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a3f:	85 db                	test   %ebx,%ebx
  801a41:	75 25                	jne    801a68 <ipc_send+0x3b>
  801a43:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a48:	eb 1e                	jmp    801a68 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a4a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a4d:	75 07                	jne    801a56 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a4f:	e8 3d e7 ff ff       	call   800191 <sys_yield>
  801a54:	eb 12                	jmp    801a68 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a56:	50                   	push   %eax
  801a57:	68 c0 21 80 00       	push   $0x8021c0
  801a5c:	6a 43                	push   $0x43
  801a5e:	68 d3 21 80 00       	push   $0x8021d3
  801a63:	e8 44 f5 ff ff       	call   800fac <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	57                   	push   %edi
  801a6b:	ff 75 08             	pushl  0x8(%ebp)
  801a6e:	e8 1b e8 ff ff       	call   80028e <sys_ipc_try_send>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	75 d0                	jne    801a4a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5f                   	pop    %edi
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a89:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801a8f:	74 22                	je     801ab3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a91:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a96:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801a9d:	89 c2                	mov    %eax,%edx
  801a9f:	c1 e2 07             	shl    $0x7,%edx
  801aa2:	29 ca                	sub    %ecx,%edx
  801aa4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aaa:	8b 52 50             	mov    0x50(%edx),%edx
  801aad:	39 da                	cmp    %ebx,%edx
  801aaf:	75 1d                	jne    801ace <ipc_find_env+0x4c>
  801ab1:	eb 05                	jmp    801ab8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ab8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801abf:	c1 e0 07             	shl    $0x7,%eax
  801ac2:	29 d0                	sub    %edx,%eax
  801ac4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ac9:	8b 40 40             	mov    0x40(%eax),%eax
  801acc:	eb 0c                	jmp    801ada <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ace:	40                   	inc    %eax
  801acf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad4:	75 c0                	jne    801a96 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ad6:	66 b8 00 00          	mov    $0x0,%ax
}
  801ada:	5b                   	pop    %ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    
  801add:	00 00                	add    %al,(%eax)
	...

00801ae0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	c1 ea 16             	shr    $0x16,%edx
  801aeb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801af2:	f6 c2 01             	test   $0x1,%dl
  801af5:	74 1e                	je     801b15 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801af7:	c1 e8 0c             	shr    $0xc,%eax
  801afa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b01:	a8 01                	test   $0x1,%al
  801b03:	74 17                	je     801b1c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b05:	c1 e8 0c             	shr    $0xc,%eax
  801b08:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b0f:	ef 
  801b10:	0f b7 c0             	movzwl %ax,%eax
  801b13:	eb 0c                	jmp    801b21 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	eb 05                	jmp    801b21 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    
	...

00801b24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	83 ec 10             	sub    $0x10,%esp
  801b2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b32:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b38:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	75 2e                	jne    801b70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b42:	39 f1                	cmp    %esi,%ecx
  801b44:	77 5a                	ja     801ba0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b46:	85 c9                	test   %ecx,%ecx
  801b48:	75 0b                	jne    801b55 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4f:	31 d2                	xor    %edx,%edx
  801b51:	f7 f1                	div    %ecx
  801b53:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b55:	31 d2                	xor    %edx,%edx
  801b57:	89 f0                	mov    %esi,%eax
  801b59:	f7 f1                	div    %ecx
  801b5b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b5d:	89 f8                	mov    %edi,%eax
  801b5f:	f7 f1                	div    %ecx
  801b61:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b63:	89 f8                	mov    %edi,%eax
  801b65:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    
  801b6e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b70:	39 f0                	cmp    %esi,%eax
  801b72:	77 1c                	ja     801b90 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b74:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801b77:	83 f7 1f             	xor    $0x1f,%edi
  801b7a:	75 3c                	jne    801bb8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801b7c:	39 f0                	cmp    %esi,%eax
  801b7e:	0f 82 90 00 00 00    	jb     801c14 <__udivdi3+0xf0>
  801b84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b87:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801b8a:	0f 86 84 00 00 00    	jbe    801c14 <__udivdi3+0xf0>
  801b90:	31 f6                	xor    %esi,%esi
  801b92:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	5e                   	pop    %esi
  801b9c:	5f                   	pop    %edi
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    
  801b9f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba0:	89 f2                	mov    %esi,%edx
  801ba2:	89 f8                	mov    %edi,%eax
  801ba4:	f7 f1                	div    %ecx
  801ba6:	89 c7                	mov    %eax,%edi
  801ba8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801baa:	89 f8                	mov    %edi,%eax
  801bac:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    
  801bb5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bb8:	89 f9                	mov    %edi,%ecx
  801bba:	d3 e0                	shl    %cl,%eax
  801bbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bbf:	b8 20 00 00 00       	mov    $0x20,%eax
  801bc4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc9:	88 c1                	mov    %al,%cl
  801bcb:	d3 ea                	shr    %cl,%edx
  801bcd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bd0:	09 ca                	or     %ecx,%edx
  801bd2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801bd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd8:	89 f9                	mov    %edi,%ecx
  801bda:	d3 e2                	shl    %cl,%edx
  801bdc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801bdf:	89 f2                	mov    %esi,%edx
  801be1:	88 c1                	mov    %al,%cl
  801be3:	d3 ea                	shr    %cl,%edx
  801be5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801be8:	89 f2                	mov    %esi,%edx
  801bea:	89 f9                	mov    %edi,%ecx
  801bec:	d3 e2                	shl    %cl,%edx
  801bee:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801bf1:	88 c1                	mov    %al,%cl
  801bf3:	d3 ee                	shr    %cl,%esi
  801bf5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801bf7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801bfa:	89 f0                	mov    %esi,%eax
  801bfc:	89 ca                	mov    %ecx,%edx
  801bfe:	f7 75 ec             	divl   -0x14(%ebp)
  801c01:	89 d1                	mov    %edx,%ecx
  801c03:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c05:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c08:	39 d1                	cmp    %edx,%ecx
  801c0a:	72 28                	jb     801c34 <__udivdi3+0x110>
  801c0c:	74 1a                	je     801c28 <__udivdi3+0x104>
  801c0e:	89 f7                	mov    %esi,%edi
  801c10:	31 f6                	xor    %esi,%esi
  801c12:	eb 80                	jmp    801b94 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c14:	31 f6                	xor    %esi,%esi
  801c16:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c1b:	89 f8                	mov    %edi,%eax
  801c1d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	5e                   	pop    %esi
  801c23:	5f                   	pop    %edi
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    
  801c26:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2b:	89 f9                	mov    %edi,%ecx
  801c2d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c2f:	39 c2                	cmp    %eax,%edx
  801c31:	73 db                	jae    801c0e <__udivdi3+0xea>
  801c33:	90                   	nop
		{
		  q0--;
  801c34:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c37:	31 f6                	xor    %esi,%esi
  801c39:	e9 56 ff ff ff       	jmp    801b94 <__udivdi3+0x70>
	...

00801c40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	83 ec 20             	sub    $0x20,%esp
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c4e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c51:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c54:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801c5d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c5f:	85 ff                	test   %edi,%edi
  801c61:	75 15                	jne    801c78 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801c63:	39 f1                	cmp    %esi,%ecx
  801c65:	0f 86 99 00 00 00    	jbe    801d04 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c6b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801c6d:	89 d0                	mov    %edx,%eax
  801c6f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801c71:	83 c4 20             	add    $0x20,%esp
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c78:	39 f7                	cmp    %esi,%edi
  801c7a:	0f 87 a4 00 00 00    	ja     801d24 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c80:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801c83:	83 f0 1f             	xor    $0x1f,%eax
  801c86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c89:	0f 84 a1 00 00 00    	je     801d30 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c8f:	89 f8                	mov    %edi,%eax
  801c91:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801c94:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c96:	bf 20 00 00 00       	mov    $0x20,%edi
  801c9b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca1:	89 f9                	mov    %edi,%ecx
  801ca3:	d3 ea                	shr    %cl,%edx
  801ca5:	09 c2                	or     %eax,%edx
  801ca7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cb0:	d3 e0                	shl    %cl,%eax
  801cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cb5:	89 f2                	mov    %esi,%edx
  801cb7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cbc:	d3 e0                	shl    %cl,%eax
  801cbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cc4:	89 f9                	mov    %edi,%ecx
  801cc6:	d3 e8                	shr    %cl,%eax
  801cc8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801cca:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ccc:	89 f2                	mov    %esi,%edx
  801cce:	f7 75 f0             	divl   -0x10(%ebp)
  801cd1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cd3:	f7 65 f4             	mull   -0xc(%ebp)
  801cd6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801cd9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cdb:	39 d6                	cmp    %edx,%esi
  801cdd:	72 71                	jb     801d50 <__umoddi3+0x110>
  801cdf:	74 7f                	je     801d60 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ce1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce4:	29 c8                	sub    %ecx,%eax
  801ce6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ce8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	89 f9                	mov    %edi,%ecx
  801cf1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801cf3:	09 d0                	or     %edx,%eax
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cfa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cfc:	83 c4 20             	add    $0x20,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    
  801d03:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d04:	85 c9                	test   %ecx,%ecx
  801d06:	75 0b                	jne    801d13 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d08:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	f7 f1                	div    %ecx
  801d11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d13:	89 f0                	mov    %esi,%eax
  801d15:	31 d2                	xor    %edx,%edx
  801d17:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1c:	f7 f1                	div    %ecx
  801d1e:	e9 4a ff ff ff       	jmp    801c6d <__umoddi3+0x2d>
  801d23:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d24:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d26:	83 c4 20             	add    $0x20,%esp
  801d29:	5e                   	pop    %esi
  801d2a:	5f                   	pop    %edi
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    
  801d2d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d30:	39 f7                	cmp    %esi,%edi
  801d32:	72 05                	jb     801d39 <__umoddi3+0xf9>
  801d34:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d37:	77 0c                	ja     801d45 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d39:	89 f2                	mov    %esi,%edx
  801d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3e:	29 c8                	sub    %ecx,%eax
  801d40:	19 fa                	sbb    %edi,%edx
  801d42:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d50:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d53:	89 c1                	mov    %eax,%ecx
  801d55:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d58:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d5b:	eb 84                	jmp    801ce1 <__umoddi3+0xa1>
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d60:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d63:	72 eb                	jb     801d50 <__umoddi3+0x110>
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	e9 75 ff ff ff       	jmp    801ce1 <__umoddi3+0xa1>
