
obj/user/softint:     file format elf32-i386


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
  800047:	e8 05 01 00 00       	call   800151 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	c1 e0 07             	shl    $0x7,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 f6                	test   %esi,%esi
  800060:	7e 07                	jle    800069 <libmain+0x2d>
		binaryname = argv[0];
  800062:	8b 03                	mov    (%ebx),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	53                   	push   %ebx
  80006d:	56                   	push   %esi
  80006e:	e8 c1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800073:	e8 0c 00 00 00       	call   800084 <exit>
  800078:	83 c4 10             	add    $0x10,%esp
}
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	c9                   	leave  
  800081:	c3                   	ret    
	...

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 9e 00 00 00       	call   80012f <sys_env_destroy>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
  80009e:	83 ec 1c             	sub    $0x1c,%esp
  8000a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000a7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b5:	cd 30                	int    $0x30
  8000b7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000bd:	74 1c                	je     8000db <syscall+0x43>
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7e 18                	jle    8000db <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	50                   	push   %eax
  8000c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ca:	68 2a 0f 80 00       	push   $0x800f2a
  8000cf:	6a 42                	push   $0x42
  8000d1:	68 47 0f 80 00       	push   $0x800f47
  8000d6:	e8 e1 01 00 00       	call   8002bc <_panic>

	return ret;
}
  8000db:	89 d0                	mov    %edx,%eax
  8000dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000eb:	6a 00                	push   $0x0
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800101:	e8 92 ff ff ff       	call   800098 <syscall>
  800106:	83 c4 10             	add    $0x10,%esp
	return;
}
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <sys_cgetc>:

int
sys_cgetc(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	6a 00                	push   $0x0
  800119:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 01 00 00 00       	mov    $0x1,%eax
  800128:	e8 6b ff ff ff       	call   800098 <syscall>
}
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800135:	6a 00                	push   $0x0
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800140:	ba 01 00 00 00       	mov    $0x1,%edx
  800145:	b8 03 00 00 00       	mov    $0x3,%eax
  80014a:	e8 49 ff ff ff       	call   800098 <syscall>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800157:	6a 00                	push   $0x0
  800159:	6a 00                	push   $0x0
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 02 00 00 00       	mov    $0x2,%eax
  80016e:	e8 25 ff ff ff       	call   800098 <syscall>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <sys_yield>:

