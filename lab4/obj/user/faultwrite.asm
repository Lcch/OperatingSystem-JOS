
obj/user/faultwrite:     file format elf32-i386


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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
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
  80004f:	e8 05 01 00 00       	call   800159 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	c1 e0 07             	shl    $0x7,%eax
  80005c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800061:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 f6                	test   %esi,%esi
  800068:	7e 07                	jle    800071 <libmain+0x2d>
		binaryname = argv[0];
  80006a:	8b 03                	mov    (%ebx),%eax
  80006c:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	53                   	push   %ebx
  800075:	56                   	push   %esi
  800076:	e8 b9 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007b:	e8 0c 00 00 00       	call   80008c <exit>
  800080:	83 c4 10             	add    $0x10,%esp
}
  800083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	c9                   	leave  
  800089:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 9e 00 00 00       	call   800137 <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 1c             	sub    $0x1c,%esp
  8000a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000af:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	cd 30                	int    $0x30
  8000bf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c5:	74 1c                	je     8000e3 <syscall+0x43>
  8000c7:	85 c0                	test   %eax,%eax
  8000c9:	7e 18                	jle    8000e3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cb:	83 ec 0c             	sub    $0xc,%esp
  8000ce:	50                   	push   %eax
  8000cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000d2:	68 2a 0f 80 00       	push   $0x800f2a
  8000d7:	6a 42                	push   $0x42
  8000d9:	68 47 0f 80 00       	push   $0x800f47
  8000de:	e8 e1 01 00 00       	call   8002c4 <_panic>

	return ret;
}
  8000e3:	89 d0                	mov    %edx,%eax
  8000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	c9                   	leave  
  8000ec:	c3                   	ret    

008000ed <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	6a 00                	push   $0x0
  8000f9:	ff 75 0c             	pushl  0xc(%ebp)
  8000fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	e8 92 ff ff ff       	call   8000a0 <syscall>
  80010e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800111:	c9                   	leave  
  800112:	c3                   	ret    

00800113 <sys_cgetc>:

