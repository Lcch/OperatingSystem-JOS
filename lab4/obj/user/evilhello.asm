
obj/user/evilhello:     file format elf32-i386


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
  800041:	e8 b7 00 00 00       	call   8000fd <sys_cputs>
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
  800057:	e8 0d 01 00 00       	call   800169 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	29 d0                	sub    %edx,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 f6                	test   %esi,%esi
  800079:	7e 07                	jle    800082 <libmain+0x36>
		binaryname = argv[0];
  80007b:	8b 03                	mov    (%ebx),%eax
  80007d:	a3 00 20 80 00       	mov    %eax,0x802000
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
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 9e 00 00 00       	call   800147 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 1c             	sub    $0x1c,%esp
  8000b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	cd 30                	int    $0x30
  8000cf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d5:	74 1c                	je     8000f3 <syscall+0x43>
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	7e 18                	jle    8000f3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e2:	68 2a 0f 80 00       	push   $0x800f2a
  8000e7:	6a 42                	push   $0x42
  8000e9:	68 47 0f 80 00       	push   $0x800f47
  8000ee:	e8 bd 01 00 00       	call   8002b0 <_panic>

	return ret;
}
  8000f3:	89 d0                	mov    %edx,%eax
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800103:	6a 00                	push   $0x0
  800105:	6a 00                	push   $0x0
  800107:	6a 00                	push   $0x0
  800109:	ff 75 0c             	pushl  0xc(%ebp)
  80010c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010f:	ba 00 00 00 00       	mov    $0x0,%edx
  800114:	b8 00 00 00 00       	mov    $0x0,%eax
  800119:	e8 92 ff ff ff       	call   8000b0 <syscall>
  80011e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <sys_cgetc>:

int
sys_cgetc(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	b9 00 00 00 00       	mov    $0x0,%ecx
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	b8 01 00 00 00       	mov    $0x1,%eax
  800140:	e8 6b ff ff ff       	call   8000b0 <syscall>
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	ba 01 00 00 00       	mov    $0x1,%edx
  80015d:	b8 03 00 00 00       	mov    $0x3,%eax
  800162:	e8 49 ff ff ff       	call   8000b0 <syscall>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017c:	ba 00 00 00 00       	mov    $0x0,%edx
  800181:	b8 02 00 00 00       	mov    $0x2,%eax
  800186:	e8 25 ff ff ff       	call   8000b0 <syscall>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <sys_yield>:

void
sys_yield(void)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	6a 00                	push   $0x0
  800199:	6a 00                	push   $0x0
  80019b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001aa:	e8 01 ff ff ff       	call   8000b0 <syscall>
  8001af:	83 c4 10             	add    $0x10,%esp
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ba:	6a 00                	push   $0x0
  8001bc:	6a 00                	push   $0x0
  8001be:	ff 75 10             	pushl  0x10(%ebp)
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d1:	e8 da fe ff ff       	call   8000b0 <syscall>
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	ff 75 14             	pushl  0x14(%ebp)
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	e8 b4 fe ff ff       	call   8000b0 <syscall>
}
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800204:	6a 00                	push   $0x0
  800206:	6a 00                	push   $0x0
  800208:	6a 00                	push   $0x0
  80020a:	ff 75 0c             	pushl  0xc(%ebp)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	ba 01 00 00 00       	mov    $0x1,%edx
  800215:	b8 06 00 00 00       	mov    $0x6,%eax
  80021a:	e8 91 fe ff ff       	call   8000b0 <syscall>
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800227:	6a 00                	push   $0x0
  800229:	6a 00                	push   $0x0
  80022b:	6a 00                	push   $0x0
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800233:	ba 01 00 00 00       	mov    $0x1,%edx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	e8 6e fe ff ff       	call   8000b0 <syscall>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80024a:	6a 00                	push   $0x0
  80024c:	6a 00                	push   $0x0
  80024e:	6a 00                	push   $0x0
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800256:	ba 01 00 00 00       	mov    $0x1,%edx
  80025b:	b8 09 00 00 00       	mov    $0x9,%eax
  800260:	e8 4b fe ff ff       	call   8000b0 <syscall>
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 14             	pushl  0x14(%ebp)
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
  800280:	b8 0b 00 00 00       	mov    $0xb,%eax
  800285:	e8 26 fe ff ff       	call   8000b0 <syscall>
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800292:	6a 00                	push   $0x0
  800294:	6a 00                	push   $0x0
  800296:	6a 00                	push   $0x0
  800298:	6a 00                	push   $0x0
  80029a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029d:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a7:	e8 04 fe ff ff       	call   8000b0 <syscall>
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    
	...

008002b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002b5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002be:	e8 a6 fe ff ff       	call   800169 <sys_getenvid>
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	ff 75 0c             	pushl  0xc(%ebp)
  8002c9:	ff 75 08             	pushl  0x8(%ebp)
  8002cc:	53                   	push   %ebx
  8002cd:	50                   	push   %eax
  8002ce:	68 58 0f 80 00       	push   $0x800f58
  8002d3:	e8 b0 00 00 00       	call   800388 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d8:	83 c4 18             	add    $0x18,%esp
  8002db:	56                   	push   %esi
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	e8 53 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002e4:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  8002eb:	e8 98 00 00 00       	call   800388 <cprintf>
  8002f0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f3:	cc                   	int3   
  8002f4:	eb fd                	jmp    8002f3 <_panic+0x43>
	...

