
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
  800047:	e8 0d 01 00 00       	call   800159 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	29 d0                	sub    %edx,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 f6                	test   %esi,%esi
  800069:	7e 07                	jle    800072 <libmain+0x36>
		binaryname = argv[0];
  80006b:	8b 03                	mov    (%ebx),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	c9                   	leave  
  80008a:	c3                   	ret    
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
  8000d2:	68 0a 0f 80 00       	push   $0x800f0a
  8000d7:	6a 42                	push   $0x42
  8000d9:	68 27 0f 80 00       	push   $0x800f27
  8000de:	e8 bd 01 00 00       	call   8002a0 <_panic>

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
	...

008002a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002ae:	e8 a6 fe ff ff       	call   800159 <sys_getenvid>
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	53                   	push   %ebx
  8002bd:	50                   	push   %eax
  8002be:	68 38 0f 80 00       	push   $0x800f38
  8002c3:	e8 b0 00 00 00       	call   800378 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c8:	83 c4 18             	add    $0x18,%esp
  8002cb:	56                   	push   %esi
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	e8 53 00 00 00       	call   800327 <vcprintf>
	cprintf("\n");
  8002d4:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  8002db:	e8 98 00 00 00       	call   800378 <cprintf>
  8002e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e3:	cc                   	int3   
  8002e4:	eb fd                	jmp    8002e3 <_panic+0x43>
	...

008002e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 04             	sub    $0x4,%esp
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f2:	8b 03                	mov    (%ebx),%eax
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002fb:	40                   	inc    %eax
  8002fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800303:	75 1a                	jne    80031f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	68 ff 00 00 00       	push   $0xff
  80030d:	8d 43 08             	lea    0x8(%ebx),%eax
  800310:	50                   	push   %eax
  800311:	e8 d7 fd ff ff       	call   8000ed <sys_cputs>
		b->idx = 0;
  800316:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80031f:	ff 43 04             	incl   0x4(%ebx)
}
  800322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800330:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800337:	00 00 00 
	b.cnt = 0;
  80033a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800341:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800344:	ff 75 0c             	pushl  0xc(%ebp)
  800347:	ff 75 08             	pushl  0x8(%ebp)
  80034a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800350:	50                   	push   %eax
  800351:	68 e8 02 80 00       	push   $0x8002e8
  800356:	e8 82 01 00 00       	call   8004dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035b:	83 c4 08             	add    $0x8,%esp
  80035e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800364:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036a:	50                   	push   %eax
  80036b:	e8 7d fd ff ff       	call   8000ed <sys_cputs>

	return b.cnt;
}
  800370:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 08             	pushl  0x8(%ebp)
  800385:	e8 9d ff ff ff       	call   800327 <vcprintf>
	va_end(ap);

	return cnt;
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 2c             	sub    $0x2c,%esp
  800395:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800398:	89 d6                	mov    %edx,%esi
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ac:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003b9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003bc:	72 0c                	jb     8003ca <printnum+0x3e>
  8003be:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003c1:	76 07                	jbe    8003ca <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c3:	4b                   	dec    %ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7f 31                	jg     8003f9 <printnum+0x6d>
  8003c8:	eb 3f                	jmp    800409 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ca:	83 ec 0c             	sub    $0xc,%esp
  8003cd:	57                   	push   %edi
  8003ce:	4b                   	dec    %ebx
  8003cf:	53                   	push   %ebx
  8003d0:	50                   	push   %eax
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003da:	ff 75 dc             	pushl  -0x24(%ebp)
  8003dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e0:	e8 c7 08 00 00       	call   800cac <__udivdi3>
  8003e5:	83 c4 18             	add    $0x18,%esp
  8003e8:	52                   	push   %edx
  8003e9:	50                   	push   %eax
  8003ea:	89 f2                	mov    %esi,%edx
  8003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ef:	e8 98 ff ff ff       	call   80038c <printnum>
  8003f4:	83 c4 20             	add    $0x20,%esp
  8003f7:	eb 10                	jmp    800409 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	56                   	push   %esi
  8003fd:	57                   	push   %edi
  8003fe:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800401:	4b                   	dec    %ebx
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	85 db                	test   %ebx,%ebx
  800407:	7f f0                	jg     8003f9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	56                   	push   %esi
  80040d:	83 ec 04             	sub    $0x4,%esp
  800410:	ff 75 d4             	pushl  -0x2c(%ebp)
  800413:	ff 75 d0             	pushl  -0x30(%ebp)
  800416:	ff 75 dc             	pushl  -0x24(%ebp)
  800419:	ff 75 d8             	pushl  -0x28(%ebp)
  80041c:	e8 a7 09 00 00       	call   800dc8 <__umoddi3>
  800421:	83 c4 14             	add    $0x14,%esp
  800424:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  80042b:	50                   	push   %eax
  80042c:	ff 55 e4             	call   *-0x1c(%ebp)
  80042f:	83 c4 10             	add    $0x10,%esp
}
  800432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800435:	5b                   	pop    %ebx
  800436:	5e                   	pop    %esi
  800437:	5f                   	pop    %edi
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043d:	83 fa 01             	cmp    $0x1,%edx
  800440:	7e 0e                	jle    800450 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800442:	8b 10                	mov    (%eax),%edx
  800444:	8d 4a 08             	lea    0x8(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 02                	mov    (%edx),%eax
  80044b:	8b 52 04             	mov    0x4(%edx),%edx
  80044e:	eb 22                	jmp    800472 <getuint+0x38>
	else if (lflag)
  800450:	85 d2                	test   %edx,%edx
  800452:	74 10                	je     800464 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800454:	8b 10                	mov    (%eax),%edx
  800456:	8d 4a 04             	lea    0x4(%edx),%ecx
  800459:	89 08                	mov    %ecx,(%eax)
  80045b:	8b 02                	mov    (%edx),%eax
  80045d:	ba 00 00 00 00       	mov    $0x0,%edx
  800462:	eb 0e                	jmp    800472 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800464:	8b 10                	mov    (%eax),%edx
  800466:	8d 4a 04             	lea    0x4(%edx),%ecx
  800469:	89 08                	mov    %ecx,(%eax)
  80046b:	8b 02                	mov    (%edx),%eax
  80046d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800472:	c9                   	leave  
  800473:	c3                   	ret    

00800474 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800477:	83 fa 01             	cmp    $0x1,%edx
  80047a:	7e 0e                	jle    80048a <getint+0x16>
		return va_arg(*ap, long long);
  80047c:	8b 10                	mov    (%eax),%edx
  80047e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800481:	89 08                	mov    %ecx,(%eax)
  800483:	8b 02                	mov    (%edx),%eax
  800485:	8b 52 04             	mov    0x4(%edx),%edx
  800488:	eb 1a                	jmp    8004a4 <getint+0x30>
	else if (lflag)
  80048a:	85 d2                	test   %edx,%edx
  80048c:	74 0c                	je     80049a <getint+0x26>
		return va_arg(*ap, long);
  80048e:	8b 10                	mov    (%eax),%edx
  800490:	8d 4a 04             	lea    0x4(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	99                   	cltd   
  800498:	eb 0a                	jmp    8004a4 <getint+0x30>
	else
		return va_arg(*ap, int);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	99                   	cltd   
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ac:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004af:	8b 10                	mov    (%eax),%edx
  8004b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b4:	73 08                	jae    8004be <sprintputch+0x18>
		*b->buf++ = ch;
  8004b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b9:	88 0a                	mov    %cl,(%edx)
  8004bb:	42                   	inc    %edx
  8004bc:	89 10                	mov    %edx,(%eax)
}
  8004be:	c9                   	leave  
  8004bf:	c3                   	ret    

008004c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c9:	50                   	push   %eax
  8004ca:	ff 75 10             	pushl  0x10(%ebp)
  8004cd:	ff 75 0c             	pushl  0xc(%ebp)
  8004d0:	ff 75 08             	pushl  0x8(%ebp)
  8004d3:	e8 05 00 00 00       	call   8004dd <vprintfmt>
	va_end(ap);
  8004d8:	83 c4 10             	add    $0x10,%esp
}
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    