int
sys_cgetc(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	b9 00 00 00 00       	mov    $0x0,%ecx
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 01 00 00 00       	mov    $0x1,%eax
  800130:	e8 6b ff ff ff       	call   8000a0 <syscall>
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800148:	ba 01 00 00 00       	mov    $0x1,%edx
  80014d:	b8 03 00 00 00       	mov    $0x3,%eax
  800152:	e8 49 ff ff ff       	call   8000a0 <syscall>
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 02 00 00 00       	mov    $0x2,%eax
  800176:	e8 25 ff ff ff       	call   8000a0 <syscall>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <sys_yield>:

void
sys_yield(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019a:	e8 01 ff ff ff       	call   8000a0 <syscall>
  80019f:	83 c4 10             	add    $0x10,%esp
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001aa:	6a 00                	push   $0x0
  8001ac:	6a 00                	push   $0x0
  8001ae:	ff 75 10             	pushl  0x10(%ebp)
  8001b1:	ff 75 0c             	pushl  0xc(%ebp)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8001bc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c1:	e8 da fe ff ff       	call   8000a0 <syscall>
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ce:	ff 75 18             	pushl  0x18(%ebp)
  8001d1:	ff 75 14             	pushl  0x14(%ebp)
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dd:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	e8 b4 fe ff ff       	call   8000a0 <syscall>
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f4:	6a 00                	push   $0x0
  8001f6:	6a 00                	push   $0x0
  8001f8:	6a 00                	push   $0x0
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800200:	ba 01 00 00 00       	mov    $0x1,%edx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	e8 91 fe ff ff       	call   8000a0 <syscall>
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800217:	6a 00                	push   $0x0
  800219:	6a 00                	push   $0x0
  80021b:	6a 00                	push   $0x0
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800223:	ba 01 00 00 00       	mov    $0x1,%edx
  800228:	b8 08 00 00 00       	mov    $0x8,%eax
  80022d:	e8 6e fe ff ff       	call   8000a0 <syscall>
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80023a:	6a 00                	push   $0x0
  80023c:	6a 00                	push   $0x0
  80023e:	6a 00                	push   $0x0
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800246:	ba 01 00 00 00       	mov    $0x1,%edx
  80024b:	b8 09 00 00 00       	mov    $0x9,%eax
  800250:	e8 4b fe ff ff       	call   8000a0 <syscall>
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80025d:	6a 00                	push   $0x0
  80025f:	ff 75 14             	pushl  0x14(%ebp)
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	ff 75 0c             	pushl  0xc(%ebp)
  800268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	b8 0b 00 00 00       	mov    $0xb,%eax
  800275:	e8 26 fe ff ff       	call   8000a0 <syscall>
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800282:	6a 00                	push   $0x0
  800284:	6a 00                	push   $0x0
  800286:	6a 00                	push   $0x0
  800288:	6a 00                	push   $0x0
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	ba 01 00 00 00       	mov    $0x1,%edx
  800292:	b8 0c 00 00 00       	mov    $0xc,%eax
  800297:	e8 04 fe ff ff       	call   8000a0 <syscall>
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002a4:	6a 00                	push   $0x0
  8002a6:	6a 00                	push   $0x0
  8002a8:	6a 00                	push   $0x0
  8002aa:	ff 75 0c             	pushl  0xc(%ebp)
  8002ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ba:	e8 e1 fd ff ff       	call   8000a0 <syscall>
}
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    
  8002c1:	00 00                	add    %al,(%eax)
	...

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002d2:	e8 82 fe ff ff       	call   800159 <sys_getenvid>
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	53                   	push   %ebx
  8002e1:	50                   	push   %eax
  8002e2:	68 58 0f 80 00       	push   $0x800f58
  8002e7:	e8 b0 00 00 00       	call   80039c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	56                   	push   %esi
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	e8 53 00 00 00       	call   80034b <vcprintf>
	cprintf("\n");
  8002f8:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  8002ff:	e8 98 00 00 00       	call   80039c <cprintf>
  800304:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800307:	cc                   	int3   
  800308:	eb fd                	jmp    800307 <_panic+0x43>
	...

0080030c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	53                   	push   %ebx
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800316:	8b 03                	mov    (%ebx),%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80031f:	40                   	inc    %eax
  800320:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800322:	3d ff 00 00 00       	cmp    $0xff,%eax
  800327:	75 1a                	jne    800343 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	68 ff 00 00 00       	push   $0xff
  800331:	8d 43 08             	lea    0x8(%ebx),%eax
  800334:	50                   	push   %eax
  800335:	e8 b3 fd ff ff       	call   8000ed <sys_cputs>
		b->idx = 0;
  80033a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800340:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800343:	ff 43 04             	incl   0x4(%ebx)
}
  800346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800354:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035b:	00 00 00 
	b.cnt = 0;
  80035e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800365:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800368:	ff 75 0c             	pushl  0xc(%ebp)
  80036b:	ff 75 08             	pushl  0x8(%ebp)
  80036e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800374:	50                   	push   %eax
  800375:	68 0c 03 80 00       	push   $0x80030c
  80037a:	e8 82 01 00 00       	call   800501 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037f:	83 c4 08             	add    $0x8,%esp
  800382:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800388:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80038e:	50                   	push   %eax
  80038f:	e8 59 fd ff ff       	call   8000ed <sys_cputs>

	return b.cnt;
}
  800394:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a5:	50                   	push   %eax
  8003a6:	ff 75 08             	pushl  0x8(%ebp)
  8003a9:	e8 9d ff ff ff       	call   80034b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	57                   	push   %edi
  8003b4:	56                   	push   %esi
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 2c             	sub    $0x2c,%esp
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	89 d6                	mov    %edx,%esi
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003dd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003e0:	72 0c                	jb     8003ee <printnum+0x3e>
  8003e2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003e5:	76 07                	jbe    8003ee <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e7:	4b                   	dec    %ebx
  8003e8:	85 db                	test   %ebx,%ebx
  8003ea:	7f 31                	jg     80041d <printnum+0x6d>
  8003ec:	eb 3f                	jmp    80042d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ee:	83 ec 0c             	sub    $0xc,%esp
  8003f1:	57                   	push   %edi
  8003f2:	4b                   	dec    %ebx
  8003f3:	53                   	push   %ebx
  8003f4:	50                   	push   %eax
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800401:	ff 75 d8             	pushl  -0x28(%ebp)
  800404:	e8 c7 08 00 00       	call   800cd0 <__udivdi3>
  800409:	83 c4 18             	add    $0x18,%esp
  80040c:	52                   	push   %edx
  80040d:	50                   	push   %eax
  80040e:	89 f2                	mov    %esi,%edx
  800410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800413:	e8 98 ff ff ff       	call   8003b0 <printnum>
  800418:	83 c4 20             	add    $0x20,%esp
  80041b:	eb 10                	jmp    80042d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	57                   	push   %edi
  800422:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800425:	4b                   	dec    %ebx
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 db                	test   %ebx,%ebx
  80042b:	7f f0                	jg     80041d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	56                   	push   %esi
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	ff 75 d4             	pushl  -0x2c(%ebp)
  800437:	ff 75 d0             	pushl  -0x30(%ebp)
  80043a:	ff 75 dc             	pushl  -0x24(%ebp)
  80043d:	ff 75 d8             	pushl  -0x28(%ebp)
  800440:	e8 a7 09 00 00       	call   800dec <__umoddi3>
  800445:	83 c4 14             	add    $0x14,%esp
  800448:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  80044f:	50                   	push   %eax
  800450:	ff 55 e4             	call   *-0x1c(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
}
  800456:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800459:	5b                   	pop    %ebx
  80045a:	5e                   	pop    %esi
  80045b:	5f                   	pop    %edi
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800461:	83 fa 01             	cmp    $0x1,%edx
  800464:	7e 0e                	jle    800474 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800466:	8b 10                	mov    (%eax),%edx
  800468:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046b:	89 08                	mov    %ecx,(%eax)
  80046d:	8b 02                	mov    (%edx),%eax
  80046f:	8b 52 04             	mov    0x4(%edx),%edx
  800472:	eb 22                	jmp    800496 <getuint+0x38>
	else if (lflag)
  800474:	85 d2                	test   %edx,%edx
  800476:	74 10                	je     800488 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 02                	mov    (%edx),%eax
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	eb 0e                	jmp    800496 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049b:	83 fa 01             	cmp    $0x1,%edx
  80049e:	7e 0e                	jle    8004ae <getint+0x16>
		return va_arg(*ap, long long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	8b 52 04             	mov    0x4(%edx),%edx
  8004ac:	eb 1a                	jmp    8004c8 <getint+0x30>
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 0c                	je     8004be <getint+0x26>
		return va_arg(*ap, long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	99                   	cltd   
  8004bc:	eb 0a                	jmp    8004c8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	99                   	cltd   
}
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    

008004ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d8:	73 08                	jae    8004e2 <sprintputch+0x18>
		*b->buf++ = ch;
  8004da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004dd:	88 0a                	mov    %cl,(%edx)
  8004df:	42                   	inc    %edx
  8004e0:	89 10                	mov    %edx,(%eax)
}
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ed:	50                   	push   %eax
  8004ee:	ff 75 10             	pushl  0x10(%ebp)
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	ff 75 08             	pushl  0x8(%ebp)
  8004f7:	e8 05 00 00 00       	call   800501 <vprintfmt>
	va_end(ap);
  8004fc:	83 c4 10             	add    $0x10,%esp
}
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    