void
sys_yield(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	b9 00 00 00 00       	mov    $0x0,%ecx
  800188:	ba 00 00 00 00       	mov    $0x0,%edx
  80018d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800192:	e8 01 ff ff ff       	call   800098 <syscall>
  800197:	83 c4 10             	add    $0x10,%esp
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001a2:	6a 00                	push   $0x0
  8001a4:	6a 00                	push   $0x0
  8001a6:	ff 75 10             	pushl  0x10(%ebp)
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001af:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b9:	e8 da fe ff ff       	call   800098 <syscall>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001c6:	ff 75 18             	pushl  0x18(%ebp)
  8001c9:	ff 75 14             	pushl  0x14(%ebp)
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	e8 b4 fe ff ff       	call   800098 <syscall>
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001ec:	6a 00                	push   $0x0
  8001ee:	6a 00                	push   $0x0
  8001f0:	6a 00                	push   $0x0
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f8:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	e8 91 fe ff ff       	call   800098 <syscall>
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80020f:	6a 00                	push   $0x0
  800211:	6a 00                	push   $0x0
  800213:	6a 00                	push   $0x0
  800215:	ff 75 0c             	pushl  0xc(%ebp)
  800218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021b:	ba 01 00 00 00       	mov    $0x1,%edx
  800220:	b8 08 00 00 00       	mov    $0x8,%eax
  800225:	e8 6e fe ff ff       	call   800098 <syscall>
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800232:	6a 00                	push   $0x0
  800234:	6a 00                	push   $0x0
  800236:	6a 00                	push   $0x0
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023e:	ba 01 00 00 00       	mov    $0x1,%edx
  800243:	b8 09 00 00 00       	mov    $0x9,%eax
  800248:	e8 4b fe ff ff       	call   800098 <syscall>
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800255:	6a 00                	push   $0x0
  800257:	ff 75 14             	pushl  0x14(%ebp)
  80025a:	ff 75 10             	pushl  0x10(%ebp)
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800263:	ba 00 00 00 00       	mov    $0x0,%edx
  800268:	b8 0b 00 00 00       	mov    $0xb,%eax
  80026d:	e8 26 fe ff ff       	call   800098 <syscall>
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80027a:	6a 00                	push   $0x0
  80027c:	6a 00                	push   $0x0
  80027e:	6a 00                	push   $0x0
  800280:	6a 00                	push   $0x0
  800282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800285:	ba 01 00 00 00       	mov    $0x1,%edx
  80028a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80028f:	e8 04 fe ff ff       	call   800098 <syscall>
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80029c:	6a 00                	push   $0x0
  80029e:	6a 00                	push   $0x0
  8002a0:	6a 00                	push   $0x0
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002b2:	e8 e1 fd ff ff       	call   800098 <syscall>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002ca:	e8 82 fe ff ff       	call   800151 <sys_getenvid>
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	ff 75 08             	pushl  0x8(%ebp)
  8002d8:	53                   	push   %ebx
  8002d9:	50                   	push   %eax
  8002da:	68 58 0f 80 00       	push   $0x800f58
  8002df:	e8 b0 00 00 00       	call   800394 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	56                   	push   %esi
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	e8 53 00 00 00       	call   800343 <vcprintf>
	cprintf("\n");
  8002f0:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  8002f7:	e8 98 00 00 00       	call   800394 <cprintf>
  8002fc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ff:	cc                   	int3   
  800300:	eb fd                	jmp    8002ff <_panic+0x43>
	...

00800304 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	53                   	push   %ebx
  800308:	83 ec 04             	sub    $0x4,%esp
  80030b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030e:	8b 03                	mov    (%ebx),%eax
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800317:	40                   	inc    %eax
  800318:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80031a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031f:	75 1a                	jne    80033b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	68 ff 00 00 00       	push   $0xff
  800329:	8d 43 08             	lea    0x8(%ebx),%eax
  80032c:	50                   	push   %eax
  80032d:	e8 b3 fd ff ff       	call   8000e5 <sys_cputs>
		b->idx = 0;
  800332:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800338:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80033b:	ff 43 04             	incl   0x4(%ebx)
}
  80033e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800353:	00 00 00 
	b.cnt = 0;
  800356:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80035d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036c:	50                   	push   %eax
  80036d:	68 04 03 80 00       	push   $0x800304
  800372:	e8 82 01 00 00       	call   8004f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800377:	83 c4 08             	add    $0x8,%esp
  80037a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800380:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800386:	50                   	push   %eax
  800387:	e8 59 fd ff ff       	call   8000e5 <sys_cputs>

	return b.cnt;
}
  80038c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80039d:	50                   	push   %eax
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 9d ff ff ff       	call   800343 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 2c             	sub    $0x2c,%esp
  8003b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b4:	89 d6                	mov    %edx,%esi
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003d8:	72 0c                	jb     8003e6 <printnum+0x3e>
  8003da:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003dd:	76 07                	jbe    8003e6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003df:	4b                   	dec    %ebx
  8003e0:	85 db                	test   %ebx,%ebx
  8003e2:	7f 31                	jg     800415 <printnum+0x6d>
  8003e4:	eb 3f                	jmp    800425 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e6:	83 ec 0c             	sub    $0xc,%esp
  8003e9:	57                   	push   %edi
  8003ea:	4b                   	dec    %ebx
  8003eb:	53                   	push   %ebx
  8003ec:	50                   	push   %eax
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fc:	e8 c7 08 00 00       	call   800cc8 <__udivdi3>
  800401:	83 c4 18             	add    $0x18,%esp
  800404:	52                   	push   %edx
  800405:	50                   	push   %eax
  800406:	89 f2                	mov    %esi,%edx
  800408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040b:	e8 98 ff ff ff       	call   8003a8 <printnum>
  800410:	83 c4 20             	add    $0x20,%esp
  800413:	eb 10                	jmp    800425 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	56                   	push   %esi
  800419:	57                   	push   %edi
  80041a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80041d:	4b                   	dec    %ebx
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	85 db                	test   %ebx,%ebx
  800423:	7f f0                	jg     800415 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	56                   	push   %esi
  800429:	83 ec 04             	sub    $0x4,%esp
  80042c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80042f:	ff 75 d0             	pushl  -0x30(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 a7 09 00 00       	call   800de4 <__umoddi3>
  80043d:	83 c4 14             	add    $0x14,%esp
  800440:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  800447:	50                   	push   %eax
  800448:	ff 55 e4             	call   *-0x1c(%ebp)
  80044b:	83 c4 10             	add    $0x10,%esp
}
  80044e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	c9                   	leave  
  800455:	c3                   	ret    

00800456 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800459:	83 fa 01             	cmp    $0x1,%edx
  80045c:	7e 0e                	jle    80046c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 08             	lea    0x8(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	8b 52 04             	mov    0x4(%edx),%edx
  80046a:	eb 22                	jmp    80048e <getuint+0x38>
	else if (lflag)
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 10                	je     800480 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	eb 0e                	jmp    80048e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800480:	8b 10                	mov    (%eax),%edx
  800482:	8d 4a 04             	lea    0x4(%edx),%ecx
  800485:	89 08                	mov    %ecx,(%eax)
  800487:	8b 02                	mov    (%edx),%eax
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800493:	83 fa 01             	cmp    $0x1,%edx
  800496:	7e 0e                	jle    8004a6 <getint+0x16>
		return va_arg(*ap, long long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	8b 52 04             	mov    0x4(%edx),%edx
  8004a4:	eb 1a                	jmp    8004c0 <getint+0x30>
	else if (lflag)
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	74 0c                	je     8004b6 <getint+0x26>
		return va_arg(*ap, long);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	99                   	cltd   
  8004b4:	eb 0a                	jmp    8004c0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	99                   	cltd   
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d0:	73 08                	jae    8004da <sprintputch+0x18>
		*b->buf++ = ch;
  8004d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d5:	88 0a                	mov    %cl,(%edx)
  8004d7:	42                   	inc    %edx
  8004d8:	89 10                	mov    %edx,(%eax)
}
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e5:	50                   	push   %eax
  8004e6:	ff 75 10             	pushl  0x10(%ebp)
  8004e9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ec:	ff 75 08             	pushl  0x8(%ebp)
  8004ef:	e8 05 00 00 00       	call   8004f9 <vprintfmt>
	va_end(ap);
  8004f4:	83 c4 10             	add    $0x10,%esp
}
  8004f7:	c9                   	leave  
  8004f8:	c3                   	ret    