008002f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 04             	sub    $0x4,%esp
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800302:	8b 03                	mov    (%ebx),%eax
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030b:	40                   	inc    %eax
  80030c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800313:	75 1a                	jne    80032f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	68 ff 00 00 00       	push   $0xff
  80031d:	8d 43 08             	lea    0x8(%ebx),%eax
  800320:	50                   	push   %eax
  800321:	e8 d7 fd ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  800326:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80032c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80032f:	ff 43 04             	incl   0x4(%ebx)
}
  800332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800340:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800347:	00 00 00 
	b.cnt = 0;
  80034a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800351:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800360:	50                   	push   %eax
  800361:	68 f8 02 80 00       	push   $0x8002f8
  800366:	e8 82 01 00 00       	call   8004ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036b:	83 c4 08             	add    $0x8,%esp
  80036e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800374:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 7d fd ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
}
  800380:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800391:	50                   	push   %eax
  800392:	ff 75 08             	pushl  0x8(%ebp)
  800395:	e8 9d ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	57                   	push   %edi
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
  8003a2:	83 ec 2c             	sub    $0x2c,%esp
  8003a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a8:	89 d6                	mov    %edx,%esi
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003cc:	72 0c                	jb     8003da <printnum+0x3e>
  8003ce:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003d1:	76 07                	jbe    8003da <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d3:	4b                   	dec    %ebx
  8003d4:	85 db                	test   %ebx,%ebx
  8003d6:	7f 31                	jg     800409 <printnum+0x6d>
  8003d8:	eb 3f                	jmp    800419 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	57                   	push   %edi
  8003de:	4b                   	dec    %ebx
  8003df:	53                   	push   %ebx
  8003e0:	50                   	push   %eax
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f0:	e8 c7 08 00 00       	call   800cbc <__udivdi3>
  8003f5:	83 c4 18             	add    $0x18,%esp
  8003f8:	52                   	push   %edx
  8003f9:	50                   	push   %eax
  8003fa:	89 f2                	mov    %esi,%edx
  8003fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ff:	e8 98 ff ff ff       	call   80039c <printnum>
  800404:	83 c4 20             	add    $0x20,%esp
  800407:	eb 10                	jmp    800419 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	56                   	push   %esi
  80040d:	57                   	push   %edi
  80040e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800411:	4b                   	dec    %ebx
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	85 db                	test   %ebx,%ebx
  800417:	7f f0                	jg     800409 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	56                   	push   %esi
  80041d:	83 ec 04             	sub    $0x4,%esp
  800420:	ff 75 d4             	pushl  -0x2c(%ebp)
  800423:	ff 75 d0             	pushl  -0x30(%ebp)
  800426:	ff 75 dc             	pushl  -0x24(%ebp)
  800429:	ff 75 d8             	pushl  -0x28(%ebp)
  80042c:	e8 a7 09 00 00       	call   800dd8 <__umoddi3>
  800431:	83 c4 14             	add    $0x14,%esp
  800434:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  80043b:	50                   	push   %eax
  80043c:	ff 55 e4             	call   *-0x1c(%ebp)
  80043f:	83 c4 10             	add    $0x10,%esp
}
  800442:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800445:	5b                   	pop    %ebx
  800446:	5e                   	pop    %esi
  800447:	5f                   	pop    %edi
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80044d:	83 fa 01             	cmp    $0x1,%edx
  800450:	7e 0e                	jle    800460 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800452:	8b 10                	mov    (%eax),%edx
  800454:	8d 4a 08             	lea    0x8(%edx),%ecx
  800457:	89 08                	mov    %ecx,(%eax)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	8b 52 04             	mov    0x4(%edx),%edx
  80045e:	eb 22                	jmp    800482 <getuint+0x38>
	else if (lflag)
  800460:	85 d2                	test   %edx,%edx
  800462:	74 10                	je     800474 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800464:	8b 10                	mov    (%eax),%edx
  800466:	8d 4a 04             	lea    0x4(%edx),%ecx
  800469:	89 08                	mov    %ecx,(%eax)
  80046b:	8b 02                	mov    (%edx),%eax
  80046d:	ba 00 00 00 00       	mov    $0x0,%edx
  800472:	eb 0e                	jmp    800482 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800474:	8b 10                	mov    (%eax),%edx
  800476:	8d 4a 04             	lea    0x4(%edx),%ecx
  800479:	89 08                	mov    %ecx,(%eax)
  80047b:	8b 02                	mov    (%edx),%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800487:	83 fa 01             	cmp    $0x1,%edx
  80048a:	7e 0e                	jle    80049a <getint+0x16>
		return va_arg(*ap, long long);
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800491:	89 08                	mov    %ecx,(%eax)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	8b 52 04             	mov    0x4(%edx),%edx
  800498:	eb 1a                	jmp    8004b4 <getint+0x30>
	else if (lflag)
  80049a:	85 d2                	test   %edx,%edx
  80049c:	74 0c                	je     8004aa <getint+0x26>
		return va_arg(*ap, long);
  80049e:	8b 10                	mov    (%eax),%edx
  8004a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a3:	89 08                	mov    %ecx,(%eax)
  8004a5:	8b 02                	mov    (%edx),%eax
  8004a7:	99                   	cltd   
  8004a8:	eb 0a                	jmp    8004b4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	99                   	cltd   
}
  8004b4:	c9                   	leave  
  8004b5:	c3                   	ret    

008004b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c4:	73 08                	jae    8004ce <sprintputch+0x18>
		*b->buf++ = ch;
  8004c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c9:	88 0a                	mov    %cl,(%edx)
  8004cb:	42                   	inc    %edx
  8004cc:	89 10                	mov    %edx,(%eax)
}
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d9:	50                   	push   %eax
  8004da:	ff 75 10             	pushl  0x10(%ebp)
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	ff 75 08             	pushl  0x8(%ebp)
  8004e3:	e8 05 00 00 00       	call   8004ed <vprintfmt>
	va_end(ap);
  8004e8:	83 c4 10             	add    $0x10,%esp
}
  8004eb:	c9                   	leave  
  8004ec:	c3                   	ret    