00800501 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	57                   	push   %edi
  800505:	56                   	push   %esi
  800506:	53                   	push   %ebx
  800507:	83 ec 2c             	sub    $0x2c,%esp
  80050a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050d:	8b 75 10             	mov    0x10(%ebp),%esi
  800510:	eb 13                	jmp    800525 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800512:	85 c0                	test   %eax,%eax
  800514:	0f 84 6d 03 00 00    	je     800887 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	57                   	push   %edi
  80051e:	50                   	push   %eax
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800525:	0f b6 06             	movzbl (%esi),%eax
  800528:	46                   	inc    %esi
  800529:	83 f8 25             	cmp    $0x25,%eax
  80052c:	75 e4                	jne    800512 <vprintfmt+0x11>
  80052e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800532:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800539:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800540:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800547:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054c:	eb 28                	jmp    800576 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800550:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800554:	eb 20                	jmp    800576 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800558:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80055c:	eb 18                	jmp    800576 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800560:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800567:	eb 0d                	jmp    800576 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800569:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8a 06                	mov    (%esi),%al
  800578:	0f b6 d0             	movzbl %al,%edx
  80057b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80057e:	83 e8 23             	sub    $0x23,%eax
  800581:	3c 55                	cmp    $0x55,%al
  800583:	0f 87 e0 02 00 00    	ja     800869 <vprintfmt+0x368>
  800589:	0f b6 c0             	movzbl %al,%eax
  80058c:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800593:	83 ea 30             	sub    $0x30,%edx
  800596:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800599:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80059c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80059f:	83 fa 09             	cmp    $0x9,%edx
  8005a2:	77 44                	ja     8005e8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	89 de                	mov    %ebx,%esi
  8005a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005aa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005ad:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005b7:	83 fb 09             	cmp    $0x9,%ebx
  8005ba:	76 ed                	jbe    8005a9 <vprintfmt+0xa8>
  8005bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005bf:	eb 29                	jmp    8005ea <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d1:	eb 17                	jmp    8005ea <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d7:	78 85                	js     80055e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	eb 99                	jmp    800576 <vprintfmt+0x75>
  8005dd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005df:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005e6:	eb 8e                	jmp    800576 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ee:	79 86                	jns    800576 <vprintfmt+0x75>
  8005f0:	e9 74 ff ff ff       	jmp    800569 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	89 de                	mov    %ebx,%esi
  8005f8:	e9 79 ff ff ff       	jmp    800576 <vprintfmt+0x75>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	57                   	push   %edi
  80060d:	ff 30                	pushl  (%eax)
  80060f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800612:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800618:	e9 08 ff ff ff       	jmp    800525 <vprintfmt+0x24>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 02                	jns    800631 <vprintfmt+0x130>
  80062f:	f7 d8                	neg    %eax
  800631:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800633:	83 f8 08             	cmp    $0x8,%eax
  800636:	7f 0b                	jg     800643 <vprintfmt+0x142>
  800638:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80063f:	85 c0                	test   %eax,%eax
  800641:	75 1a                	jne    80065d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800643:	52                   	push   %edx
  800644:	68 96 0f 80 00       	push   $0x800f96
  800649:	57                   	push   %edi
  80064a:	ff 75 08             	pushl  0x8(%ebp)
  80064d:	e8 92 fe ff ff       	call   8004e4 <printfmt>
  800652:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800658:	e9 c8 fe ff ff       	jmp    800525 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80065d:	50                   	push   %eax
  80065e:	68 9f 0f 80 00       	push   $0x800f9f
  800663:	57                   	push   %edi
  800664:	ff 75 08             	pushl  0x8(%ebp)
  800667:	e8 78 fe ff ff       	call   8004e4 <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800672:	e9 ae fe ff ff       	jmp    800525 <vprintfmt+0x24>
  800677:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80067a:	89 de                	mov    %ebx,%esi
  80067c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80067f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800690:	85 c0                	test   %eax,%eax
  800692:	75 07                	jne    80069b <vprintfmt+0x19a>
				p = "(null)";
  800694:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80069b:	85 db                	test   %ebx,%ebx
  80069d:	7e 42                	jle    8006e1 <vprintfmt+0x1e0>
  80069f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006a3:	74 3c                	je     8006e1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	51                   	push   %ecx
  8006a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ac:	e8 6f 02 00 00       	call   800920 <strnlen>
  8006b1:	29 c3                	sub    %eax,%ebx
  8006b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	85 db                	test   %ebx,%ebx
  8006bb:	7e 24                	jle    8006e1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006bd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006c1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006c4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	57                   	push   %edi
  8006cb:	53                   	push   %ebx
  8006cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	4e                   	dec    %esi
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	85 f6                	test   %esi,%esi
  8006d5:	7f f0                	jg     8006c7 <vprintfmt+0x1c6>
  8006d7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e4:	0f be 02             	movsbl (%edx),%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	75 47                	jne    800732 <vprintfmt+0x231>
  8006eb:	eb 37                	jmp    800724 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f1:	74 16                	je     800709 <vprintfmt+0x208>
  8006f3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006f6:	83 fa 5e             	cmp    $0x5e,%edx
  8006f9:	76 0e                	jbe    800709 <vprintfmt+0x208>
					putch('?', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	57                   	push   %edi
  8006ff:	6a 3f                	push   $0x3f
  800701:	ff 55 08             	call   *0x8(%ebp)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 0b                	jmp    800714 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	50                   	push   %eax
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	ff 4d e4             	decl   -0x1c(%ebp)
  800717:	0f be 03             	movsbl (%ebx),%eax
  80071a:	85 c0                	test   %eax,%eax
  80071c:	74 03                	je     800721 <vprintfmt+0x220>
  80071e:	43                   	inc    %ebx
  80071f:	eb 1b                	jmp    80073c <vprintfmt+0x23b>
  800721:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800724:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800728:	7f 1e                	jg     800748 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80072d:	e9 f3 fd ff ff       	jmp    800525 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800732:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800735:	43                   	inc    %ebx
  800736:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800739:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80073c:	85 f6                	test   %esi,%esi
  80073e:	78 ad                	js     8006ed <vprintfmt+0x1ec>
  800740:	4e                   	dec    %esi
  800741:	79 aa                	jns    8006ed <vprintfmt+0x1ec>
  800743:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800746:	eb dc                	jmp    800724 <vprintfmt+0x223>
  800748:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	57                   	push   %edi
  80074f:	6a 20                	push   $0x20
  800751:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800754:	4b                   	dec    %ebx
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	85 db                	test   %ebx,%ebx
  80075a:	7f ef                	jg     80074b <vprintfmt+0x24a>
  80075c:	e9 c4 fd ff ff       	jmp    800525 <vprintfmt+0x24>
  800761:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 2a fd ff ff       	call   800498 <getint>
  80076e:	89 c3                	mov    %eax,%ebx
  800770:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800772:	85 d2                	test   %edx,%edx
  800774:	78 0a                	js     800780 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800776:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077b:	e9 b0 00 00 00       	jmp    800830 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	57                   	push   %edi
  800784:	6a 2d                	push   $0x2d
  800786:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800789:	f7 db                	neg    %ebx
  80078b:	83 d6 00             	adc    $0x0,%esi
  80078e:	f7 de                	neg    %esi
  800790:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800793:	b8 0a 00 00 00       	mov    $0xa,%eax
  800798:	e9 93 00 00 00       	jmp    800830 <vprintfmt+0x32f>
  80079d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 b4 fc ff ff       	call   80045e <getuint>
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	89 d6                	mov    %edx,%esi
			base = 10;
  8007ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b3:	eb 7b                	jmp    800830 <vprintfmt+0x32f>
  8007b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007b8:	89 ca                	mov    %ecx,%edx
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 d6 fc ff ff       	call   800498 <getint>
  8007c2:	89 c3                	mov    %eax,%ebx
  8007c4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	78 07                	js     8007d1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cf:	eb 5f                	jmp    800830 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	57                   	push   %edi
  8007d5:	6a 2d                	push   $0x2d
  8007d7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007da:	f7 db                	neg    %ebx
  8007dc:	83 d6 00             	adc    $0x0,%esi
  8007df:	f7 de                	neg    %esi
  8007e1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e9:	eb 45                	jmp    800830 <vprintfmt+0x32f>
  8007eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	57                   	push   %edi
  8007f2:	6a 30                	push   $0x30
  8007f4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	57                   	push   %edi
  8007fb:	6a 78                	push   $0x78
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800809:	8b 18                	mov    (%eax),%ebx
  80080b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800810:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800818:	eb 16                	jmp    800830 <vprintfmt+0x32f>
  80081a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80081d:	89 ca                	mov    %ecx,%edx
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	e8 37 fc ff ff       	call   80045e <getuint>
  800827:	89 c3                	mov    %eax,%ebx
  800829:	89 d6                	mov    %edx,%esi
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800837:	52                   	push   %edx
  800838:	ff 75 e4             	pushl  -0x1c(%ebp)
  80083b:	50                   	push   %eax
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	89 fa                	mov    %edi,%edx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	e8 68 fb ff ff       	call   8003b0 <printnum>
			break;
  800848:	83 c4 20             	add    $0x20,%esp
  80084b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80084e:	e9 d2 fc ff ff       	jmp    800525 <vprintfmt+0x24>
  800853:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	57                   	push   %edi
  80085a:	52                   	push   %edx
  80085b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80085e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800861:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800864:	e9 bc fc ff ff       	jmp    800525 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	57                   	push   %edi
  80086d:	6a 25                	push   $0x25
  80086f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	eb 02                	jmp    800879 <vprintfmt+0x378>
  800877:	89 c6                	mov    %eax,%esi
  800879:	8d 46 ff             	lea    -0x1(%esi),%eax
  80087c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800880:	75 f5                	jne    800877 <vprintfmt+0x376>
  800882:	e9 9e fc ff ff       	jmp    800525 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800887:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5f                   	pop    %edi
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 18             	sub    $0x18,%esp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	74 26                	je     8008d6 <vsnprintf+0x47>
  8008b0:	85 d2                	test   %edx,%edx
  8008b2:	7e 29                	jle    8008dd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b4:	ff 75 14             	pushl  0x14(%ebp)
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	68 ca 04 80 00       	push   $0x8004ca
  8008c3:	e8 39 fc ff ff       	call   800501 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	eb 0c                	jmp    8008e2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008db:	eb 05                	jmp    8008e2 <vsnprintf+0x53>
  8008dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ed:	50                   	push   %eax
  8008ee:	ff 75 10             	pushl  0x10(%ebp)
  8008f1:	ff 75 0c             	pushl  0xc(%ebp)
  8008f4:	ff 75 08             	pushl  0x8(%ebp)
  8008f7:	e8 93 ff ff ff       	call   80088f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	80 3a 00             	cmpb   $0x0,(%edx)
  800909:	74 0e                	je     800919 <strlen+0x19>
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800910:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800911:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800915:	75 f9                	jne    800910 <strlen+0x10>
  800917:	eb 05                	jmp    80091e <strlen+0x1e>
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800929:	85 d2                	test   %edx,%edx
  80092b:	74 17                	je     800944 <strnlen+0x24>
  80092d:	80 39 00             	cmpb   $0x0,(%ecx)
  800930:	74 19                	je     80094b <strnlen+0x2b>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800937:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	74 14                	je     800950 <strnlen+0x30>
  80093c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800940:	75 f5                	jne    800937 <strnlen+0x17>
  800942:	eb 0c                	jmp    800950 <strnlen+0x30>
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	eb 05                	jmp    800950 <strnlen+0x30>
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095c:	ba 00 00 00 00       	mov    $0x0,%edx
  800961:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800964:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800967:	42                   	inc    %edx
  800968:	84 c9                	test   %cl,%cl
  80096a:	75 f5                	jne    800961 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80096c:	5b                   	pop    %ebx
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800976:	53                   	push   %ebx
  800977:	e8 84 ff ff ff       	call   800900 <strlen>
  80097c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800985:	50                   	push   %eax
  800986:	e8 c7 ff ff ff       	call   800952 <strcpy>
	return dst;
}
  80098b:	89 d8                	mov    %ebx,%eax
  80098d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a0:	85 f6                	test   %esi,%esi
  8009a2:	74 15                	je     8009b9 <strncpy+0x27>
  8009a4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009a9:	8a 1a                	mov    (%edx),%bl
  8009ab:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ae:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	41                   	inc    %ecx
  8009b5:	39 ce                	cmp    %ecx,%esi
  8009b7:	77 f0                	ja     8009a9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cc:	85 f6                	test   %esi,%esi
  8009ce:	74 32                	je     800a02 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009d0:	83 fe 01             	cmp    $0x1,%esi
  8009d3:	74 22                	je     8009f7 <strlcpy+0x3a>
  8009d5:	8a 0b                	mov    (%ebx),%cl
  8009d7:	84 c9                	test   %cl,%cl
  8009d9:	74 20                	je     8009fb <strlcpy+0x3e>
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009e2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e5:	88 08                	mov    %cl,(%eax)
  8009e7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e8:	39 f2                	cmp    %esi,%edx
  8009ea:	74 11                	je     8009fd <strlcpy+0x40>
  8009ec:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009f0:	42                   	inc    %edx
  8009f1:	84 c9                	test   %cl,%cl
  8009f3:	75 f0                	jne    8009e5 <strlcpy+0x28>
  8009f5:	eb 06                	jmp    8009fd <strlcpy+0x40>
  8009f7:	89 f8                	mov    %edi,%eax
  8009f9:	eb 02                	jmp    8009fd <strlcpy+0x40>
  8009fb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fd:	c6 00 00             	movb   $0x0,(%eax)
  800a00:	eb 02                	jmp    800a04 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a02:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a04:	29 f8                	sub    %edi,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a14:	8a 01                	mov    (%ecx),%al
  800a16:	84 c0                	test   %al,%al
  800a18:	74 10                	je     800a2a <strcmp+0x1f>
  800a1a:	3a 02                	cmp    (%edx),%al
  800a1c:	75 0c                	jne    800a2a <strcmp+0x1f>
		p++, q++;
  800a1e:	41                   	inc    %ecx
  800a1f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a20:	8a 01                	mov    (%ecx),%al
  800a22:	84 c0                	test   %al,%al
  800a24:	74 04                	je     800a2a <strcmp+0x1f>
  800a26:	3a 02                	cmp    (%edx),%al
  800a28:	74 f4                	je     800a1e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 12             	movzbl (%edx),%edx
  800a30:	29 d0                	sub    %edx,%eax
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 1b                	je     800a60 <strncmp+0x2c>
  800a45:	8a 1a                	mov    (%edx),%bl
  800a47:	84 db                	test   %bl,%bl
  800a49:	74 24                	je     800a6f <strncmp+0x3b>
  800a4b:	3a 19                	cmp    (%ecx),%bl
  800a4d:	75 20                	jne    800a6f <strncmp+0x3b>
  800a4f:	48                   	dec    %eax
  800a50:	74 15                	je     800a67 <strncmp+0x33>
		n--, p++, q++;
  800a52:	42                   	inc    %edx
  800a53:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a54:	8a 1a                	mov    (%edx),%bl
  800a56:	84 db                	test   %bl,%bl
  800a58:	74 15                	je     800a6f <strncmp+0x3b>
  800a5a:	3a 19                	cmp    (%ecx),%bl
  800a5c:	74 f1                	je     800a4f <strncmp+0x1b>
  800a5e:	eb 0f                	jmp    800a6f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	eb 05                	jmp    800a6c <strncmp+0x38>
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6f:	0f b6 02             	movzbl (%edx),%eax
  800a72:	0f b6 11             	movzbl (%ecx),%edx
  800a75:	29 d0                	sub    %edx,%eax
  800a77:	eb f3                	jmp    800a6c <strncmp+0x38>