008004f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	57                   	push   %edi
  8004fd:	56                   	push   %esi
  8004fe:	53                   	push   %ebx
  8004ff:	83 ec 2c             	sub    $0x2c,%esp
  800502:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800505:	8b 75 10             	mov    0x10(%ebp),%esi
  800508:	eb 13                	jmp    80051d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050a:	85 c0                	test   %eax,%eax
  80050c:	0f 84 6d 03 00 00    	je     80087f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	57                   	push   %edi
  800516:	50                   	push   %eax
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80051d:	0f b6 06             	movzbl (%esi),%eax
  800520:	46                   	inc    %esi
  800521:	83 f8 25             	cmp    $0x25,%eax
  800524:	75 e4                	jne    80050a <vprintfmt+0x11>
  800526:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80052a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800531:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800538:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800544:	eb 28                	jmp    80056e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800548:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80054c:	eb 20                	jmp    80056e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800554:	eb 18                	jmp    80056e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800558:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80055f:	eb 0d                	jmp    80056e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800561:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800567:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8a 06                	mov    (%esi),%al
  800570:	0f b6 d0             	movzbl %al,%edx
  800573:	8d 5e 01             	lea    0x1(%esi),%ebx
  800576:	83 e8 23             	sub    $0x23,%eax
  800579:	3c 55                	cmp    $0x55,%al
  80057b:	0f 87 e0 02 00 00    	ja     800861 <vprintfmt+0x368>
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058b:	83 ea 30             	sub    $0x30,%edx
  80058e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800591:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800594:	8d 50 d0             	lea    -0x30(%eax),%edx
  800597:	83 fa 09             	cmp    $0x9,%edx
  80059a:	77 44                	ja     8005e0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	89 de                	mov    %ebx,%esi
  80059e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005a2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005a5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005a9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005ac:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005af:	83 fb 09             	cmp    $0x9,%ebx
  8005b2:	76 ed                	jbe    8005a1 <vprintfmt+0xa8>
  8005b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005b7:	eb 29                	jmp    8005e2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c9:	eb 17                	jmp    8005e2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cf:	78 85                	js     800556 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	89 de                	mov    %ebx,%esi
  8005d3:	eb 99                	jmp    80056e <vprintfmt+0x75>
  8005d5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005de:	eb 8e                	jmp    80056e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e6:	79 86                	jns    80056e <vprintfmt+0x75>
  8005e8:	e9 74 ff ff ff       	jmp    800561 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ed:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	89 de                	mov    %ebx,%esi
  8005f0:	e9 79 ff ff ff       	jmp    80056e <vprintfmt+0x75>
  8005f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	57                   	push   %edi
  800605:	ff 30                	pushl  (%eax)
  800607:	ff 55 08             	call   *0x8(%ebp)
			break;
  80060a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800610:	e9 08 ff ff ff       	jmp    80051d <vprintfmt+0x24>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	85 c0                	test   %eax,%eax
  800625:	79 02                	jns    800629 <vprintfmt+0x130>
  800627:	f7 d8                	neg    %eax
  800629:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062b:	83 f8 08             	cmp    $0x8,%eax
  80062e:	7f 0b                	jg     80063b <vprintfmt+0x142>
  800630:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  800637:	85 c0                	test   %eax,%eax
  800639:	75 1a                	jne    800655 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80063b:	52                   	push   %edx
  80063c:	68 96 0f 80 00       	push   $0x800f96
  800641:	57                   	push   %edi
  800642:	ff 75 08             	pushl  0x8(%ebp)
  800645:	e8 92 fe ff ff       	call   8004dc <printfmt>
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800650:	e9 c8 fe ff ff       	jmp    80051d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800655:	50                   	push   %eax
  800656:	68 9f 0f 80 00       	push   $0x800f9f
  80065b:	57                   	push   %edi
  80065c:	ff 75 08             	pushl  0x8(%ebp)
  80065f:	e8 78 fe ff ff       	call   8004dc <printfmt>
  800664:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80066a:	e9 ae fe ff ff       	jmp    80051d <vprintfmt+0x24>
  80066f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800672:	89 de                	mov    %ebx,%esi
  800674:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800677:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800688:	85 c0                	test   %eax,%eax
  80068a:	75 07                	jne    800693 <vprintfmt+0x19a>
				p = "(null)";
  80068c:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800693:	85 db                	test   %ebx,%ebx
  800695:	7e 42                	jle    8006d9 <vprintfmt+0x1e0>
  800697:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80069b:	74 3c                	je     8006d9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	51                   	push   %ecx
  8006a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a4:	e8 6f 02 00 00       	call   800918 <strnlen>
  8006a9:	29 c3                	sub    %eax,%ebx
  8006ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	85 db                	test   %ebx,%ebx
  8006b3:	7e 24                	jle    8006d9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006b5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006b9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006bc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	57                   	push   %edi
  8006c3:	53                   	push   %ebx
  8006c4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c7:	4e                   	dec    %esi
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 f6                	test   %esi,%esi
  8006cd:	7f f0                	jg     8006bf <vprintfmt+0x1c6>
  8006cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006dc:	0f be 02             	movsbl (%edx),%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	75 47                	jne    80072a <vprintfmt+0x231>
  8006e3:	eb 37                	jmp    80071c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e9:	74 16                	je     800701 <vprintfmt+0x208>
  8006eb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006ee:	83 fa 5e             	cmp    $0x5e,%edx
  8006f1:	76 0e                	jbe    800701 <vprintfmt+0x208>
					putch('?', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	57                   	push   %edi
  8006f7:	6a 3f                	push   $0x3f
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 0b                	jmp    80070c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	50                   	push   %eax
  800706:	ff 55 08             	call   *0x8(%ebp)
  800709:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070c:	ff 4d e4             	decl   -0x1c(%ebp)
  80070f:	0f be 03             	movsbl (%ebx),%eax
  800712:	85 c0                	test   %eax,%eax
  800714:	74 03                	je     800719 <vprintfmt+0x220>
  800716:	43                   	inc    %ebx
  800717:	eb 1b                	jmp    800734 <vprintfmt+0x23b>
  800719:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800720:	7f 1e                	jg     800740 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800725:	e9 f3 fd ff ff       	jmp    80051d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80072d:	43                   	inc    %ebx
  80072e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800731:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800734:	85 f6                	test   %esi,%esi
  800736:	78 ad                	js     8006e5 <vprintfmt+0x1ec>
  800738:	4e                   	dec    %esi
  800739:	79 aa                	jns    8006e5 <vprintfmt+0x1ec>
  80073b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80073e:	eb dc                	jmp    80071c <vprintfmt+0x223>
  800740:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	57                   	push   %edi
  800747:	6a 20                	push   $0x20
  800749:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074c:	4b                   	dec    %ebx
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 db                	test   %ebx,%ebx
  800752:	7f ef                	jg     800743 <vprintfmt+0x24a>
  800754:	e9 c4 fd ff ff       	jmp    80051d <vprintfmt+0x24>
  800759:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 2a fd ff ff       	call   800490 <getint>
  800766:	89 c3                	mov    %eax,%ebx
  800768:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80076a:	85 d2                	test   %edx,%edx
  80076c:	78 0a                	js     800778 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 b0 00 00 00       	jmp    800828 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	57                   	push   %edi
  80077c:	6a 2d                	push   $0x2d
  80077e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800781:	f7 db                	neg    %ebx
  800783:	83 d6 00             	adc    $0x0,%esi
  800786:	f7 de                	neg    %esi
  800788:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80078b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800790:	e9 93 00 00 00       	jmp    800828 <vprintfmt+0x32f>
  800795:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800798:	89 ca                	mov    %ecx,%edx
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
  80079d:	e8 b4 fc ff ff       	call   800456 <getuint>
  8007a2:	89 c3                	mov    %eax,%ebx
  8007a4:	89 d6                	mov    %edx,%esi
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007ab:	eb 7b                	jmp    800828 <vprintfmt+0x32f>
  8007ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007b0:	89 ca                	mov    %ecx,%edx
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 d6 fc ff ff       	call   800490 <getint>
  8007ba:	89 c3                	mov    %eax,%ebx
  8007bc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	78 07                	js     8007c9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007c7:	eb 5f                	jmp    800828 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	57                   	push   %edi
  8007cd:	6a 2d                	push   $0x2d
  8007cf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007d2:	f7 db                	neg    %ebx
  8007d4:	83 d6 00             	adc    $0x0,%esi
  8007d7:	f7 de                	neg    %esi
  8007d9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e1:	eb 45                	jmp    800828 <vprintfmt+0x32f>
  8007e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	57                   	push   %edi
  8007ea:	6a 30                	push   $0x30
  8007ec:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ef:	83 c4 08             	add    $0x8,%esp
  8007f2:	57                   	push   %edi
  8007f3:	6a 78                	push   $0x78
  8007f5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800801:	8b 18                	mov    (%eax),%ebx
  800803:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800808:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800810:	eb 16                	jmp    800828 <vprintfmt+0x32f>
  800812:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800815:	89 ca                	mov    %ecx,%edx
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
  80081a:	e8 37 fc ff ff       	call   800456 <getuint>
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	89 d6                	mov    %edx,%esi
			base = 16;
  800823:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80082f:	52                   	push   %edx
  800830:	ff 75 e4             	pushl  -0x1c(%ebp)
  800833:	50                   	push   %eax
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	89 fa                	mov    %edi,%edx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	e8 68 fb ff ff       	call   8003a8 <printnum>
			break;
  800840:	83 c4 20             	add    $0x20,%esp
  800843:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800846:	e9 d2 fc ff ff       	jmp    80051d <vprintfmt+0x24>
  80084b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	57                   	push   %edi
  800852:	52                   	push   %edx
  800853:	ff 55 08             	call   *0x8(%ebp)
			break;
  800856:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80085c:	e9 bc fc ff ff       	jmp    80051d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	57                   	push   %edi
  800865:	6a 25                	push   $0x25
  800867:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	eb 02                	jmp    800871 <vprintfmt+0x378>
  80086f:	89 c6                	mov    %eax,%esi
  800871:	8d 46 ff             	lea    -0x1(%esi),%eax
  800874:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800878:	75 f5                	jne    80086f <vprintfmt+0x376>
  80087a:	e9 9e fc ff ff       	jmp    80051d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 26                	je     8008ce <vsnprintf+0x47>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 29                	jle    8008d5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	ff 75 14             	pushl  0x14(%ebp)
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	68 c2 04 80 00       	push   $0x8004c2
  8008bb:	e8 39 fc ff ff       	call   8004f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	eb 0c                	jmp    8008da <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d3:	eb 05                	jmp    8008da <vsnprintf+0x53>
  8008d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e5:	50                   	push   %eax
  8008e6:	ff 75 10             	pushl  0x10(%ebp)
  8008e9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ec:	ff 75 08             	pushl  0x8(%ebp)
  8008ef:	e8 93 ff ff ff       	call   800887 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    
	...

008008f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fe:	80 3a 00             	cmpb   $0x0,(%edx)
  800901:	74 0e                	je     800911 <strlen+0x19>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800908:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800909:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090d:	75 f9                	jne    800908 <strlen+0x10>
  80090f:	eb 05                	jmp    800916 <strlen+0x1e>
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	85 d2                	test   %edx,%edx
  800923:	74 17                	je     80093c <strnlen+0x24>
  800925:	80 39 00             	cmpb   $0x0,(%ecx)
  800928:	74 19                	je     800943 <strnlen+0x2b>
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80092f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	39 d0                	cmp    %edx,%eax
  800932:	74 14                	je     800948 <strnlen+0x30>
  800934:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800938:	75 f5                	jne    80092f <strnlen+0x17>
  80093a:	eb 0c                	jmp    800948 <strnlen+0x30>
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	eb 05                	jmp    800948 <strnlen+0x30>
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
  800959:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80095c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80095f:	42                   	inc    %edx
  800960:	84 c9                	test   %cl,%cl
  800962:	75 f5                	jne    800959 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096e:	53                   	push   %ebx
  80096f:	e8 84 ff ff ff       	call   8008f8 <strlen>
  800974:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80097d:	50                   	push   %eax
  80097e:	e8 c7 ff ff ff       	call   80094a <strcpy>
	return dst;
}
  800983:	89 d8                	mov    %ebx,%eax
  800985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	85 f6                	test   %esi,%esi
  80099a:	74 15                	je     8009b1 <strncpy+0x27>
  80099c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009a1:	8a 1a                	mov    (%edx),%bl
  8009a3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a6:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	41                   	inc    %ecx
  8009ad:	39 ce                	cmp    %ecx,%esi
  8009af:	77 f0                	ja     8009a1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	57                   	push   %edi
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c4:	85 f6                	test   %esi,%esi
  8009c6:	74 32                	je     8009fa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009c8:	83 fe 01             	cmp    $0x1,%esi
  8009cb:	74 22                	je     8009ef <strlcpy+0x3a>
  8009cd:	8a 0b                	mov    (%ebx),%cl
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 20                	je     8009f3 <strlcpy+0x3e>
  8009d3:	89 f8                	mov    %edi,%eax
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009da:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009dd:	88 08                	mov    %cl,(%eax)
  8009df:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e0:	39 f2                	cmp    %esi,%edx
  8009e2:	74 11                	je     8009f5 <strlcpy+0x40>
  8009e4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009e8:	42                   	inc    %edx
  8009e9:	84 c9                	test   %cl,%cl
  8009eb:	75 f0                	jne    8009dd <strlcpy+0x28>
  8009ed:	eb 06                	jmp    8009f5 <strlcpy+0x40>
  8009ef:	89 f8                	mov    %edi,%eax
  8009f1:	eb 02                	jmp    8009f5 <strlcpy+0x40>
  8009f3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f5:	c6 00 00             	movb   $0x0,(%eax)
  8009f8:	eb 02                	jmp    8009fc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fa:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009fc:	29 f8                	sub    %edi,%eax
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0c:	8a 01                	mov    (%ecx),%al
  800a0e:	84 c0                	test   %al,%al
  800a10:	74 10                	je     800a22 <strcmp+0x1f>
  800a12:	3a 02                	cmp    (%edx),%al
  800a14:	75 0c                	jne    800a22 <strcmp+0x1f>
		p++, q++;
  800a16:	41                   	inc    %ecx
  800a17:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a18:	8a 01                	mov    (%ecx),%al
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 04                	je     800a22 <strcmp+0x1f>
  800a1e:	3a 02                	cmp    (%edx),%al
  800a20:	74 f4                	je     800a16 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a22:	0f b6 c0             	movzbl %al,%eax
  800a25:	0f b6 12             	movzbl (%edx),%edx
  800a28:	29 d0                	sub    %edx,%eax
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	53                   	push   %ebx
  800a30:	8b 55 08             	mov    0x8(%ebp),%edx
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a36:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	74 1b                	je     800a58 <strncmp+0x2c>
  800a3d:	8a 1a                	mov    (%edx),%bl
  800a3f:	84 db                	test   %bl,%bl
  800a41:	74 24                	je     800a67 <strncmp+0x3b>
  800a43:	3a 19                	cmp    (%ecx),%bl
  800a45:	75 20                	jne    800a67 <strncmp+0x3b>
  800a47:	48                   	dec    %eax
  800a48:	74 15                	je     800a5f <strncmp+0x33>
		n--, p++, q++;
  800a4a:	42                   	inc    %edx
  800a4b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4c:	8a 1a                	mov    (%edx),%bl
  800a4e:	84 db                	test   %bl,%bl
  800a50:	74 15                	je     800a67 <strncmp+0x3b>
  800a52:	3a 19                	cmp    (%ecx),%bl
  800a54:	74 f1                	je     800a47 <strncmp+0x1b>
  800a56:	eb 0f                	jmp    800a67 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5d:	eb 05                	jmp    800a64 <strncmp+0x38>
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a64:	5b                   	pop    %ebx
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a67:	0f b6 02             	movzbl (%edx),%eax
  800a6a:	0f b6 11             	movzbl (%ecx),%edx
  800a6d:	29 d0                	sub    %edx,%eax
  800a6f:	eb f3                	jmp    800a64 <strncmp+0x38>