008004ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	57                   	push   %edi
  8004f1:	56                   	push   %esi
  8004f2:	53                   	push   %ebx
  8004f3:	83 ec 2c             	sub    $0x2c,%esp
  8004f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8004fc:	eb 13                	jmp    800511 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fe:	85 c0                	test   %eax,%eax
  800500:	0f 84 6d 03 00 00    	je     800873 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	57                   	push   %edi
  80050a:	50                   	push   %eax
  80050b:	ff 55 08             	call   *0x8(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800511:	0f b6 06             	movzbl (%esi),%eax
  800514:	46                   	inc    %esi
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e4                	jne    8004fe <vprintfmt+0x11>
  80051a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80051e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800525:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80052c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 28                	jmp    800562 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800540:	eb 20                	jmp    800562 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800544:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800548:	eb 18                	jmp    800562 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80054c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800553:	eb 0d                	jmp    800562 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800555:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8a 06                	mov    (%esi),%al
  800564:	0f b6 d0             	movzbl %al,%edx
  800567:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056a:	83 e8 23             	sub    $0x23,%eax
  80056d:	3c 55                	cmp    $0x55,%al
  80056f:	0f 87 e0 02 00 00    	ja     800855 <vprintfmt+0x368>
  800575:	0f b6 c0             	movzbl %al,%eax
  800578:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057f:	83 ea 30             	sub    $0x30,%edx
  800582:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800585:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800588:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058b:	83 fa 09             	cmp    $0x9,%edx
  80058e:	77 44                	ja     8005d4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	89 de                	mov    %ebx,%esi
  800592:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800595:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800596:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800599:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80059d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005a0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005a3:	83 fb 09             	cmp    $0x9,%ebx
  8005a6:	76 ed                	jbe    800595 <vprintfmt+0xa8>
  8005a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ab:	eb 29                	jmp    8005d6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005bd:	eb 17                	jmp    8005d6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c3:	78 85                	js     80054a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	89 de                	mov    %ebx,%esi
  8005c7:	eb 99                	jmp    800562 <vprintfmt+0x75>
  8005c9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005d2:	eb 8e                	jmp    800562 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005da:	79 86                	jns    800562 <vprintfmt+0x75>
  8005dc:	e9 74 ff ff ff       	jmp    800555 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	89 de                	mov    %ebx,%esi
  8005e4:	e9 79 ff ff ff       	jmp    800562 <vprintfmt+0x75>
  8005e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	57                   	push   %edi
  8005f9:	ff 30                	pushl  (%eax)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800604:	e9 08 ff ff ff       	jmp    800511 <vprintfmt+0x24>
  800609:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	85 c0                	test   %eax,%eax
  800619:	79 02                	jns    80061d <vprintfmt+0x130>
  80061b:	f7 d8                	neg    %eax
  80061d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061f:	83 f8 08             	cmp    $0x8,%eax
  800622:	7f 0b                	jg     80062f <vprintfmt+0x142>
  800624:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80062b:	85 c0                	test   %eax,%eax
  80062d:	75 1a                	jne    800649 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80062f:	52                   	push   %edx
  800630:	68 96 0f 80 00       	push   $0x800f96
  800635:	57                   	push   %edi
  800636:	ff 75 08             	pushl  0x8(%ebp)
  800639:	e8 92 fe ff ff       	call   8004d0 <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800644:	e9 c8 fe ff ff       	jmp    800511 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800649:	50                   	push   %eax
  80064a:	68 9f 0f 80 00       	push   $0x800f9f
  80064f:	57                   	push   %edi
  800650:	ff 75 08             	pushl  0x8(%ebp)
  800653:	e8 78 fe ff ff       	call   8004d0 <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065e:	e9 ae fe ff ff       	jmp    800511 <vprintfmt+0x24>
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800666:	89 de                	mov    %ebx,%esi
  800668:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80066b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067c:	85 c0                	test   %eax,%eax
  80067e:	75 07                	jne    800687 <vprintfmt+0x19a>
				p = "(null)";
  800680:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800687:	85 db                	test   %ebx,%ebx
  800689:	7e 42                	jle    8006cd <vprintfmt+0x1e0>
  80068b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80068f:	74 3c                	je     8006cd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	51                   	push   %ecx
  800695:	ff 75 d0             	pushl  -0x30(%ebp)
  800698:	e8 6f 02 00 00       	call   80090c <strnlen>
  80069d:	29 c3                	sub    %eax,%ebx
  80069f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	85 db                	test   %ebx,%ebx
  8006a7:	7e 24                	jle    8006cd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006a9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006ad:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	57                   	push   %edi
  8006b7:	53                   	push   %ebx
  8006b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bb:	4e                   	dec    %esi
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	85 f6                	test   %esi,%esi
  8006c1:	7f f0                	jg     8006b3 <vprintfmt+0x1c6>
  8006c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d0:	0f be 02             	movsbl (%edx),%eax
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	75 47                	jne    80071e <vprintfmt+0x231>
  8006d7:	eb 37                	jmp    800710 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006dd:	74 16                	je     8006f5 <vprintfmt+0x208>
  8006df:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006e2:	83 fa 5e             	cmp    $0x5e,%edx
  8006e5:	76 0e                	jbe    8006f5 <vprintfmt+0x208>
					putch('?', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	6a 3f                	push   $0x3f
  8006ed:	ff 55 08             	call   *0x8(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 0b                	jmp    800700 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	57                   	push   %edi
  8006f9:	50                   	push   %eax
  8006fa:	ff 55 08             	call   *0x8(%ebp)
  8006fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800700:	ff 4d e4             	decl   -0x1c(%ebp)
  800703:	0f be 03             	movsbl (%ebx),%eax
  800706:	85 c0                	test   %eax,%eax
  800708:	74 03                	je     80070d <vprintfmt+0x220>
  80070a:	43                   	inc    %ebx
  80070b:	eb 1b                	jmp    800728 <vprintfmt+0x23b>
  80070d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800714:	7f 1e                	jg     800734 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800719:	e9 f3 fd ff ff       	jmp    800511 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800721:	43                   	inc    %ebx
  800722:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800725:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800728:	85 f6                	test   %esi,%esi
  80072a:	78 ad                	js     8006d9 <vprintfmt+0x1ec>
  80072c:	4e                   	dec    %esi
  80072d:	79 aa                	jns    8006d9 <vprintfmt+0x1ec>
  80072f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800732:	eb dc                	jmp    800710 <vprintfmt+0x223>
  800734:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	57                   	push   %edi
  80073b:	6a 20                	push   $0x20
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800740:	4b                   	dec    %ebx
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	85 db                	test   %ebx,%ebx
  800746:	7f ef                	jg     800737 <vprintfmt+0x24a>
  800748:	e9 c4 fd ff ff       	jmp    800511 <vprintfmt+0x24>
  80074d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800750:	89 ca                	mov    %ecx,%edx
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	e8 2a fd ff ff       	call   800484 <getint>
  80075a:	89 c3                	mov    %eax,%ebx
  80075c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80075e:	85 d2                	test   %edx,%edx
  800760:	78 0a                	js     80076c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800762:	b8 0a 00 00 00       	mov    $0xa,%eax
  800767:	e9 b0 00 00 00       	jmp    80081c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	57                   	push   %edi
  800770:	6a 2d                	push   $0x2d
  800772:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800775:	f7 db                	neg    %ebx
  800777:	83 d6 00             	adc    $0x0,%esi
  80077a:	f7 de                	neg    %esi
  80077c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	e9 93 00 00 00       	jmp    80081c <vprintfmt+0x32f>
  800789:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078c:	89 ca                	mov    %ecx,%edx
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 b4 fc ff ff       	call   80044a <getuint>
  800796:	89 c3                	mov    %eax,%ebx
  800798:	89 d6                	mov    %edx,%esi
			base = 10;
  80079a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80079f:	eb 7b                	jmp    80081c <vprintfmt+0x32f>
  8007a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007a4:	89 ca                	mov    %ecx,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 d6 fc ff ff       	call   800484 <getint>
  8007ae:	89 c3                	mov    %eax,%ebx
  8007b0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	78 07                	js     8007bd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007bb:	eb 5f                	jmp    80081c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	57                   	push   %edi
  8007c1:	6a 2d                	push   $0x2d
  8007c3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007c6:	f7 db                	neg    %ebx
  8007c8:	83 d6 00             	adc    $0x0,%esi
  8007cb:	f7 de                	neg    %esi
  8007cd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d5:	eb 45                	jmp    80081c <vprintfmt+0x32f>
  8007d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	57                   	push   %edi
  8007de:	6a 30                	push   $0x30
  8007e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e3:	83 c4 08             	add    $0x8,%esp
  8007e6:	57                   	push   %edi
  8007e7:	6a 78                	push   $0x78
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 04             	lea    0x4(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f5:	8b 18                	mov    (%eax),%ebx
  8007f7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800804:	eb 16                	jmp    80081c <vprintfmt+0x32f>
  800806:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800809:	89 ca                	mov    %ecx,%edx
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	e8 37 fc ff ff       	call   80044a <getuint>
  800813:	89 c3                	mov    %eax,%ebx
  800815:	89 d6                	mov    %edx,%esi
			base = 16;
  800817:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081c:	83 ec 0c             	sub    $0xc,%esp
  80081f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800823:	52                   	push   %edx
  800824:	ff 75 e4             	pushl  -0x1c(%ebp)
  800827:	50                   	push   %eax
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	89 fa                	mov    %edi,%edx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	e8 68 fb ff ff       	call   80039c <printnum>
			break;
  800834:	83 c4 20             	add    $0x20,%esp
  800837:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80083a:	e9 d2 fc ff ff       	jmp    800511 <vprintfmt+0x24>
  80083f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	57                   	push   %edi
  800846:	52                   	push   %edx
  800847:	ff 55 08             	call   *0x8(%ebp)
			break;
  80084a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800850:	e9 bc fc ff ff       	jmp    800511 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	57                   	push   %edi
  800859:	6a 25                	push   $0x25
  80085b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	eb 02                	jmp    800865 <vprintfmt+0x378>
  800863:	89 c6                	mov    %eax,%esi
  800865:	8d 46 ff             	lea    -0x1(%esi),%eax
  800868:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80086c:	75 f5                	jne    800863 <vprintfmt+0x376>
  80086e:	e9 9e fc ff ff       	jmp    800511 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800873:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 18             	sub    $0x18,%esp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800887:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800891:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800898:	85 c0                	test   %eax,%eax
  80089a:	74 26                	je     8008c2 <vsnprintf+0x47>
  80089c:	85 d2                	test   %edx,%edx
  80089e:	7e 29                	jle    8008c9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a0:	ff 75 14             	pushl  0x14(%ebp)
  8008a3:	ff 75 10             	pushl  0x10(%ebp)
  8008a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	68 b6 04 80 00       	push   $0x8004b6
  8008af:	e8 39 fc ff ff       	call   8004ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	eb 0c                	jmp    8008ce <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c7:	eb 05                	jmp    8008ce <vsnprintf+0x53>
  8008c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d9:	50                   	push   %eax
  8008da:	ff 75 10             	pushl  0x10(%ebp)
  8008dd:	ff 75 0c             	pushl  0xc(%ebp)
  8008e0:	ff 75 08             	pushl  0x8(%ebp)
  8008e3:	e8 93 ff ff ff       	call   80087b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    
	...

008008ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f2:	80 3a 00             	cmpb   $0x0,(%edx)
  8008f5:	74 0e                	je     800905 <strlen+0x19>
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008fc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800901:	75 f9                	jne    8008fc <strlen+0x10>
  800903:	eb 05                	jmp    80090a <strlen+0x1e>
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800915:	85 d2                	test   %edx,%edx
  800917:	74 17                	je     800930 <strnlen+0x24>
  800919:	80 39 00             	cmpb   $0x0,(%ecx)
  80091c:	74 19                	je     800937 <strnlen+0x2b>
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800923:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800924:	39 d0                	cmp    %edx,%eax
  800926:	74 14                	je     80093c <strnlen+0x30>
  800928:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092c:	75 f5                	jne    800923 <strnlen+0x17>
  80092e:	eb 0c                	jmp    80093c <strnlen+0x30>
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
  800935:	eb 05                	jmp    80093c <strnlen+0x30>
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800950:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800953:	42                   	inc    %edx
  800954:	84 c9                	test   %cl,%cl
  800956:	75 f5                	jne    80094d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800958:	5b                   	pop    %ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	53                   	push   %ebx
  800963:	e8 84 ff ff ff       	call   8008ec <strlen>
  800968:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800971:	50                   	push   %eax
  800972:	e8 c7 ff ff ff       	call   80093e <strcpy>
	return dst;
}
  800977:	89 d8                	mov    %ebx,%eax
  800979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098c:	85 f6                	test   %esi,%esi
  80098e:	74 15                	je     8009a5 <strncpy+0x27>
  800990:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800995:	8a 1a                	mov    (%edx),%bl
  800997:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099a:	80 3a 01             	cmpb   $0x1,(%edx)
  80099d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a0:	41                   	inc    %ecx
  8009a1:	39 ce                	cmp    %ecx,%esi
  8009a3:	77 f0                	ja     800995 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b8:	85 f6                	test   %esi,%esi
  8009ba:	74 32                	je     8009ee <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009bc:	83 fe 01             	cmp    $0x1,%esi
  8009bf:	74 22                	je     8009e3 <strlcpy+0x3a>
  8009c1:	8a 0b                	mov    (%ebx),%cl
  8009c3:	84 c9                	test   %cl,%cl
  8009c5:	74 20                	je     8009e7 <strlcpy+0x3e>
  8009c7:	89 f8                	mov    %edi,%eax
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009ce:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d1:	88 08                	mov    %cl,(%eax)
  8009d3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d4:	39 f2                	cmp    %esi,%edx
  8009d6:	74 11                	je     8009e9 <strlcpy+0x40>
  8009d8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009dc:	42                   	inc    %edx
  8009dd:	84 c9                	test   %cl,%cl
  8009df:	75 f0                	jne    8009d1 <strlcpy+0x28>
  8009e1:	eb 06                	jmp    8009e9 <strlcpy+0x40>
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	eb 02                	jmp    8009e9 <strlcpy+0x40>
  8009e7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e9:	c6 00 00             	movb   $0x0,(%eax)
  8009ec:	eb 02                	jmp    8009f0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ee:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009f0:	29 f8                	sub    %edi,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a00:	8a 01                	mov    (%ecx),%al
  800a02:	84 c0                	test   %al,%al
  800a04:	74 10                	je     800a16 <strcmp+0x1f>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	75 0c                	jne    800a16 <strcmp+0x1f>
		p++, q++;
  800a0a:	41                   	inc    %ecx
  800a0b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0c:	8a 01                	mov    (%ecx),%al
  800a0e:	84 c0                	test   %al,%al
  800a10:	74 04                	je     800a16 <strcmp+0x1f>
  800a12:	3a 02                	cmp    (%edx),%al
  800a14:	74 f4                	je     800a0a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 12             	movzbl (%edx),%edx
  800a1c:	29 d0                	sub    %edx,%eax
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	53                   	push   %ebx
  800a24:	8b 55 08             	mov    0x8(%ebp),%edx
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	74 1b                	je     800a4c <strncmp+0x2c>
  800a31:	8a 1a                	mov    (%edx),%bl
  800a33:	84 db                	test   %bl,%bl
  800a35:	74 24                	je     800a5b <strncmp+0x3b>
  800a37:	3a 19                	cmp    (%ecx),%bl
  800a39:	75 20                	jne    800a5b <strncmp+0x3b>
  800a3b:	48                   	dec    %eax
  800a3c:	74 15                	je     800a53 <strncmp+0x33>
		n--, p++, q++;
  800a3e:	42                   	inc    %edx
  800a3f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a40:	8a 1a                	mov    (%edx),%bl
  800a42:	84 db                	test   %bl,%bl
  800a44:	74 15                	je     800a5b <strncmp+0x3b>
  800a46:	3a 19                	cmp    (%ecx),%bl
  800a48:	74 f1                	je     800a3b <strncmp+0x1b>
  800a4a:	eb 0f                	jmp    800a5b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strncmp+0x38>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a58:	5b                   	pop    %ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5b:	0f b6 02             	movzbl (%edx),%eax
  800a5e:	0f b6 11             	movzbl (%ecx),%edx
  800a61:	29 d0                	sub    %edx,%eax
  800a63:	eb f3                	jmp    800a58 <strncmp+0x38>

00800a65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6e:	8a 10                	mov    (%eax),%dl
  800a70:	84 d2                	test   %dl,%dl
  800a72:	74 18                	je     800a8c <strchr+0x27>
		if (*s == c)
  800a74:	38 ca                	cmp    %cl,%dl
  800a76:	75 06                	jne    800a7e <strchr+0x19>
  800a78:	eb 17                	jmp    800a91 <strchr+0x2c>
  800a7a:	38 ca                	cmp    %cl,%dl
  800a7c:	74 13                	je     800a91 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7e:	40                   	inc    %eax
  800a7f:	8a 10                	mov    (%eax),%dl
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f5                	jne    800a7a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8a:	eb 05                	jmp    800a91 <strchr+0x2c>
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a9c:	8a 10                	mov    (%eax),%dl
  800a9e:	84 d2                	test   %dl,%dl
  800aa0:	74 11                	je     800ab3 <strfind+0x20>
		if (*s == c)
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	75 06                	jne    800aac <strfind+0x19>
  800aa6:	eb 0b                	jmp    800ab3 <strfind+0x20>
  800aa8:	38 ca                	cmp    %cl,%dl
  800aaa:	74 07                	je     800ab3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aac:	40                   	inc    %eax
  800aad:	8a 10                	mov    (%eax),%dl
  800aaf:	84 d2                	test   %dl,%dl
  800ab1:	75 f5                	jne    800aa8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac4:	85 c9                	test   %ecx,%ecx
  800ac6:	74 30                	je     800af8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ace:	75 25                	jne    800af5 <memset+0x40>
  800ad0:	f6 c1 03             	test   $0x3,%cl
  800ad3:	75 20                	jne    800af5 <memset+0x40>
		c &= 0xFF;
  800ad5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 d0                	or     %edx,%eax
  800aeb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aed:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af0:	fc                   	cld    
  800af1:	f3 ab                	rep stos %eax,%es:(%edi)
  800af3:	eb 03                	jmp    800af8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af5:	fc                   	cld    
  800af6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af8:	89 f8                	mov    %edi,%eax
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0d:	39 c6                	cmp    %eax,%esi
  800b0f:	73 34                	jae    800b45 <memmove+0x46>
  800b11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 2d                	jae    800b45 <memmove+0x46>
		s += n;
		d += n;
  800b18:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1b:	f6 c2 03             	test   $0x3,%dl
  800b1e:	75 1b                	jne    800b3b <memmove+0x3c>
  800b20:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b26:	75 13                	jne    800b3b <memmove+0x3c>
  800b28:	f6 c1 03             	test   $0x3,%cl
  800b2b:	75 0e                	jne    800b3b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b2d:	83 ef 04             	sub    $0x4,%edi
  800b30:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b33:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b36:	fd                   	std    
  800b37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b39:	eb 07                	jmp    800b42 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3b:	4f                   	dec    %edi
  800b3c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3f:	fd                   	std    
  800b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b42:	fc                   	cld    
  800b43:	eb 20                	jmp    800b65 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4b:	75 13                	jne    800b60 <memmove+0x61>
  800b4d:	a8 03                	test   $0x3,%al
  800b4f:	75 0f                	jne    800b60 <memmove+0x61>
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 0a                	jne    800b60 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b56:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	fc                   	cld    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 05                	jmp    800b65 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b60:	89 c7                	mov    %eax,%edi
  800b62:	fc                   	cld    
  800b63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6c:	ff 75 10             	pushl  0x10(%ebp)
  800b6f:	ff 75 0c             	pushl  0xc(%ebp)
  800b72:	ff 75 08             	pushl  0x8(%ebp)
  800b75:	e8 85 ff ff ff       	call   800aff <memmove>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8b:	85 ff                	test   %edi,%edi
  800b8d:	74 32                	je     800bc1 <memcmp+0x45>
		if (*s1 != *s2)
  800b8f:	8a 03                	mov    (%ebx),%al
  800b91:	8a 0e                	mov    (%esi),%cl
  800b93:	38 c8                	cmp    %cl,%al
  800b95:	74 19                	je     800bb0 <memcmp+0x34>
  800b97:	eb 0d                	jmp    800ba6 <memcmp+0x2a>
  800b99:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b9d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800ba1:	42                   	inc    %edx
  800ba2:	38 c8                	cmp    %cl,%al
  800ba4:	74 10                	je     800bb6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800ba6:	0f b6 c0             	movzbl %al,%eax
  800ba9:	0f b6 c9             	movzbl %cl,%ecx
  800bac:	29 c8                	sub    %ecx,%eax
  800bae:	eb 16                	jmp    800bc6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb0:	4f                   	dec    %edi
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	39 fa                	cmp    %edi,%edx
  800bb8:	75 df                	jne    800b99 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	eb 05                	jmp    800bc6 <memcmp+0x4a>
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd6:	39 d0                	cmp    %edx,%eax
  800bd8:	73 12                	jae    800bec <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bdd:	38 08                	cmp    %cl,(%eax)
  800bdf:	75 06                	jne    800be7 <memfind+0x1c>
  800be1:	eb 09                	jmp    800bec <memfind+0x21>
  800be3:	38 08                	cmp    %cl,(%eax)
  800be5:	74 05                	je     800bec <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be7:	40                   	inc    %eax
  800be8:	39 c2                	cmp    %eax,%edx
  800bea:	77 f7                	ja     800be3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	eb 01                	jmp    800bfd <strtol+0xf>
		s++;
  800bfc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfd:	8a 02                	mov    (%edx),%al
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f9                	je     800bfc <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f5                	je     800bfc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 08                	jne    800c13 <strtol+0x25>
		s++;
  800c0b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c11:	eb 13                	jmp    800c26 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c13:	3c 2d                	cmp    $0x2d,%al
  800c15:	75 0a                	jne    800c21 <strtol+0x33>
		s++, neg = 1;
  800c17:	8d 52 01             	lea    0x1(%edx),%edx
  800c1a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1f:	eb 05                	jmp    800c26 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	85 db                	test   %ebx,%ebx
  800c28:	74 05                	je     800c2f <strtol+0x41>
  800c2a:	83 fb 10             	cmp    $0x10,%ebx
  800c2d:	75 28                	jne    800c57 <strtol+0x69>
  800c2f:	8a 02                	mov    (%edx),%al
  800c31:	3c 30                	cmp    $0x30,%al
  800c33:	75 10                	jne    800c45 <strtol+0x57>
  800c35:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c39:	75 0a                	jne    800c45 <strtol+0x57>
		s += 2, base = 16;
  800c3b:	83 c2 02             	add    $0x2,%edx
  800c3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c43:	eb 12                	jmp    800c57 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c45:	85 db                	test   %ebx,%ebx
  800c47:	75 0e                	jne    800c57 <strtol+0x69>
  800c49:	3c 30                	cmp    $0x30,%al
  800c4b:	75 05                	jne    800c52 <strtol+0x64>
		s++, base = 8;
  800c4d:	42                   	inc    %edx
  800c4e:	b3 08                	mov    $0x8,%bl
  800c50:	eb 05                	jmp    800c57 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5e:	8a 0a                	mov    (%edx),%cl
  800c60:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c63:	80 fb 09             	cmp    $0x9,%bl
  800c66:	77 08                	ja     800c70 <strtol+0x82>
			dig = *s - '0';
  800c68:	0f be c9             	movsbl %cl,%ecx
  800c6b:	83 e9 30             	sub    $0x30,%ecx
  800c6e:	eb 1e                	jmp    800c8e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c70:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 08                	ja     800c80 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c78:	0f be c9             	movsbl %cl,%ecx
  800c7b:	83 e9 57             	sub    $0x57,%ecx
  800c7e:	eb 0e                	jmp    800c8e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c80:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c83:	80 fb 19             	cmp    $0x19,%bl
  800c86:	77 13                	ja     800c9b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c88:	0f be c9             	movsbl %cl,%ecx
  800c8b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8e:	39 f1                	cmp    %esi,%ecx
  800c90:	7d 0d                	jge    800c9f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c92:	42                   	inc    %edx
  800c93:	0f af c6             	imul   %esi,%eax
  800c96:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c99:	eb c3                	jmp    800c5e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c9b:	89 c1                	mov    %eax,%ecx
  800c9d:	eb 02                	jmp    800ca1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ca1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca5:	74 05                	je     800cac <strtol+0xbe>
		*endptr = (char *) s;
  800ca7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800caa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cac:	85 ff                	test   %edi,%edi
  800cae:	74 04                	je     800cb4 <strtol+0xc6>
  800cb0:	89 c8                	mov    %ecx,%eax
  800cb2:	f7 d8                	neg    %eax
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    
  800cb9:	00 00                	add    %al,(%eax)
	...

00800cbc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	83 ec 10             	sub    $0x10,%esp
  800cc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cca:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ccd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cd0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cd3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	75 2e                	jne    800d08 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cda:	39 f1                	cmp    %esi,%ecx
  800cdc:	77 5a                	ja     800d38 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cde:	85 c9                	test   %ecx,%ecx
  800ce0:	75 0b                	jne    800ced <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce7:	31 d2                	xor    %edx,%edx
  800ce9:	f7 f1                	div    %ecx
  800ceb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ced:	31 d2                	xor    %edx,%edx
  800cef:	89 f0                	mov    %esi,%eax
  800cf1:	f7 f1                	div    %ecx
  800cf3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf5:	89 f8                	mov    %edi,%eax
  800cf7:	f7 f1                	div    %ecx
  800cf9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cfb:	89 f8                	mov    %edi,%eax
  800cfd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cff:	83 c4 10             	add    $0x10,%esp
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    
  800d06:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d08:	39 f0                	cmp    %esi,%eax
  800d0a:	77 1c                	ja     800d28 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d0c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d0f:	83 f7 1f             	xor    $0x1f,%edi
  800d12:	75 3c                	jne    800d50 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d14:	39 f0                	cmp    %esi,%eax
  800d16:	0f 82 90 00 00 00    	jb     800dac <__udivdi3+0xf0>
  800d1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d1f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d22:	0f 86 84 00 00 00    	jbe    800dac <__udivdi3+0xf0>
  800d28:	31 f6                	xor    %esi,%esi
  800d2a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d2c:	89 f8                	mov    %edi,%eax
  800d2e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    
  800d37:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	89 f8                	mov    %edi,%eax
  800d3c:	f7 f1                	div    %ecx
  800d3e:	89 c7                	mov    %eax,%edi
  800d40:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d42:	89 f8                	mov    %edi,%eax
  800d44:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d50:	89 f9                	mov    %edi,%ecx
  800d52:	d3 e0                	shl    %cl,%eax
  800d54:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d57:	b8 20 00 00 00       	mov    $0x20,%eax
  800d5c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d61:	88 c1                	mov    %al,%cl
  800d63:	d3 ea                	shr    %cl,%edx
  800d65:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d68:	09 ca                	or     %ecx,%edx
  800d6a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d70:	89 f9                	mov    %edi,%ecx
  800d72:	d3 e2                	shl    %cl,%edx
  800d74:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d77:	89 f2                	mov    %esi,%edx
  800d79:	88 c1                	mov    %al,%cl
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d80:	89 f2                	mov    %esi,%edx
  800d82:	89 f9                	mov    %edi,%ecx
  800d84:	d3 e2                	shl    %cl,%edx
  800d86:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d89:	88 c1                	mov    %al,%cl
  800d8b:	d3 ee                	shr    %cl,%esi
  800d8d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d8f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d92:	89 f0                	mov    %esi,%eax
  800d94:	89 ca                	mov    %ecx,%edx
  800d96:	f7 75 ec             	divl   -0x14(%ebp)
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d9d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da0:	39 d1                	cmp    %edx,%ecx
  800da2:	72 28                	jb     800dcc <__udivdi3+0x110>
  800da4:	74 1a                	je     800dc0 <__udivdi3+0x104>
  800da6:	89 f7                	mov    %esi,%edi
  800da8:	31 f6                	xor    %esi,%esi
  800daa:	eb 80                	jmp    800d2c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dac:	31 f6                	xor    %esi,%esi
  800dae:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db3:	89 f8                	mov    %edi,%eax
  800db5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    
  800dbe:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dc3:	89 f9                	mov    %edi,%ecx
  800dc5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc7:	39 c2                	cmp    %eax,%edx
  800dc9:	73 db                	jae    800da6 <__udivdi3+0xea>
  800dcb:	90                   	nop
		{
		  q0--;
  800dcc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dcf:	31 f6                	xor    %esi,%esi
  800dd1:	e9 56 ff ff ff       	jmp    800d2c <__udivdi3+0x70>
	...

00800dd8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	83 ec 20             	sub    $0x20,%esp
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800de6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800de9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800dec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800def:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800df2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800df5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df7:	85 ff                	test   %edi,%edi
  800df9:	75 15                	jne    800e10 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800dfb:	39 f1                	cmp    %esi,%ecx
  800dfd:	0f 86 99 00 00 00    	jbe    800e9c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e03:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e05:	89 d0                	mov    %edx,%eax
  800e07:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e09:	83 c4 20             	add    $0x20,%esp
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e10:	39 f7                	cmp    %esi,%edi
  800e12:	0f 87 a4 00 00 00    	ja     800ebc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e18:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e1b:	83 f0 1f             	xor    $0x1f,%eax
  800e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e21:	0f 84 a1 00 00 00    	je     800ec8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e27:	89 f8                	mov    %edi,%eax
  800e29:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e2c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e2e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e33:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e39:	89 f9                	mov    %edi,%ecx
  800e3b:	d3 ea                	shr    %cl,%edx
  800e3d:	09 c2                	or     %eax,%edx
  800e3f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e45:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e48:	d3 e0                	shl    %cl,%eax
  800e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e4d:	89 f2                	mov    %esi,%edx
  800e4f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e51:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e54:	d3 e0                	shl    %cl,%eax
  800e56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e5c:	89 f9                	mov    %edi,%ecx
  800e5e:	d3 e8                	shr    %cl,%eax
  800e60:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e62:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e64:	89 f2                	mov    %esi,%edx
  800e66:	f7 75 f0             	divl   -0x10(%ebp)
  800e69:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e6b:	f7 65 f4             	mull   -0xc(%ebp)
  800e6e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e71:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e73:	39 d6                	cmp    %edx,%esi
  800e75:	72 71                	jb     800ee8 <__umoddi3+0x110>
  800e77:	74 7f                	je     800ef8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e7c:	29 c8                	sub    %ecx,%eax
  800e7e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e80:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e83:	d3 e8                	shr    %cl,%eax
  800e85:	89 f2                	mov    %esi,%edx
  800e87:	89 f9                	mov    %edi,%ecx
  800e89:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e8b:	09 d0                	or     %edx,%eax
  800e8d:	89 f2                	mov    %esi,%edx
  800e8f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e92:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e94:	83 c4 20             	add    $0x20,%esp
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    
  800e9b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e9c:	85 c9                	test   %ecx,%ecx
  800e9e:	75 0b                	jne    800eab <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea5:	31 d2                	xor    %edx,%edx
  800ea7:	f7 f1                	div    %ecx
  800ea9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eab:	89 f0                	mov    %esi,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb4:	f7 f1                	div    %ecx
  800eb6:	e9 4a ff ff ff       	jmp    800e05 <__umoddi3+0x2d>
  800ebb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ebc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ebe:	83 c4 20             	add    $0x20,%esp
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	c9                   	leave  
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec8:	39 f7                	cmp    %esi,%edi
  800eca:	72 05                	jb     800ed1 <__umoddi3+0xf9>
  800ecc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ecf:	77 0c                	ja     800edd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed1:	89 f2                	mov    %esi,%edx
  800ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed6:	29 c8                	sub    %ecx,%eax
  800ed8:	19 fa                	sbb    %edi,%edx
  800eda:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ee8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ef0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ef3:	eb 84                	jmp    800e79 <__umoddi3+0xa1>
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ef8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800efb:	72 eb                	jb     800ee8 <__umoddi3+0x110>
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	e9 75 ff ff ff       	jmp    800e79 <__umoddi3+0xa1>