00800a79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a82:	8a 10                	mov    (%eax),%dl
  800a84:	84 d2                	test   %dl,%dl
  800a86:	74 18                	je     800aa0 <strchr+0x27>
		if (*s == c)
  800a88:	38 ca                	cmp    %cl,%dl
  800a8a:	75 06                	jne    800a92 <strchr+0x19>
  800a8c:	eb 17                	jmp    800aa5 <strchr+0x2c>
  800a8e:	38 ca                	cmp    %cl,%dl
  800a90:	74 13                	je     800aa5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a92:	40                   	inc    %eax
  800a93:	8a 10                	mov    (%eax),%dl
  800a95:	84 d2                	test   %dl,%dl
  800a97:	75 f5                	jne    800a8e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9e:	eb 05                	jmp    800aa5 <strchr+0x2c>
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ab0:	8a 10                	mov    (%eax),%dl
  800ab2:	84 d2                	test   %dl,%dl
  800ab4:	74 11                	je     800ac7 <strfind+0x20>
		if (*s == c)
  800ab6:	38 ca                	cmp    %cl,%dl
  800ab8:	75 06                	jne    800ac0 <strfind+0x19>
  800aba:	eb 0b                	jmp    800ac7 <strfind+0x20>
  800abc:	38 ca                	cmp    %cl,%dl
  800abe:	74 07                	je     800ac7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac0:	40                   	inc    %eax
  800ac1:	8a 10                	mov    (%eax),%dl
  800ac3:	84 d2                	test   %dl,%dl
  800ac5:	75 f5                	jne    800abc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad8:	85 c9                	test   %ecx,%ecx
  800ada:	74 30                	je     800b0c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae2:	75 25                	jne    800b09 <memset+0x40>
  800ae4:	f6 c1 03             	test   $0x3,%cl
  800ae7:	75 20                	jne    800b09 <memset+0x40>
		c &= 0xFF;
  800ae9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	c1 e3 08             	shl    $0x8,%ebx
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	c1 e6 18             	shl    $0x18,%esi
  800af6:	89 d0                	mov    %edx,%eax
  800af8:	c1 e0 10             	shl    $0x10,%eax
  800afb:	09 f0                	or     %esi,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b01:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b04:	fc                   	cld    
  800b05:	f3 ab                	rep stos %eax,%es:(%edi)
  800b07:	eb 03                	jmp    800b0c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b09:	fc                   	cld    
  800b0a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0c:	89 f8                	mov    %edi,%eax
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b21:	39 c6                	cmp    %eax,%esi
  800b23:	73 34                	jae    800b59 <memmove+0x46>
  800b25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b28:	39 d0                	cmp    %edx,%eax
  800b2a:	73 2d                	jae    800b59 <memmove+0x46>
		s += n;
		d += n;
  800b2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	f6 c2 03             	test   $0x3,%dl
  800b32:	75 1b                	jne    800b4f <memmove+0x3c>
  800b34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3a:	75 13                	jne    800b4f <memmove+0x3c>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 07                	jmp    800b56 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4f:	4f                   	dec    %edi
  800b50:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b53:	fd                   	std    
  800b54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b56:	fc                   	cld    
  800b57:	eb 20                	jmp    800b79 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5f:	75 13                	jne    800b74 <memmove+0x61>
  800b61:	a8 03                	test   $0x3,%al
  800b63:	75 0f                	jne    800b74 <memmove+0x61>
  800b65:	f6 c1 03             	test   $0x3,%cl
  800b68:	75 0a                	jne    800b74 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b6a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	fc                   	cld    
  800b70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b72:	eb 05                	jmp    800b79 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b74:	89 c7                	mov    %eax,%edi
  800b76:	fc                   	cld    
  800b77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b80:	ff 75 10             	pushl  0x10(%ebp)
  800b83:	ff 75 0c             	pushl  0xc(%ebp)
  800b86:	ff 75 08             	pushl  0x8(%ebp)
  800b89:	e8 85 ff ff ff       	call   800b13 <memmove>
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	85 ff                	test   %edi,%edi
  800ba1:	74 32                	je     800bd5 <memcmp+0x45>
		if (*s1 != *s2)
  800ba3:	8a 03                	mov    (%ebx),%al
  800ba5:	8a 0e                	mov    (%esi),%cl
  800ba7:	38 c8                	cmp    %cl,%al
  800ba9:	74 19                	je     800bc4 <memcmp+0x34>
  800bab:	eb 0d                	jmp    800bba <memcmp+0x2a>
  800bad:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bb1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bb5:	42                   	inc    %edx
  800bb6:	38 c8                	cmp    %cl,%al
  800bb8:	74 10                	je     800bca <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bba:	0f b6 c0             	movzbl %al,%eax
  800bbd:	0f b6 c9             	movzbl %cl,%ecx
  800bc0:	29 c8                	sub    %ecx,%eax
  800bc2:	eb 16                	jmp    800bda <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc4:	4f                   	dec    %edi
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	39 fa                	cmp    %edi,%edx
  800bcc:	75 df                	jne    800bad <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd3:	eb 05                	jmp    800bda <memcmp+0x4a>
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bea:	39 d0                	cmp    %edx,%eax
  800bec:	73 12                	jae    800c00 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bee:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bf1:	38 08                	cmp    %cl,(%eax)
  800bf3:	75 06                	jne    800bfb <memfind+0x1c>
  800bf5:	eb 09                	jmp    800c00 <memfind+0x21>
  800bf7:	38 08                	cmp    %cl,(%eax)
  800bf9:	74 05                	je     800c00 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfb:	40                   	inc    %eax
  800bfc:	39 c2                	cmp    %eax,%edx
  800bfe:	77 f7                	ja     800bf7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0e:	eb 01                	jmp    800c11 <strtol+0xf>
		s++;
  800c10:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c11:	8a 02                	mov    (%edx),%al
  800c13:	3c 20                	cmp    $0x20,%al
  800c15:	74 f9                	je     800c10 <strtol+0xe>
  800c17:	3c 09                	cmp    $0x9,%al
  800c19:	74 f5                	je     800c10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1b:	3c 2b                	cmp    $0x2b,%al
  800c1d:	75 08                	jne    800c27 <strtol+0x25>
		s++;
  800c1f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	eb 13                	jmp    800c3a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c27:	3c 2d                	cmp    $0x2d,%al
  800c29:	75 0a                	jne    800c35 <strtol+0x33>
		s++, neg = 1;
  800c2b:	8d 52 01             	lea    0x1(%edx),%edx
  800c2e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c33:	eb 05                	jmp    800c3a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3a:	85 db                	test   %ebx,%ebx
  800c3c:	74 05                	je     800c43 <strtol+0x41>
  800c3e:	83 fb 10             	cmp    $0x10,%ebx
  800c41:	75 28                	jne    800c6b <strtol+0x69>
  800c43:	8a 02                	mov    (%edx),%al
  800c45:	3c 30                	cmp    $0x30,%al
  800c47:	75 10                	jne    800c59 <strtol+0x57>
  800c49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c4d:	75 0a                	jne    800c59 <strtol+0x57>
		s += 2, base = 16;
  800c4f:	83 c2 02             	add    $0x2,%edx
  800c52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c57:	eb 12                	jmp    800c6b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c59:	85 db                	test   %ebx,%ebx
  800c5b:	75 0e                	jne    800c6b <strtol+0x69>
  800c5d:	3c 30                	cmp    $0x30,%al
  800c5f:	75 05                	jne    800c66 <strtol+0x64>
		s++, base = 8;
  800c61:	42                   	inc    %edx
  800c62:	b3 08                	mov    $0x8,%bl
  800c64:	eb 05                	jmp    800c6b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c66:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c72:	8a 0a                	mov    (%edx),%cl
  800c74:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c77:	80 fb 09             	cmp    $0x9,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0x82>
			dig = *s - '0';
  800c7c:	0f be c9             	movsbl %cl,%ecx
  800c7f:	83 e9 30             	sub    $0x30,%ecx
  800c82:	eb 1e                	jmp    800ca2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c84:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c87:	80 fb 19             	cmp    $0x19,%bl
  800c8a:	77 08                	ja     800c94 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c8c:	0f be c9             	movsbl %cl,%ecx
  800c8f:	83 e9 57             	sub    $0x57,%ecx
  800c92:	eb 0e                	jmp    800ca2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c94:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c97:	80 fb 19             	cmp    $0x19,%bl
  800c9a:	77 13                	ja     800caf <strtol+0xad>
			dig = *s - 'A' + 10;
  800c9c:	0f be c9             	movsbl %cl,%ecx
  800c9f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ca2:	39 f1                	cmp    %esi,%ecx
  800ca4:	7d 0d                	jge    800cb3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ca6:	42                   	inc    %edx
  800ca7:	0f af c6             	imul   %esi,%eax
  800caa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cad:	eb c3                	jmp    800c72 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	eb 02                	jmp    800cb5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb9:	74 05                	je     800cc0 <strtol+0xbe>
		*endptr = (char *) s;
  800cbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cbe:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc0:	85 ff                	test   %edi,%edi
  800cc2:	74 04                	je     800cc8 <strtol+0xc6>
  800cc4:	89 c8                	mov    %ecx,%eax
  800cc6:	f7 d8                	neg    %eax
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    
  800ccd:	00 00                	add    %al,(%eax)
	...