008004dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	57                   	push   %edi
  8004e1:	56                   	push   %esi
  8004e2:	53                   	push   %ebx
  8004e3:	83 ec 2c             	sub    $0x2c,%esp
  8004e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8004ec:	eb 13                	jmp    800501 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	0f 84 6d 03 00 00    	je     800863 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	57                   	push   %edi
  8004fa:	50                   	push   %eax
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800501:	0f b6 06             	movzbl (%esi),%eax
  800504:	46                   	inc    %esi
  800505:	83 f8 25             	cmp    $0x25,%eax
  800508:	75 e4                	jne    8004ee <vprintfmt+0x11>
  80050a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80050e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800515:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80051c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800523:	b9 00 00 00 00       	mov    $0x0,%ecx
  800528:	eb 28                	jmp    800552 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80052c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800530:	eb 20                	jmp    800552 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800534:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800538:	eb 18                	jmp    800552 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80053c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800543:	eb 0d                	jmp    800552 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800545:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800548:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8a 06                	mov    (%esi),%al
  800554:	0f b6 d0             	movzbl %al,%edx
  800557:	8d 5e 01             	lea    0x1(%esi),%ebx
  80055a:	83 e8 23             	sub    $0x23,%eax
  80055d:	3c 55                	cmp    $0x55,%al
  80055f:	0f 87 e0 02 00 00    	ja     800845 <vprintfmt+0x368>
  800565:	0f b6 c0             	movzbl %al,%eax
  800568:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056f:	83 ea 30             	sub    $0x30,%edx
  800572:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800575:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800578:	8d 50 d0             	lea    -0x30(%eax),%edx
  80057b:	83 fa 09             	cmp    $0x9,%edx
  80057e:	77 44                	ja     8005c4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	89 de                	mov    %ebx,%esi
  800582:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800585:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800586:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800589:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80058d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800590:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800593:	83 fb 09             	cmp    $0x9,%ebx
  800596:	76 ed                	jbe    800585 <vprintfmt+0xa8>
  800598:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059b:	eb 29                	jmp    8005c6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ad:	eb 17                	jmp    8005c6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b3:	78 85                	js     80053a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	89 de                	mov    %ebx,%esi
  8005b7:	eb 99                	jmp    800552 <vprintfmt+0x75>
  8005b9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005c2:	eb 8e                	jmp    800552 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ca:	79 86                	jns    800552 <vprintfmt+0x75>
  8005cc:	e9 74 ff ff ff       	jmp    800545 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	89 de                	mov    %ebx,%esi
  8005d4:	e9 79 ff ff ff       	jmp    800552 <vprintfmt+0x75>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	57                   	push   %edi
  8005e9:	ff 30                	pushl  (%eax)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f4:	e9 08 ff ff ff       	jmp    800501 <vprintfmt+0x24>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	85 c0                	test   %eax,%eax
  800609:	79 02                	jns    80060d <vprintfmt+0x130>
  80060b:	f7 d8                	neg    %eax
  80060d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060f:	83 f8 08             	cmp    $0x8,%eax
  800612:	7f 0b                	jg     80061f <vprintfmt+0x142>
  800614:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 1a                	jne    800639 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80061f:	52                   	push   %edx
  800620:	68 76 0f 80 00       	push   $0x800f76
  800625:	57                   	push   %edi
  800626:	ff 75 08             	pushl  0x8(%ebp)
  800629:	e8 92 fe ff ff       	call   8004c0 <printfmt>
  80062e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800634:	e9 c8 fe ff ff       	jmp    800501 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800639:	50                   	push   %eax
  80063a:	68 7f 0f 80 00       	push   $0x800f7f
  80063f:	57                   	push   %edi
  800640:	ff 75 08             	pushl  0x8(%ebp)
  800643:	e8 78 fe ff ff       	call   8004c0 <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80064e:	e9 ae fe ff ff       	jmp    800501 <vprintfmt+0x24>
  800653:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800656:	89 de                	mov    %ebx,%esi
  800658:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80065b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80066c:	85 c0                	test   %eax,%eax
  80066e:	75 07                	jne    800677 <vprintfmt+0x19a>
				p = "(null)";
  800670:	c7 45 d0 6f 0f 80 00 	movl   $0x800f6f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800677:	85 db                	test   %ebx,%ebx
  800679:	7e 42                	jle    8006bd <vprintfmt+0x1e0>
  80067b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80067f:	74 3c                	je     8006bd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	51                   	push   %ecx
  800685:	ff 75 d0             	pushl  -0x30(%ebp)
  800688:	e8 6f 02 00 00       	call   8008fc <strnlen>
  80068d:	29 c3                	sub    %eax,%ebx
  80068f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	85 db                	test   %ebx,%ebx
  800697:	7e 24                	jle    8006bd <vprintfmt+0x1e0>
					putch(padc, putdat);
  800699:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80069d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	57                   	push   %edi
  8006a7:	53                   	push   %ebx
  8006a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	4e                   	dec    %esi
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	85 f6                	test   %esi,%esi
  8006b1:	7f f0                	jg     8006a3 <vprintfmt+0x1c6>
  8006b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c0:	0f be 02             	movsbl (%edx),%eax
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	75 47                	jne    80070e <vprintfmt+0x231>
  8006c7:	eb 37                	jmp    800700 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cd:	74 16                	je     8006e5 <vprintfmt+0x208>
  8006cf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d2:	83 fa 5e             	cmp    $0x5e,%edx
  8006d5:	76 0e                	jbe    8006e5 <vprintfmt+0x208>
					putch('?', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 3f                	push   $0x3f
  8006dd:	ff 55 08             	call   *0x8(%ebp)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb 0b                	jmp    8006f0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	57                   	push   %edi
  8006e9:	50                   	push   %eax
  8006ea:	ff 55 08             	call   *0x8(%ebp)
  8006ed:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f0:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f3:	0f be 03             	movsbl (%ebx),%eax
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 03                	je     8006fd <vprintfmt+0x220>
  8006fa:	43                   	inc    %ebx
  8006fb:	eb 1b                	jmp    800718 <vprintfmt+0x23b>
  8006fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800700:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800704:	7f 1e                	jg     800724 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800709:	e9 f3 fd ff ff       	jmp    800501 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800711:	43                   	inc    %ebx
  800712:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800715:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800718:	85 f6                	test   %esi,%esi
  80071a:	78 ad                	js     8006c9 <vprintfmt+0x1ec>
  80071c:	4e                   	dec    %esi
  80071d:	79 aa                	jns    8006c9 <vprintfmt+0x1ec>
  80071f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800722:	eb dc                	jmp    800700 <vprintfmt+0x223>
  800724:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	57                   	push   %edi
  80072b:	6a 20                	push   $0x20
  80072d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800730:	4b                   	dec    %ebx
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	85 db                	test   %ebx,%ebx
  800736:	7f ef                	jg     800727 <vprintfmt+0x24a>
  800738:	e9 c4 fd ff ff       	jmp    800501 <vprintfmt+0x24>
  80073d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800740:	89 ca                	mov    %ecx,%edx
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 2a fd ff ff       	call   800474 <getint>
  80074a:	89 c3                	mov    %eax,%ebx
  80074c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80074e:	85 d2                	test   %edx,%edx
  800750:	78 0a                	js     80075c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
  800757:	e9 b0 00 00 00       	jmp    80080c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	57                   	push   %edi
  800760:	6a 2d                	push   $0x2d
  800762:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800765:	f7 db                	neg    %ebx
  800767:	83 d6 00             	adc    $0x0,%esi
  80076a:	f7 de                	neg    %esi
  80076c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800774:	e9 93 00 00 00       	jmp    80080c <vprintfmt+0x32f>
  800779:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077c:	89 ca                	mov    %ecx,%edx
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	e8 b4 fc ff ff       	call   80043a <getuint>
  800786:	89 c3                	mov    %eax,%ebx
  800788:	89 d6                	mov    %edx,%esi
			base = 10;
  80078a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80078f:	eb 7b                	jmp    80080c <vprintfmt+0x32f>
  800791:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800794:	89 ca                	mov    %ecx,%edx
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 d6 fc ff ff       	call   800474 <getint>
  80079e:	89 c3                	mov    %eax,%ebx
  8007a0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	78 07                	js     8007ad <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007ab:	eb 5f                	jmp    80080c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	57                   	push   %edi
  8007b1:	6a 2d                	push   $0x2d
  8007b3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007b6:	f7 db                	neg    %ebx
  8007b8:	83 d6 00             	adc    $0x0,%esi
  8007bb:	f7 de                	neg    %esi
  8007bd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007c5:	eb 45                	jmp    80080c <vprintfmt+0x32f>
  8007c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	57                   	push   %edi
  8007ce:	6a 30                	push   $0x30
  8007d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	57                   	push   %edi
  8007d7:	6a 78                	push   $0x78
  8007d9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e5:	8b 18                	mov    (%eax),%ebx
  8007e7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f4:	eb 16                	jmp    80080c <vprintfmt+0x32f>
  8007f6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f9:	89 ca                	mov    %ecx,%edx
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 37 fc ff ff       	call   80043a <getuint>
  800803:	89 c3                	mov    %eax,%ebx
  800805:	89 d6                	mov    %edx,%esi
			base = 16;
  800807:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080c:	83 ec 0c             	sub    $0xc,%esp
  80080f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800813:	52                   	push   %edx
  800814:	ff 75 e4             	pushl  -0x1c(%ebp)
  800817:	50                   	push   %eax
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	89 fa                	mov    %edi,%edx
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	e8 68 fb ff ff       	call   80038c <printnum>
			break;
  800824:	83 c4 20             	add    $0x20,%esp
  800827:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80082a:	e9 d2 fc ff ff       	jmp    800501 <vprintfmt+0x24>
  80082f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	57                   	push   %edi
  800836:	52                   	push   %edx
  800837:	ff 55 08             	call   *0x8(%ebp)
			break;
  80083a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800840:	e9 bc fc ff ff       	jmp    800501 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	57                   	push   %edi
  800849:	6a 25                	push   $0x25
  80084b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	eb 02                	jmp    800855 <vprintfmt+0x378>
  800853:	89 c6                	mov    %eax,%esi
  800855:	8d 46 ff             	lea    -0x1(%esi),%eax
  800858:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80085c:	75 f5                	jne    800853 <vprintfmt+0x376>
  80085e:	e9 9e fc ff ff       	jmp    800501 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800863:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5f                   	pop    %edi
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	83 ec 18             	sub    $0x18,%esp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800877:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80087e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800881:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800888:	85 c0                	test   %eax,%eax
  80088a:	74 26                	je     8008b2 <vsnprintf+0x47>
  80088c:	85 d2                	test   %edx,%edx
  80088e:	7e 29                	jle    8008b9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800890:	ff 75 14             	pushl  0x14(%ebp)
  800893:	ff 75 10             	pushl  0x10(%ebp)
  800896:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800899:	50                   	push   %eax
  80089a:	68 a6 04 80 00       	push   $0x8004a6
  80089f:	e8 39 fc ff ff       	call   8004dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	eb 0c                	jmp    8008be <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b7:	eb 05                	jmp    8008be <vsnprintf+0x53>
  8008b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c9:	50                   	push   %eax
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	ff 75 0c             	pushl  0xc(%ebp)
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 93 ff ff ff       	call   80086b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    
	...

008008dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e2:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e5:	74 0e                	je     8008f5 <strlen+0x19>
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008ec:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f1:	75 f9                	jne    8008ec <strlen+0x10>
  8008f3:	eb 05                	jmp    8008fa <strlen+0x1e>
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	85 d2                	test   %edx,%edx
  800907:	74 17                	je     800920 <strnlen+0x24>
  800909:	80 39 00             	cmpb   $0x0,(%ecx)
  80090c:	74 19                	je     800927 <strnlen+0x2b>
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800913:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800914:	39 d0                	cmp    %edx,%eax
  800916:	74 14                	je     80092c <strnlen+0x30>
  800918:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80091c:	75 f5                	jne    800913 <strnlen+0x17>
  80091e:	eb 0c                	jmp    80092c <strnlen+0x30>
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	eb 05                	jmp    80092c <strnlen+0x30>
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800940:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800943:	42                   	inc    %edx
  800944:	84 c9                	test   %cl,%cl
  800946:	75 f5                	jne    80093d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800948:	5b                   	pop    %ebx
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800952:	53                   	push   %ebx
  800953:	e8 84 ff ff ff       	call   8008dc <strlen>
  800958:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095b:	ff 75 0c             	pushl  0xc(%ebp)
  80095e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800961:	50                   	push   %eax
  800962:	e8 c7 ff ff ff       	call   80092e <strcpy>
	return dst;
}
  800967:	89 d8                	mov    %ebx,%eax
  800969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
  800979:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097c:	85 f6                	test   %esi,%esi
  80097e:	74 15                	je     800995 <strncpy+0x27>
  800980:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800985:	8a 1a                	mov    (%edx),%bl
  800987:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098a:	80 3a 01             	cmpb   $0x1,(%edx)
  80098d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	41                   	inc    %ecx
  800991:	39 ce                	cmp    %ecx,%esi
  800993:	77 f0                	ja     800985 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a8:	85 f6                	test   %esi,%esi
  8009aa:	74 32                	je     8009de <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009ac:	83 fe 01             	cmp    $0x1,%esi
  8009af:	74 22                	je     8009d3 <strlcpy+0x3a>
  8009b1:	8a 0b                	mov    (%ebx),%cl
  8009b3:	84 c9                	test   %cl,%cl
  8009b5:	74 20                	je     8009d7 <strlcpy+0x3e>
  8009b7:	89 f8                	mov    %edi,%eax
  8009b9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009be:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c1:	88 08                	mov    %cl,(%eax)
  8009c3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c4:	39 f2                	cmp    %esi,%edx
  8009c6:	74 11                	je     8009d9 <strlcpy+0x40>
  8009c8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009cc:	42                   	inc    %edx
  8009cd:	84 c9                	test   %cl,%cl
  8009cf:	75 f0                	jne    8009c1 <strlcpy+0x28>
  8009d1:	eb 06                	jmp    8009d9 <strlcpy+0x40>
  8009d3:	89 f8                	mov    %edi,%eax
  8009d5:	eb 02                	jmp    8009d9 <strlcpy+0x40>
  8009d7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009d9:	c6 00 00             	movb   $0x0,(%eax)
  8009dc:	eb 02                	jmp    8009e0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009de:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009e0:	29 f8                	sub    %edi,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f0:	8a 01                	mov    (%ecx),%al
  8009f2:	84 c0                	test   %al,%al
  8009f4:	74 10                	je     800a06 <strcmp+0x1f>
  8009f6:	3a 02                	cmp    (%edx),%al
  8009f8:	75 0c                	jne    800a06 <strcmp+0x1f>
		p++, q++;
  8009fa:	41                   	inc    %ecx
  8009fb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fc:	8a 01                	mov    (%ecx),%al
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 04                	je     800a06 <strcmp+0x1f>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	74 f4                	je     8009fa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 12             	movzbl (%edx),%edx
  800a0c:	29 d0                	sub    %edx,%eax
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a1d:	85 c0                	test   %eax,%eax
  800a1f:	74 1b                	je     800a3c <strncmp+0x2c>
  800a21:	8a 1a                	mov    (%edx),%bl
  800a23:	84 db                	test   %bl,%bl
  800a25:	74 24                	je     800a4b <strncmp+0x3b>
  800a27:	3a 19                	cmp    (%ecx),%bl
  800a29:	75 20                	jne    800a4b <strncmp+0x3b>
  800a2b:	48                   	dec    %eax
  800a2c:	74 15                	je     800a43 <strncmp+0x33>
		n--, p++, q++;
  800a2e:	42                   	inc    %edx
  800a2f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a30:	8a 1a                	mov    (%edx),%bl
  800a32:	84 db                	test   %bl,%bl
  800a34:	74 15                	je     800a4b <strncmp+0x3b>
  800a36:	3a 19                	cmp    (%ecx),%bl
  800a38:	74 f1                	je     800a2b <strncmp+0x1b>
  800a3a:	eb 0f                	jmp    800a4b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strncmp+0x38>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a48:	5b                   	pop    %ebx
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4b:	0f b6 02             	movzbl (%edx),%eax
  800a4e:	0f b6 11             	movzbl (%ecx),%edx
  800a51:	29 d0                	sub    %edx,%eax
  800a53:	eb f3                	jmp    800a48 <strncmp+0x38>

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a5e:	8a 10                	mov    (%eax),%dl
  800a60:	84 d2                	test   %dl,%dl
  800a62:	74 18                	je     800a7c <strchr+0x27>
		if (*s == c)
  800a64:	38 ca                	cmp    %cl,%dl
  800a66:	75 06                	jne    800a6e <strchr+0x19>
  800a68:	eb 17                	jmp    800a81 <strchr+0x2c>
  800a6a:	38 ca                	cmp    %cl,%dl
  800a6c:	74 13                	je     800a81 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6e:	40                   	inc    %eax
  800a6f:	8a 10                	mov    (%eax),%dl
  800a71:	84 d2                	test   %dl,%dl
  800a73:	75 f5                	jne    800a6a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	eb 05                	jmp    800a81 <strchr+0x2c>
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a8c:	8a 10                	mov    (%eax),%dl
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	74 11                	je     800aa3 <strfind+0x20>
		if (*s == c)
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	75 06                	jne    800a9c <strfind+0x19>
  800a96:	eb 0b                	jmp    800aa3 <strfind+0x20>
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 07                	je     800aa3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a9c:	40                   	inc    %eax
  800a9d:	8a 10                	mov    (%eax),%dl
  800a9f:	84 d2                	test   %dl,%dl
  800aa1:	75 f5                	jne    800a98 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab4:	85 c9                	test   %ecx,%ecx
  800ab6:	74 30                	je     800ae8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abe:	75 25                	jne    800ae5 <memset+0x40>
  800ac0:	f6 c1 03             	test   $0x3,%cl
  800ac3:	75 20                	jne    800ae5 <memset+0x40>
		c &= 0xFF;
  800ac5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	c1 e3 08             	shl    $0x8,%ebx
  800acd:	89 d6                	mov    %edx,%esi
  800acf:	c1 e6 18             	shl    $0x18,%esi
  800ad2:	89 d0                	mov    %edx,%eax
  800ad4:	c1 e0 10             	shl    $0x10,%eax
  800ad7:	09 f0                	or     %esi,%eax
  800ad9:	09 d0                	or     %edx,%eax
  800adb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800add:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae0:	fc                   	cld    
  800ae1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae3:	eb 03                	jmp    800ae8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae5:	fc                   	cld    
  800ae6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae8:	89 f8                	mov    %edi,%eax
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 34                	jae    800b35 <memmove+0x46>
  800b01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 2d                	jae    800b35 <memmove+0x46>
		s += n;
		d += n;
  800b08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0b:	f6 c2 03             	test   $0x3,%dl
  800b0e:	75 1b                	jne    800b2b <memmove+0x3c>
  800b10:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b16:	75 13                	jne    800b2b <memmove+0x3c>
  800b18:	f6 c1 03             	test   $0x3,%cl
  800b1b:	75 0e                	jne    800b2b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1d:	83 ef 04             	sub    $0x4,%edi
  800b20:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b23:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b26:	fd                   	std    
  800b27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b29:	eb 07                	jmp    800b32 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2b:	4f                   	dec    %edi
  800b2c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2f:	fd                   	std    
  800b30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b32:	fc                   	cld    
  800b33:	eb 20                	jmp    800b55 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b35:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3b:	75 13                	jne    800b50 <memmove+0x61>
  800b3d:	a8 03                	test   $0x3,%al
  800b3f:	75 0f                	jne    800b50 <memmove+0x61>
  800b41:	f6 c1 03             	test   $0x3,%cl
  800b44:	75 0a                	jne    800b50 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b46:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	fc                   	cld    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb 05                	jmp    800b55 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b50:	89 c7                	mov    %eax,%edi
  800b52:	fc                   	cld    
  800b53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5c:	ff 75 10             	pushl  0x10(%ebp)
  800b5f:	ff 75 0c             	pushl  0xc(%ebp)
  800b62:	ff 75 08             	pushl  0x8(%ebp)
  800b65:	e8 85 ff ff ff       	call   800aef <memmove>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b78:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	74 32                	je     800bb1 <memcmp+0x45>
		if (*s1 != *s2)
  800b7f:	8a 03                	mov    (%ebx),%al
  800b81:	8a 0e                	mov    (%esi),%cl
  800b83:	38 c8                	cmp    %cl,%al
  800b85:	74 19                	je     800ba0 <memcmp+0x34>
  800b87:	eb 0d                	jmp    800b96 <memcmp+0x2a>
  800b89:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b8d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b91:	42                   	inc    %edx
  800b92:	38 c8                	cmp    %cl,%al
  800b94:	74 10                	je     800ba6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b96:	0f b6 c0             	movzbl %al,%eax
  800b99:	0f b6 c9             	movzbl %cl,%ecx
  800b9c:	29 c8                	sub    %ecx,%eax
  800b9e:	eb 16                	jmp    800bb6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba0:	4f                   	dec    %edi
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	39 fa                	cmp    %edi,%edx
  800ba8:	75 df                	jne    800b89 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	eb 05                	jmp    800bb6 <memcmp+0x4a>
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc6:	39 d0                	cmp    %edx,%eax
  800bc8:	73 12                	jae    800bdc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bca:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bcd:	38 08                	cmp    %cl,(%eax)
  800bcf:	75 06                	jne    800bd7 <memfind+0x1c>
  800bd1:	eb 09                	jmp    800bdc <memfind+0x21>
  800bd3:	38 08                	cmp    %cl,(%eax)
  800bd5:	74 05                	je     800bdc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd7:	40                   	inc    %eax
  800bd8:	39 c2                	cmp    %eax,%edx
  800bda:	77 f7                	ja     800bd3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	eb 01                	jmp    800bed <strtol+0xf>
		s++;
  800bec:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bed:	8a 02                	mov    (%edx),%al
  800bef:	3c 20                	cmp    $0x20,%al
  800bf1:	74 f9                	je     800bec <strtol+0xe>
  800bf3:	3c 09                	cmp    $0x9,%al
  800bf5:	74 f5                	je     800bec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf7:	3c 2b                	cmp    $0x2b,%al
  800bf9:	75 08                	jne    800c03 <strtol+0x25>
		s++;
  800bfb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 13                	jmp    800c16 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c03:	3c 2d                	cmp    $0x2d,%al
  800c05:	75 0a                	jne    800c11 <strtol+0x33>
		s++, neg = 1;
  800c07:	8d 52 01             	lea    0x1(%edx),%edx
  800c0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c0f:	eb 05                	jmp    800c16 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c16:	85 db                	test   %ebx,%ebx
  800c18:	74 05                	je     800c1f <strtol+0x41>
  800c1a:	83 fb 10             	cmp    $0x10,%ebx
  800c1d:	75 28                	jne    800c47 <strtol+0x69>
  800c1f:	8a 02                	mov    (%edx),%al
  800c21:	3c 30                	cmp    $0x30,%al
  800c23:	75 10                	jne    800c35 <strtol+0x57>
  800c25:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c29:	75 0a                	jne    800c35 <strtol+0x57>
		s += 2, base = 16;
  800c2b:	83 c2 02             	add    $0x2,%edx
  800c2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c33:	eb 12                	jmp    800c47 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c35:	85 db                	test   %ebx,%ebx
  800c37:	75 0e                	jne    800c47 <strtol+0x69>
  800c39:	3c 30                	cmp    $0x30,%al
  800c3b:	75 05                	jne    800c42 <strtol+0x64>
		s++, base = 8;
  800c3d:	42                   	inc    %edx
  800c3e:	b3 08                	mov    $0x8,%bl
  800c40:	eb 05                	jmp    800c47 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4e:	8a 0a                	mov    (%edx),%cl
  800c50:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c53:	80 fb 09             	cmp    $0x9,%bl
  800c56:	77 08                	ja     800c60 <strtol+0x82>
			dig = *s - '0';
  800c58:	0f be c9             	movsbl %cl,%ecx
  800c5b:	83 e9 30             	sub    $0x30,%ecx
  800c5e:	eb 1e                	jmp    800c7e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c60:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c63:	80 fb 19             	cmp    $0x19,%bl
  800c66:	77 08                	ja     800c70 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c68:	0f be c9             	movsbl %cl,%ecx
  800c6b:	83 e9 57             	sub    $0x57,%ecx
  800c6e:	eb 0e                	jmp    800c7e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c70:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 13                	ja     800c8b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c78:	0f be c9             	movsbl %cl,%ecx
  800c7b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c7e:	39 f1                	cmp    %esi,%ecx
  800c80:	7d 0d                	jge    800c8f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c82:	42                   	inc    %edx
  800c83:	0f af c6             	imul   %esi,%eax
  800c86:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c89:	eb c3                	jmp    800c4e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c8b:	89 c1                	mov    %eax,%ecx
  800c8d:	eb 02                	jmp    800c91 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c8f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c95:	74 05                	je     800c9c <strtol+0xbe>
		*endptr = (char *) s;
  800c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c9a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c9c:	85 ff                	test   %edi,%edi
  800c9e:	74 04                	je     800ca4 <strtol+0xc6>
  800ca0:	89 c8                	mov    %ecx,%eax
  800ca2:	f7 d8                	neg    %eax
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    
  800ca9:	00 00                	add    %al,(%eax)
	...