00800a71 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7a:	8a 10                	mov    (%eax),%dl
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	74 18                	je     800a98 <strchr+0x27>
		if (*s == c)
  800a80:	38 ca                	cmp    %cl,%dl
  800a82:	75 06                	jne    800a8a <strchr+0x19>
  800a84:	eb 17                	jmp    800a9d <strchr+0x2c>
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 13                	je     800a9d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	40                   	inc    %eax
  800a8b:	8a 10                	mov    (%eax),%dl
  800a8d:	84 d2                	test   %dl,%dl
  800a8f:	75 f5                	jne    800a86 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	eb 05                	jmp    800a9d <strchr+0x2c>
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aa8:	8a 10                	mov    (%eax),%dl
  800aaa:	84 d2                	test   %dl,%dl
  800aac:	74 11                	je     800abf <strfind+0x20>
		if (*s == c)
  800aae:	38 ca                	cmp    %cl,%dl
  800ab0:	75 06                	jne    800ab8 <strfind+0x19>
  800ab2:	eb 0b                	jmp    800abf <strfind+0x20>
  800ab4:	38 ca                	cmp    %cl,%dl
  800ab6:	74 07                	je     800abf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ab8:	40                   	inc    %eax
  800ab9:	8a 10                	mov    (%eax),%dl
  800abb:	84 d2                	test   %dl,%dl
  800abd:	75 f5                	jne    800ab4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 30                	je     800b04 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 25                	jne    800b01 <memset+0x40>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 20                	jne    800b01 <memset+0x40>
		c &= 0xFF;
  800ae1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	c1 e3 08             	shl    $0x8,%ebx
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	c1 e6 18             	shl    $0x18,%esi
  800aee:	89 d0                	mov    %edx,%eax
  800af0:	c1 e0 10             	shl    $0x10,%eax
  800af3:	09 f0                	or     %esi,%eax
  800af5:	09 d0                	or     %edx,%eax
  800af7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800afc:	fc                   	cld    
  800afd:	f3 ab                	rep stos %eax,%es:(%edi)
  800aff:	eb 03                	jmp    800b04 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b19:	39 c6                	cmp    %eax,%esi
  800b1b:	73 34                	jae    800b51 <memmove+0x46>
  800b1d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b20:	39 d0                	cmp    %edx,%eax
  800b22:	73 2d                	jae    800b51 <memmove+0x46>
		s += n;
		d += n;
  800b24:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b27:	f6 c2 03             	test   $0x3,%dl
  800b2a:	75 1b                	jne    800b47 <memmove+0x3c>
  800b2c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b32:	75 13                	jne    800b47 <memmove+0x3c>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0e                	jne    800b47 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b39:	83 ef 04             	sub    $0x4,%edi
  800b3c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b42:	fd                   	std    
  800b43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b45:	eb 07                	jmp    800b4e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b47:	4f                   	dec    %edi
  800b48:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4b:	fd                   	std    
  800b4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4e:	fc                   	cld    
  800b4f:	eb 20                	jmp    800b71 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b57:	75 13                	jne    800b6c <memmove+0x61>
  800b59:	a8 03                	test   $0x3,%al
  800b5b:	75 0f                	jne    800b6c <memmove+0x61>
  800b5d:	f6 c1 03             	test   $0x3,%cl
  800b60:	75 0a                	jne    800b6c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b62:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	fc                   	cld    
  800b68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6a:	eb 05                	jmp    800b71 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b78:	ff 75 10             	pushl  0x10(%ebp)
  800b7b:	ff 75 0c             	pushl  0xc(%ebp)
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 85 ff ff ff       	call   800b0b <memmove>
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b94:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b97:	85 ff                	test   %edi,%edi
  800b99:	74 32                	je     800bcd <memcmp+0x45>
		if (*s1 != *s2)
  800b9b:	8a 03                	mov    (%ebx),%al
  800b9d:	8a 0e                	mov    (%esi),%cl
  800b9f:	38 c8                	cmp    %cl,%al
  800ba1:	74 19                	je     800bbc <memcmp+0x34>
  800ba3:	eb 0d                	jmp    800bb2 <memcmp+0x2a>
  800ba5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800ba9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bad:	42                   	inc    %edx
  800bae:	38 c8                	cmp    %cl,%al
  800bb0:	74 10                	je     800bc2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bb2:	0f b6 c0             	movzbl %al,%eax
  800bb5:	0f b6 c9             	movzbl %cl,%ecx
  800bb8:	29 c8                	sub    %ecx,%eax
  800bba:	eb 16                	jmp    800bd2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbc:	4f                   	dec    %edi
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	39 fa                	cmp    %edi,%edx
  800bc4:	75 df                	jne    800ba5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	eb 05                	jmp    800bd2 <memcmp+0x4a>
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be2:	39 d0                	cmp    %edx,%eax
  800be4:	73 12                	jae    800bf8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800be9:	38 08                	cmp    %cl,(%eax)
  800beb:	75 06                	jne    800bf3 <memfind+0x1c>
  800bed:	eb 09                	jmp    800bf8 <memfind+0x21>
  800bef:	38 08                	cmp    %cl,(%eax)
  800bf1:	74 05                	je     800bf8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf3:	40                   	inc    %eax
  800bf4:	39 c2                	cmp    %eax,%edx
  800bf6:	77 f7                	ja     800bef <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c06:	eb 01                	jmp    800c09 <strtol+0xf>
		s++;
  800c08:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c09:	8a 02                	mov    (%edx),%al
  800c0b:	3c 20                	cmp    $0x20,%al
  800c0d:	74 f9                	je     800c08 <strtol+0xe>
  800c0f:	3c 09                	cmp    $0x9,%al
  800c11:	74 f5                	je     800c08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c13:	3c 2b                	cmp    $0x2b,%al
  800c15:	75 08                	jne    800c1f <strtol+0x25>
		s++;
  800c17:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c18:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1d:	eb 13                	jmp    800c32 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1f:	3c 2d                	cmp    $0x2d,%al
  800c21:	75 0a                	jne    800c2d <strtol+0x33>
		s++, neg = 1;
  800c23:	8d 52 01             	lea    0x1(%edx),%edx
  800c26:	bf 01 00 00 00       	mov    $0x1,%edi
  800c2b:	eb 05                	jmp    800c32 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c32:	85 db                	test   %ebx,%ebx
  800c34:	74 05                	je     800c3b <strtol+0x41>
  800c36:	83 fb 10             	cmp    $0x10,%ebx
  800c39:	75 28                	jne    800c63 <strtol+0x69>
  800c3b:	8a 02                	mov    (%edx),%al
  800c3d:	3c 30                	cmp    $0x30,%al
  800c3f:	75 10                	jne    800c51 <strtol+0x57>
  800c41:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c45:	75 0a                	jne    800c51 <strtol+0x57>
		s += 2, base = 16;
  800c47:	83 c2 02             	add    $0x2,%edx
  800c4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4f:	eb 12                	jmp    800c63 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c51:	85 db                	test   %ebx,%ebx
  800c53:	75 0e                	jne    800c63 <strtol+0x69>
  800c55:	3c 30                	cmp    $0x30,%al
  800c57:	75 05                	jne    800c5e <strtol+0x64>
		s++, base = 8;
  800c59:	42                   	inc    %edx
  800c5a:	b3 08                	mov    $0x8,%bl
  800c5c:	eb 05                	jmp    800c63 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6a:	8a 0a                	mov    (%edx),%cl
  800c6c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c6f:	80 fb 09             	cmp    $0x9,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x82>
			dig = *s - '0';
  800c74:	0f be c9             	movsbl %cl,%ecx
  800c77:	83 e9 30             	sub    $0x30,%ecx
  800c7a:	eb 1e                	jmp    800c9a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c7c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x92>
			dig = *s - 'a' + 10;
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 57             	sub    $0x57,%ecx
  800c8a:	eb 0e                	jmp    800c9a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c8c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c8f:	80 fb 19             	cmp    $0x19,%bl
  800c92:	77 13                	ja     800ca7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c94:	0f be c9             	movsbl %cl,%ecx
  800c97:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9a:	39 f1                	cmp    %esi,%ecx
  800c9c:	7d 0d                	jge    800cab <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c9e:	42                   	inc    %edx
  800c9f:	0f af c6             	imul   %esi,%eax
  800ca2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ca5:	eb c3                	jmp    800c6a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ca7:	89 c1                	mov    %eax,%ecx
  800ca9:	eb 02                	jmp    800cad <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cab:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb1:	74 05                	je     800cb8 <strtol+0xbe>
		*endptr = (char *) s;
  800cb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cb8:	85 ff                	test   %edi,%edi
  800cba:	74 04                	je     800cc0 <strtol+0xc6>
  800cbc:	89 c8                	mov    %ecx,%eax
  800cbe:	f7 d8                	neg    %eax
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    
  800cc5:	00 00                	add    %al,(%eax)
	...