00800cd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	83 ec 10             	sub    $0x10,%esp
  800cd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cde:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ce1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ce7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	75 2e                	jne    800d1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cee:	39 f1                	cmp    %esi,%ecx
  800cf0:	77 5a                	ja     800d4c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf2:	85 c9                	test   %ecx,%ecx
  800cf4:	75 0b                	jne    800d01 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f1                	div    %ecx
  800cff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d01:	31 d2                	xor    %edx,%edx
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	f7 f1                	div    %ecx
  800d07:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	f7 f1                	div    %ecx
  800d0d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    
  800d1a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d1c:	39 f0                	cmp    %esi,%eax
  800d1e:	77 1c                	ja     800d3c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d20:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d23:	83 f7 1f             	xor    $0x1f,%edi
  800d26:	75 3c                	jne    800d64 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	0f 82 90 00 00 00    	jb     800dc0 <__udivdi3+0xf0>
  800d30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d33:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d36:	0f 86 84 00 00 00    	jbe    800dc0 <__udivdi3+0xf0>
  800d3c:	31 f6                	xor    %esi,%esi
  800d3e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d40:	89 f8                	mov    %edi,%eax
  800d42:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d4c:	89 f2                	mov    %esi,%edx
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	f7 f1                	div    %ecx
  800d52:	89 c7                	mov    %eax,%edi
  800d54:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d56:	89 f8                	mov    %edi,%eax
  800d58:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    
  800d61:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d64:	89 f9                	mov    %edi,%ecx
  800d66:	d3 e0                	shl    %cl,%eax
  800d68:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d6b:	b8 20 00 00 00       	mov    $0x20,%eax
  800d70:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d75:	88 c1                	mov    %al,%cl
  800d77:	d3 ea                	shr    %cl,%edx
  800d79:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d7c:	09 ca                	or     %ecx,%edx
  800d7e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d84:	89 f9                	mov    %edi,%ecx
  800d86:	d3 e2                	shl    %cl,%edx
  800d88:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	88 c1                	mov    %al,%cl
  800d8f:	d3 ea                	shr    %cl,%edx
  800d91:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d94:	89 f2                	mov    %esi,%edx
  800d96:	89 f9                	mov    %edi,%ecx
  800d98:	d3 e2                	shl    %cl,%edx
  800d9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d9d:	88 c1                	mov    %al,%cl
  800d9f:	d3 ee                	shr    %cl,%esi
  800da1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	89 ca                	mov    %ecx,%edx
  800daa:	f7 75 ec             	divl   -0x14(%ebp)
  800dad:	89 d1                	mov    %edx,%ecx
  800daf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800db1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db4:	39 d1                	cmp    %edx,%ecx
  800db6:	72 28                	jb     800de0 <__udivdi3+0x110>
  800db8:	74 1a                	je     800dd4 <__udivdi3+0x104>
  800dba:	89 f7                	mov    %esi,%edi
  800dbc:	31 f6                	xor    %esi,%esi
  800dbe:	eb 80                	jmp    800d40 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc0:	31 f6                	xor    %esi,%esi
  800dc2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc7:	89 f8                	mov    %edi,%eax
  800dc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    
  800dd2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd7:	89 f9                	mov    %edi,%ecx
  800dd9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ddb:	39 c2                	cmp    %eax,%edx
  800ddd:	73 db                	jae    800dba <__udivdi3+0xea>
  800ddf:	90                   	nop
		{
		  q0--;
  800de0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de3:	31 f6                	xor    %esi,%esi
  800de5:	e9 56 ff ff ff       	jmp    800d40 <__udivdi3+0x70>
	...

00800dec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	83 ec 20             	sub    $0x20,%esp
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800dfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e03:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e09:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e0b:	85 ff                	test   %edi,%edi
  800e0d:	75 15                	jne    800e24 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e0f:	39 f1                	cmp    %esi,%ecx
  800e11:	0f 86 99 00 00 00    	jbe    800eb0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e17:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e19:	89 d0                	mov    %edx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e1d:	83 c4 20             	add    $0x20,%esp
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e24:	39 f7                	cmp    %esi,%edi
  800e26:	0f 87 a4 00 00 00    	ja     800ed0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e2c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e2f:	83 f0 1f             	xor    $0x1f,%eax
  800e32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e35:	0f 84 a1 00 00 00    	je     800edc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e3b:	89 f8                	mov    %edi,%eax
  800e3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e40:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e42:	bf 20 00 00 00       	mov    $0x20,%edi
  800e47:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4d:	89 f9                	mov    %edi,%ecx
  800e4f:	d3 ea                	shr    %cl,%edx
  800e51:	09 c2                	or     %eax,%edx
  800e53:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e5c:	d3 e0                	shl    %cl,%eax
  800e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e61:	89 f2                	mov    %esi,%edx
  800e63:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e68:	d3 e0                	shl    %cl,%eax
  800e6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	d3 e8                	shr    %cl,%eax
  800e74:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e76:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	f7 75 f0             	divl   -0x10(%ebp)
  800e7d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e7f:	f7 65 f4             	mull   -0xc(%ebp)
  800e82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e85:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 71                	jb     800efc <__umoddi3+0x110>
  800e8b:	74 7f                	je     800f0c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e90:	29 c8                	sub    %ecx,%eax
  800e92:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e94:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e97:	d3 e8                	shr    %cl,%eax
  800e99:	89 f2                	mov    %esi,%edx
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e9f:	09 d0                	or     %edx,%eax
  800ea1:	89 f2                	mov    %esi,%edx
  800ea3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ea6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb0:	85 c9                	test   %ecx,%ecx
  800eb2:	75 0b                	jne    800ebf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb9:	31 d2                	xor    %edx,%edx
  800ebb:	f7 f1                	div    %ecx
  800ebd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec8:	f7 f1                	div    %ecx
  800eca:	e9 4a ff ff ff       	jmp    800e19 <__umoddi3+0x2d>
  800ecf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed2:	83 c4 20             	add    $0x20,%esp
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    
  800ed9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800edc:	39 f7                	cmp    %esi,%edi
  800ede:	72 05                	jb     800ee5 <__umoddi3+0xf9>
  800ee0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ee3:	77 0c                	ja     800ef1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee5:	89 f2                	mov    %esi,%edx
  800ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eea:	29 c8                	sub    %ecx,%eax
  800eec:	19 fa                	sbb    %edi,%edx
  800eee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    
  800efb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800efc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f04:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f07:	eb 84                	jmp    800e8d <__umoddi3+0xa1>
  800f09:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f0f:	72 eb                	jb     800efc <__umoddi3+0x110>
  800f11:	89 f2                	mov    %esi,%edx
  800f13:	e9 75 ff ff ff       	jmp    800e8d <__umoddi3+0xa1>