00800cac <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	83 ec 10             	sub    $0x10,%esp
  800cb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cba:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cc3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	75 2e                	jne    800cf8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cca:	39 f1                	cmp    %esi,%ecx
  800ccc:	77 5a                	ja     800d28 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cce:	85 c9                	test   %ecx,%ecx
  800cd0:	75 0b                	jne    800cdd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd7:	31 d2                	xor    %edx,%edx
  800cd9:	f7 f1                	div    %ecx
  800cdb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cdd:	31 d2                	xor    %edx,%edx
  800cdf:	89 f0                	mov    %esi,%eax
  800ce1:	f7 f1                	div    %ecx
  800ce3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ce5:	89 f8                	mov    %edi,%eax
  800ce7:	f7 f1                	div    %ecx
  800ce9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ceb:	89 f8                	mov    %edi,%eax
  800ced:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    
  800cf6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cf8:	39 f0                	cmp    %esi,%eax
  800cfa:	77 1c                	ja     800d18 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cfc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800cff:	83 f7 1f             	xor    $0x1f,%edi
  800d02:	75 3c                	jne    800d40 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d04:	39 f0                	cmp    %esi,%eax
  800d06:	0f 82 90 00 00 00    	jb     800d9c <__udivdi3+0xf0>
  800d0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d0f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d12:	0f 86 84 00 00 00    	jbe    800d9c <__udivdi3+0xf0>
  800d18:	31 f6                	xor    %esi,%esi
  800d1a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d1c:	89 f8                	mov    %edi,%eax
  800d1e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
  800d27:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	f7 f1                	div    %ecx
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d32:	89 f8                	mov    %edi,%eax
  800d34:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    
  800d3d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d40:	89 f9                	mov    %edi,%ecx
  800d42:	d3 e0                	shl    %cl,%eax
  800d44:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d47:	b8 20 00 00 00       	mov    $0x20,%eax
  800d4c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d51:	88 c1                	mov    %al,%cl
  800d53:	d3 ea                	shr    %cl,%edx
  800d55:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d58:	09 ca                	or     %ecx,%edx
  800d5a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d60:	89 f9                	mov    %edi,%ecx
  800d62:	d3 e2                	shl    %cl,%edx
  800d64:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d67:	89 f2                	mov    %esi,%edx
  800d69:	88 c1                	mov    %al,%cl
  800d6b:	d3 ea                	shr    %cl,%edx
  800d6d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d70:	89 f2                	mov    %esi,%edx
  800d72:	89 f9                	mov    %edi,%ecx
  800d74:	d3 e2                	shl    %cl,%edx
  800d76:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d79:	88 c1                	mov    %al,%cl
  800d7b:	d3 ee                	shr    %cl,%esi
  800d7d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d7f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	89 ca                	mov    %ecx,%edx
  800d86:	f7 75 ec             	divl   -0x14(%ebp)
  800d89:	89 d1                	mov    %edx,%ecx
  800d8b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d8d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d90:	39 d1                	cmp    %edx,%ecx
  800d92:	72 28                	jb     800dbc <__udivdi3+0x110>
  800d94:	74 1a                	je     800db0 <__udivdi3+0x104>
  800d96:	89 f7                	mov    %esi,%edi
  800d98:	31 f6                	xor    %esi,%esi
  800d9a:	eb 80                	jmp    800d1c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d9c:	31 f6                	xor    %esi,%esi
  800d9e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da3:	89 f8                	mov    %edi,%eax
  800da5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    
  800dae:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800db0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db7:	39 c2                	cmp    %eax,%edx
  800db9:	73 db                	jae    800d96 <__udivdi3+0xea>
  800dbb:	90                   	nop
		{
		  q0--;
  800dbc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dbf:	31 f6                	xor    %esi,%esi
  800dc1:	e9 56 ff ff ff       	jmp    800d1c <__udivdi3+0x70>
	...

00800dc8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	83 ec 20             	sub    $0x20,%esp
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800dd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ddc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800de5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800de7:	85 ff                	test   %edi,%edi
  800de9:	75 15                	jne    800e00 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800deb:	39 f1                	cmp    %esi,%ecx
  800ded:	0f 86 99 00 00 00    	jbe    800e8c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800df5:	89 d0                	mov    %edx,%eax
  800df7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e00:	39 f7                	cmp    %esi,%edi
  800e02:	0f 87 a4 00 00 00    	ja     800eac <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e08:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e0b:	83 f0 1f             	xor    $0x1f,%eax
  800e0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e11:	0f 84 a1 00 00 00    	je     800eb8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e17:	89 f8                	mov    %edi,%eax
  800e19:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e1c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e1e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e23:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e29:	89 f9                	mov    %edi,%ecx
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	09 c2                	or     %eax,%edx
  800e2f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e35:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e38:	d3 e0                	shl    %cl,%eax
  800e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e3d:	89 f2                	mov    %esi,%edx
  800e3f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e44:	d3 e0                	shl    %cl,%eax
  800e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e4c:	89 f9                	mov    %edi,%ecx
  800e4e:	d3 e8                	shr    %cl,%eax
  800e50:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e52:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e54:	89 f2                	mov    %esi,%edx
  800e56:	f7 75 f0             	divl   -0x10(%ebp)
  800e59:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e5b:	f7 65 f4             	mull   -0xc(%ebp)
  800e5e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e61:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e63:	39 d6                	cmp    %edx,%esi
  800e65:	72 71                	jb     800ed8 <__umoddi3+0x110>
  800e67:	74 7f                	je     800ee8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e6c:	29 c8                	sub    %ecx,%eax
  800e6e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e70:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e73:	d3 e8                	shr    %cl,%eax
  800e75:	89 f2                	mov    %esi,%edx
  800e77:	89 f9                	mov    %edi,%ecx
  800e79:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e7b:	09 d0                	or     %edx,%eax
  800e7d:	89 f2                	mov    %esi,%edx
  800e7f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e82:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e84:	83 c4 20             	add    $0x20,%esp
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    
  800e8b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e8c:	85 c9                	test   %ecx,%ecx
  800e8e:	75 0b                	jne    800e9b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e90:	b8 01 00 00 00       	mov    $0x1,%eax
  800e95:	31 d2                	xor    %edx,%edx
  800e97:	f7 f1                	div    %ecx
  800e99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e9b:	89 f0                	mov    %esi,%eax
  800e9d:	31 d2                	xor    %edx,%edx
  800e9f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea4:	f7 f1                	div    %ecx
  800ea6:	e9 4a ff ff ff       	jmp    800df5 <__umoddi3+0x2d>
  800eab:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800eac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eae:	83 c4 20             	add    $0x20,%esp
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb8:	39 f7                	cmp    %esi,%edi
  800eba:	72 05                	jb     800ec1 <__umoddi3+0xf9>
  800ebc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ebf:	77 0c                	ja     800ecd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec1:	89 f2                	mov    %esi,%edx
  800ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec6:	29 c8                	sub    %ecx,%eax
  800ec8:	19 fa                	sbb    %edi,%edx
  800eca:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    
  800ed7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ed8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800edb:	89 c1                	mov    %eax,%ecx
  800edd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ee0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ee3:	eb 84                	jmp    800e69 <__umoddi3+0xa1>
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800eeb:	72 eb                	jb     800ed8 <__umoddi3+0x110>
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	e9 75 ff ff ff       	jmp    800e69 <__umoddi3+0xa1>