00800cc8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	83 ec 10             	sub    $0x10,%esp
  800cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cd6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cdc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cdf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	75 2e                	jne    800d14 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ce6:	39 f1                	cmp    %esi,%ecx
  800ce8:	77 5a                	ja     800d44 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cea:	85 c9                	test   %ecx,%ecx
  800cec:	75 0b                	jne    800cf9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cee:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf3:	31 d2                	xor    %edx,%edx
  800cf5:	f7 f1                	div    %ecx
  800cf7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf9:	31 d2                	xor    %edx,%edx
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	f7 f1                	div    %ecx
  800cff:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d01:	89 f8                	mov    %edi,%eax
  800d03:	f7 f1                	div    %ecx
  800d05:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d0b:	83 c4 10             	add    $0x10,%esp
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    
  800d12:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d14:	39 f0                	cmp    %esi,%eax
  800d16:	77 1c                	ja     800d34 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d18:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d1b:	83 f7 1f             	xor    $0x1f,%edi
  800d1e:	75 3c                	jne    800d5c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d20:	39 f0                	cmp    %esi,%eax
  800d22:	0f 82 90 00 00 00    	jb     800db8 <__udivdi3+0xf0>
  800d28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d2b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d2e:	0f 86 84 00 00 00    	jbe    800db8 <__udivdi3+0xf0>
  800d34:	31 f6                	xor    %esi,%esi
  800d36:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d38:	89 f8                	mov    %edi,%eax
  800d3a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    
  800d43:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d44:	89 f2                	mov    %esi,%edx
  800d46:	89 f8                	mov    %edi,%eax
  800d48:	f7 f1                	div    %ecx
  800d4a:	89 c7                	mov    %eax,%edi
  800d4c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    
  800d59:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d5c:	89 f9                	mov    %edi,%ecx
  800d5e:	d3 e0                	shl    %cl,%eax
  800d60:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d63:	b8 20 00 00 00       	mov    $0x20,%eax
  800d68:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6d:	88 c1                	mov    %al,%cl
  800d6f:	d3 ea                	shr    %cl,%edx
  800d71:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d74:	09 ca                	or     %ecx,%edx
  800d76:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d7c:	89 f9                	mov    %edi,%ecx
  800d7e:	d3 e2                	shl    %cl,%edx
  800d80:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d83:	89 f2                	mov    %esi,%edx
  800d85:	88 c1                	mov    %al,%cl
  800d87:	d3 ea                	shr    %cl,%edx
  800d89:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d8c:	89 f2                	mov    %esi,%edx
  800d8e:	89 f9                	mov    %edi,%ecx
  800d90:	d3 e2                	shl    %cl,%edx
  800d92:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d95:	88 c1                	mov    %al,%cl
  800d97:	d3 ee                	shr    %cl,%esi
  800d99:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d9b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d9e:	89 f0                	mov    %esi,%eax
  800da0:	89 ca                	mov    %ecx,%edx
  800da2:	f7 75 ec             	divl   -0x14(%ebp)
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800da9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dac:	39 d1                	cmp    %edx,%ecx
  800dae:	72 28                	jb     800dd8 <__udivdi3+0x110>
  800db0:	74 1a                	je     800dcc <__udivdi3+0x104>
  800db2:	89 f7                	mov    %esi,%edi
  800db4:	31 f6                	xor    %esi,%esi
  800db6:	eb 80                	jmp    800d38 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800db8:	31 f6                	xor    %esi,%esi
  800dba:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    
  800dca:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dcf:	89 f9                	mov    %edi,%ecx
  800dd1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd3:	39 c2                	cmp    %eax,%edx
  800dd5:	73 db                	jae    800db2 <__udivdi3+0xea>
  800dd7:	90                   	nop
		{
		  q0--;
  800dd8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ddb:	31 f6                	xor    %esi,%esi
  800ddd:	e9 56 ff ff ff       	jmp    800d38 <__udivdi3+0x70>
	...

00800de4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	83 ec 20             	sub    $0x20,%esp
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800df2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800df5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800df8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e01:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e03:	85 ff                	test   %edi,%edi
  800e05:	75 15                	jne    800e1c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e07:	39 f1                	cmp    %esi,%ecx
  800e09:	0f 86 99 00 00 00    	jbe    800ea8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e0f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e11:	89 d0                	mov    %edx,%eax
  800e13:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e15:	83 c4 20             	add    $0x20,%esp
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e1c:	39 f7                	cmp    %esi,%edi
  800e1e:	0f 87 a4 00 00 00    	ja     800ec8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e24:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e27:	83 f0 1f             	xor    $0x1f,%eax
  800e2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e2d:	0f 84 a1 00 00 00    	je     800ed4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e33:	89 f8                	mov    %edi,%eax
  800e35:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e38:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e3f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 ea                	shr    %cl,%edx
  800e49:	09 c2                	or     %eax,%edx
  800e4b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e54:	d3 e0                	shl    %cl,%eax
  800e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e59:	89 f2                	mov    %esi,%edx
  800e5b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e60:	d3 e0                	shl    %cl,%eax
  800e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e68:	89 f9                	mov    %edi,%ecx
  800e6a:	d3 e8                	shr    %cl,%eax
  800e6c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e6e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e70:	89 f2                	mov    %esi,%edx
  800e72:	f7 75 f0             	divl   -0x10(%ebp)
  800e75:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e77:	f7 65 f4             	mull   -0xc(%ebp)
  800e7a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e7d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e7f:	39 d6                	cmp    %edx,%esi
  800e81:	72 71                	jb     800ef4 <__umoddi3+0x110>
  800e83:	74 7f                	je     800f04 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e88:	29 c8                	sub    %ecx,%eax
  800e8a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e8c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e8f:	d3 e8                	shr    %cl,%eax
  800e91:	89 f2                	mov    %esi,%edx
  800e93:	89 f9                	mov    %edi,%ecx
  800e95:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e97:	09 d0                	or     %edx,%eax
  800e99:	89 f2                	mov    %esi,%edx
  800e9b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e9e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea0:	83 c4 20             	add    $0x20,%esp
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    
  800ea7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea8:	85 c9                	test   %ecx,%ecx
  800eaa:	75 0b                	jne    800eb7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eac:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb1:	31 d2                	xor    %edx,%edx
  800eb3:	f7 f1                	div    %ecx
  800eb5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	31 d2                	xor    %edx,%edx
  800ebb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec0:	f7 f1                	div    %ecx
  800ec2:	e9 4a ff ff ff       	jmp    800e11 <__umoddi3+0x2d>
  800ec7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ec8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eca:	83 c4 20             	add    $0x20,%esp
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    
  800ed1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed4:	39 f7                	cmp    %esi,%edi
  800ed6:	72 05                	jb     800edd <__umoddi3+0xf9>
  800ed8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800edb:	77 0c                	ja     800ee9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800edd:	89 f2                	mov    %esi,%edx
  800edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee2:	29 c8                	sub    %ecx,%eax
  800ee4:	19 fa                	sbb    %edi,%edx
  800ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eec:	83 c4 20             	add    $0x20,%esp
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ef7:	89 c1                	mov    %eax,%ecx
  800ef9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800efc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800eff:	eb 84                	jmp    800e85 <__umoddi3+0xa1>
  800f01:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f04:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f07:	72 eb                	jb     800ef4 <__umoddi3+0x110>
  800f09:	89 f2                	mov    %esi,%edx
  800f0b:	e9 75 ff ff ff       	jmp    800e85 <__umoddi3+0xa1>
