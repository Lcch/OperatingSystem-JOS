
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c9                   	leave  
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004b:	e8 05 01 00 00       	call   800155 <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	c1 e0 07             	shl    $0x7,%eax
  800058:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 f6                	test   %esi,%esi
  800064:	7e 07                	jle    80006d <libmain+0x2d>
		binaryname = argv[0];
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	a3 00 20 80 00       	mov    %eax,0x802000
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
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 9e 00 00 00       	call   800133 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	83 ec 1c             	sub    $0x1c,%esp
  8000a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000ab:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b9:	cd 30                	int    $0x30
  8000bb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c1:	74 1c                	je     8000df <syscall+0x43>
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7e 18                	jle    8000df <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	50                   	push   %eax
  8000cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ce:	68 2a 0f 80 00       	push   $0x800f2a
  8000d3:	6a 42                	push   $0x42
  8000d5:	68 47 0f 80 00       	push   $0x800f47
  8000da:	e8 e1 01 00 00       	call   8002c0 <_panic>

	return ret;
}
  8000df:	89 d0                	mov    %edx,%eax
  8000e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800100:	b8 00 00 00 00       	mov    $0x0,%eax
  800105:	e8 92 ff ff ff       	call   80009c <syscall>
  80010a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <sys_cgetc>:

int
sys_cgetc(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800115:	6a 00                	push   $0x0
  800117:	6a 00                	push   $0x0
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 01 00 00 00       	mov    $0x1,%eax
  80012c:	e8 6b ff ff ff       	call   80009c <syscall>
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800144:	ba 01 00 00 00       	mov    $0x1,%edx
  800149:	b8 03 00 00 00       	mov    $0x3,%eax
  80014e:	e8 49 ff ff ff       	call   80009c <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	b9 00 00 00 00       	mov    $0x0,%ecx
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 02 00 00 00       	mov    $0x2,%eax
  800172:	e8 25 ff ff ff       	call   80009c <syscall>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <sys_yield>:

void
sys_yield(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80017f:	6a 00                	push   $0x0
  800181:	6a 00                	push   $0x0
  800183:	6a 00                	push   $0x0
  800185:	6a 00                	push   $0x0
  800187:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018c:	ba 00 00 00 00       	mov    $0x0,%edx
  800191:	b8 0a 00 00 00       	mov    $0xa,%eax
  800196:	e8 01 ff ff ff       	call   80009c <syscall>
  80019b:	83 c4 10             	add    $0x10,%esp
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001a6:	6a 00                	push   $0x0
  8001a8:	6a 00                	push   $0x0
  8001aa:	ff 75 10             	pushl  0x10(%ebp)
  8001ad:	ff 75 0c             	pushl  0xc(%ebp)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001bd:	e8 da fe ff ff       	call   80009c <syscall>
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff 75 14             	pushl  0x14(%ebp)
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	e8 b4 fe ff ff       	call   80009c <syscall>
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f0:	6a 00                	push   $0x0
  8001f2:	6a 00                	push   $0x0
  8001f4:	6a 00                	push   $0x0
  8001f6:	ff 75 0c             	pushl  0xc(%ebp)
  8001f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fc:	ba 01 00 00 00       	mov    $0x1,%edx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	e8 91 fe ff ff       	call   80009c <syscall>
}
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800213:	6a 00                	push   $0x0
  800215:	6a 00                	push   $0x0
  800217:	6a 00                	push   $0x0
  800219:	ff 75 0c             	pushl  0xc(%ebp)
  80021c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021f:	ba 01 00 00 00       	mov    $0x1,%edx
  800224:	b8 08 00 00 00       	mov    $0x8,%eax
  800229:	e8 6e fe ff ff       	call   80009c <syscall>
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800236:	6a 00                	push   $0x0
  800238:	6a 00                	push   $0x0
  80023a:	6a 00                	push   $0x0
  80023c:	ff 75 0c             	pushl  0xc(%ebp)
  80023f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800242:	ba 01 00 00 00       	mov    $0x1,%edx
  800247:	b8 09 00 00 00       	mov    $0x9,%eax
  80024c:	e8 4b fe ff ff       	call   80009c <syscall>
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800259:	6a 00                	push   $0x0
  80025b:	ff 75 14             	pushl  0x14(%ebp)
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800267:	ba 00 00 00 00       	mov    $0x0,%edx
  80026c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800271:	e8 26 fe ff ff       	call   80009c <syscall>
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80027e:	6a 00                	push   $0x0
  800280:	6a 00                	push   $0x0
  800282:	6a 00                	push   $0x0
  800284:	6a 00                	push   $0x0
  800286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800289:	ba 01 00 00 00       	mov    $0x1,%edx
  80028e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800293:	e8 04 fe ff ff       	call   80009c <syscall>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002a0:	6a 00                	push   $0x0
  8002a2:	6a 00                	push   $0x0
  8002a4:	6a 00                	push   $0x0
  8002a6:	ff 75 0c             	pushl  0xc(%ebp)
  8002a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002b6:	e8 e1 fd ff ff       	call   80009c <syscall>
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    
  8002bd:	00 00                	add    %al,(%eax)
	...

008002c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002ce:	e8 82 fe ff ff       	call   800155 <sys_getenvid>
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 0c             	pushl  0xc(%ebp)
  8002d9:	ff 75 08             	pushl  0x8(%ebp)
  8002dc:	53                   	push   %ebx
  8002dd:	50                   	push   %eax
  8002de:	68 58 0f 80 00       	push   $0x800f58
  8002e3:	e8 b0 00 00 00       	call   800398 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e8:	83 c4 18             	add    $0x18,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 10             	pushl  0x10(%ebp)
  8002ef:	e8 53 00 00 00       	call   800347 <vcprintf>
	cprintf("\n");
  8002f4:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  8002fb:	e8 98 00 00 00       	call   800398 <cprintf>
  800300:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800303:	cc                   	int3   
  800304:	eb fd                	jmp    800303 <_panic+0x43>
	...

00800308 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	53                   	push   %ebx
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800312:	8b 03                	mov    (%ebx),%eax
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80031b:	40                   	inc    %eax
  80031c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80031e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800323:	75 1a                	jne    80033f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	68 ff 00 00 00       	push   $0xff
  80032d:	8d 43 08             	lea    0x8(%ebx),%eax
  800330:	50                   	push   %eax
  800331:	e8 b3 fd ff ff       	call   8000e9 <sys_cputs>
		b->idx = 0;
  800336:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80033c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80033f:	ff 43 04             	incl   0x4(%ebx)
}
  800342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800350:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800357:	00 00 00 
	b.cnt = 0;
  80035a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800361:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800364:	ff 75 0c             	pushl  0xc(%ebp)
  800367:	ff 75 08             	pushl  0x8(%ebp)
  80036a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800370:	50                   	push   %eax
  800371:	68 08 03 80 00       	push   $0x800308
  800376:	e8 82 01 00 00       	call   8004fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037b:	83 c4 08             	add    $0x8,%esp
  80037e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800384:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80038a:	50                   	push   %eax
  80038b:	e8 59 fd ff ff       	call   8000e9 <sys_cputs>

	return b.cnt;
}
  800390:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a1:	50                   	push   %eax
  8003a2:	ff 75 08             	pushl  0x8(%ebp)
  8003a5:	e8 9d ff ff ff       	call   800347 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 2c             	sub    $0x2c,%esp
  8003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b8:	89 d6                	mov    %edx,%esi
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003cc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003dc:	72 0c                	jb     8003ea <printnum+0x3e>
  8003de:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003e1:	76 07                	jbe    8003ea <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e3:	4b                   	dec    %ebx
  8003e4:	85 db                	test   %ebx,%ebx
  8003e6:	7f 31                	jg     800419 <printnum+0x6d>
  8003e8:	eb 3f                	jmp    800429 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ea:	83 ec 0c             	sub    $0xc,%esp
  8003ed:	57                   	push   %edi
  8003ee:	4b                   	dec    %ebx
  8003ef:	53                   	push   %ebx
  8003f0:	50                   	push   %eax
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800400:	e8 c7 08 00 00       	call   800ccc <__udivdi3>
  800405:	83 c4 18             	add    $0x18,%esp
  800408:	52                   	push   %edx
  800409:	50                   	push   %eax
  80040a:	89 f2                	mov    %esi,%edx
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	e8 98 ff ff ff       	call   8003ac <printnum>
  800414:	83 c4 20             	add    $0x20,%esp
  800417:	eb 10                	jmp    800429 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	56                   	push   %esi
  80041d:	57                   	push   %edi
  80041e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800421:	4b                   	dec    %ebx
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	85 db                	test   %ebx,%ebx
  800427:	7f f0                	jg     800419 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	56                   	push   %esi
  80042d:	83 ec 04             	sub    $0x4,%esp
  800430:	ff 75 d4             	pushl  -0x2c(%ebp)
  800433:	ff 75 d0             	pushl  -0x30(%ebp)
  800436:	ff 75 dc             	pushl  -0x24(%ebp)
  800439:	ff 75 d8             	pushl  -0x28(%ebp)
  80043c:	e8 a7 09 00 00       	call   800de8 <__umoddi3>
  800441:	83 c4 14             	add    $0x14,%esp
  800444:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  80044b:	50                   	push   %eax
  80044c:	ff 55 e4             	call   *-0x1c(%ebp)
  80044f:	83 c4 10             	add    $0x10,%esp
}
  800452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800455:	5b                   	pop    %ebx
  800456:	5e                   	pop    %esi
  800457:	5f                   	pop    %edi
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80045d:	83 fa 01             	cmp    $0x1,%edx
  800460:	7e 0e                	jle    800470 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 08             	lea    0x8(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	8b 52 04             	mov    0x4(%edx),%edx
  80046e:	eb 22                	jmp    800492 <getuint+0x38>
	else if (lflag)
  800470:	85 d2                	test   %edx,%edx
  800472:	74 10                	je     800484 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800474:	8b 10                	mov    (%eax),%edx
  800476:	8d 4a 04             	lea    0x4(%edx),%ecx
  800479:	89 08                	mov    %ecx,(%eax)
  80047b:	8b 02                	mov    (%edx),%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	eb 0e                	jmp    800492 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800497:	83 fa 01             	cmp    $0x1,%edx
  80049a:	7e 0e                	jle    8004aa <getint+0x16>
		return va_arg(*ap, long long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	8b 52 04             	mov    0x4(%edx),%edx
  8004a8:	eb 1a                	jmp    8004c4 <getint+0x30>
	else if (lflag)
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	74 0c                	je     8004ba <getint+0x26>
		return va_arg(*ap, long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	99                   	cltd   
  8004b8:	eb 0a                	jmp    8004c4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004ba:	8b 10                	mov    (%eax),%edx
  8004bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bf:	89 08                	mov    %ecx,(%eax)
  8004c1:	8b 02                	mov    (%edx),%eax
  8004c3:	99                   	cltd   
}
  8004c4:	c9                   	leave  
  8004c5:	c3                   	ret    

008004c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004cf:	8b 10                	mov    (%eax),%edx
  8004d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d4:	73 08                	jae    8004de <sprintputch+0x18>
		*b->buf++ = ch;
  8004d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d9:	88 0a                	mov    %cl,(%edx)
  8004db:	42                   	inc    %edx
  8004dc:	89 10                	mov    %edx,(%eax)
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e9:	50                   	push   %eax
  8004ea:	ff 75 10             	pushl  0x10(%ebp)
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 05 00 00 00       	call   8004fd <vprintfmt>
	va_end(ap);
  8004f8:	83 c4 10             	add    $0x10,%esp
}
  8004fb:	c9                   	leave  
  8004fc:	c3                   	ret    

008004fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	57                   	push   %edi
  800501:	56                   	push   %esi
  800502:	53                   	push   %ebx
  800503:	83 ec 2c             	sub    $0x2c,%esp
  800506:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800509:	8b 75 10             	mov    0x10(%ebp),%esi
  80050c:	eb 13                	jmp    800521 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 84 6d 03 00 00    	je     800883 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	57                   	push   %edi
  80051a:	50                   	push   %eax
  80051b:	ff 55 08             	call   *0x8(%ebp)
  80051e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800521:	0f b6 06             	movzbl (%esi),%eax
  800524:	46                   	inc    %esi
  800525:	83 f8 25             	cmp    $0x25,%eax
  800528:	75 e4                	jne    80050e <vprintfmt+0x11>
  80052a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80052e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800535:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80053c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800543:	b9 00 00 00 00       	mov    $0x0,%ecx
  800548:	eb 28                	jmp    800572 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80054c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800550:	eb 20                	jmp    800572 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800554:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800558:	eb 18                	jmp    800572 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80055c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800563:	eb 0d                	jmp    800572 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8a 06                	mov    (%esi),%al
  800574:	0f b6 d0             	movzbl %al,%edx
  800577:	8d 5e 01             	lea    0x1(%esi),%ebx
  80057a:	83 e8 23             	sub    $0x23,%eax
  80057d:	3c 55                	cmp    $0x55,%al
  80057f:	0f 87 e0 02 00 00    	ja     800865 <vprintfmt+0x368>
  800585:	0f b6 c0             	movzbl %al,%eax
  800588:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058f:	83 ea 30             	sub    $0x30,%edx
  800592:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800595:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800598:	8d 50 d0             	lea    -0x30(%eax),%edx
  80059b:	83 fa 09             	cmp    $0x9,%edx
  80059e:	77 44                	ja     8005e4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	89 de                	mov    %ebx,%esi
  8005a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005a6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005a9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005ad:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005b3:	83 fb 09             	cmp    $0x9,%ebx
  8005b6:	76 ed                	jbe    8005a5 <vprintfmt+0xa8>
  8005b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005bb:	eb 29                	jmp    8005e6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cd:	eb 17                	jmp    8005e6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d3:	78 85                	js     80055a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	89 de                	mov    %ebx,%esi
  8005d7:	eb 99                	jmp    800572 <vprintfmt+0x75>
  8005d9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005e2:	eb 8e                	jmp    800572 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ea:	79 86                	jns    800572 <vprintfmt+0x75>
  8005ec:	e9 74 ff ff ff       	jmp    800565 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	89 de                	mov    %ebx,%esi
  8005f4:	e9 79 ff ff ff       	jmp    800572 <vprintfmt+0x75>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	57                   	push   %edi
  800609:	ff 30                	pushl  (%eax)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80060e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800614:	e9 08 ff ff ff       	jmp    800521 <vprintfmt+0x24>
  800619:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	79 02                	jns    80062d <vprintfmt+0x130>
  80062b:	f7 d8                	neg    %eax
  80062d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062f:	83 f8 08             	cmp    $0x8,%eax
  800632:	7f 0b                	jg     80063f <vprintfmt+0x142>
  800634:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  80063b:	85 c0                	test   %eax,%eax
  80063d:	75 1a                	jne    800659 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80063f:	52                   	push   %edx
  800640:	68 96 0f 80 00       	push   $0x800f96
  800645:	57                   	push   %edi
  800646:	ff 75 08             	pushl  0x8(%ebp)
  800649:	e8 92 fe ff ff       	call   8004e0 <printfmt>
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800654:	e9 c8 fe ff ff       	jmp    800521 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800659:	50                   	push   %eax
  80065a:	68 9f 0f 80 00       	push   $0x800f9f
  80065f:	57                   	push   %edi
  800660:	ff 75 08             	pushl  0x8(%ebp)
  800663:	e8 78 fe ff ff       	call   8004e0 <printfmt>
  800668:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80066e:	e9 ae fe ff ff       	jmp    800521 <vprintfmt+0x24>
  800673:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800676:	89 de                	mov    %ebx,%esi
  800678:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80067b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068c:	85 c0                	test   %eax,%eax
  80068e:	75 07                	jne    800697 <vprintfmt+0x19a>
				p = "(null)";
  800690:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800697:	85 db                	test   %ebx,%ebx
  800699:	7e 42                	jle    8006dd <vprintfmt+0x1e0>
  80069b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80069f:	74 3c                	je     8006dd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	51                   	push   %ecx
  8006a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a8:	e8 6f 02 00 00       	call   80091c <strnlen>
  8006ad:	29 c3                	sub    %eax,%ebx
  8006af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	85 db                	test   %ebx,%ebx
  8006b7:	7e 24                	jle    8006dd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006b9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006bd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	57                   	push   %edi
  8006c7:	53                   	push   %ebx
  8006c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	4e                   	dec    %esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 f6                	test   %esi,%esi
  8006d1:	7f f0                	jg     8006c3 <vprintfmt+0x1c6>
  8006d3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006dd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e0:	0f be 02             	movsbl (%edx),%eax
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	75 47                	jne    80072e <vprintfmt+0x231>
  8006e7:	eb 37                	jmp    800720 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ed:	74 16                	je     800705 <vprintfmt+0x208>
  8006ef:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006f2:	83 fa 5e             	cmp    $0x5e,%edx
  8006f5:	76 0e                	jbe    800705 <vprintfmt+0x208>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	57                   	push   %edi
  8006fb:	6a 3f                	push   $0x3f
  8006fd:	ff 55 08             	call   *0x8(%ebp)
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb 0b                	jmp    800710 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	57                   	push   %edi
  800709:	50                   	push   %eax
  80070a:	ff 55 08             	call   *0x8(%ebp)
  80070d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800710:	ff 4d e4             	decl   -0x1c(%ebp)
  800713:	0f be 03             	movsbl (%ebx),%eax
  800716:	85 c0                	test   %eax,%eax
  800718:	74 03                	je     80071d <vprintfmt+0x220>
  80071a:	43                   	inc    %ebx
  80071b:	eb 1b                	jmp    800738 <vprintfmt+0x23b>
  80071d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800720:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800724:	7f 1e                	jg     800744 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800729:	e9 f3 fd ff ff       	jmp    800521 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800731:	43                   	inc    %ebx
  800732:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800735:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800738:	85 f6                	test   %esi,%esi
  80073a:	78 ad                	js     8006e9 <vprintfmt+0x1ec>
  80073c:	4e                   	dec    %esi
  80073d:	79 aa                	jns    8006e9 <vprintfmt+0x1ec>
  80073f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800742:	eb dc                	jmp    800720 <vprintfmt+0x223>
  800744:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	57                   	push   %edi
  80074b:	6a 20                	push   $0x20
  80074d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800750:	4b                   	dec    %ebx
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f ef                	jg     800747 <vprintfmt+0x24a>
  800758:	e9 c4 fd ff ff       	jmp    800521 <vprintfmt+0x24>
  80075d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 2a fd ff ff       	call   800494 <getint>
  80076a:	89 c3                	mov    %eax,%ebx
  80076c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80076e:	85 d2                	test   %edx,%edx
  800770:	78 0a                	js     80077c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800772:	b8 0a 00 00 00       	mov    $0xa,%eax
  800777:	e9 b0 00 00 00       	jmp    80082c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	57                   	push   %edi
  800780:	6a 2d                	push   $0x2d
  800782:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800785:	f7 db                	neg    %ebx
  800787:	83 d6 00             	adc    $0x0,%esi
  80078a:	f7 de                	neg    %esi
  80078c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80078f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800794:	e9 93 00 00 00       	jmp    80082c <vprintfmt+0x32f>
  800799:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80079c:	89 ca                	mov    %ecx,%edx
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 b4 fc ff ff       	call   80045a <getuint>
  8007a6:	89 c3                	mov    %eax,%ebx
  8007a8:	89 d6                	mov    %edx,%esi
			base = 10;
  8007aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007af:	eb 7b                	jmp    80082c <vprintfmt+0x32f>
  8007b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 d6 fc ff ff       	call   800494 <getint>
  8007be:	89 c3                	mov    %eax,%ebx
  8007c0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	78 07                	js     8007cd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cb:	eb 5f                	jmp    80082c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	57                   	push   %edi
  8007d1:	6a 2d                	push   $0x2d
  8007d3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007d6:	f7 db                	neg    %ebx
  8007d8:	83 d6 00             	adc    $0x0,%esi
  8007db:	f7 de                	neg    %esi
  8007dd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e5:	eb 45                	jmp    80082c <vprintfmt+0x32f>
  8007e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	57                   	push   %edi
  8007ee:	6a 30                	push   $0x30
  8007f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	57                   	push   %edi
  8007f7:	6a 78                	push   $0x78
  8007f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8d 50 04             	lea    0x4(%eax),%edx
  800802:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800805:	8b 18                	mov    (%eax),%ebx
  800807:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80080c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800814:	eb 16                	jmp    80082c <vprintfmt+0x32f>
  800816:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800819:	89 ca                	mov    %ecx,%edx
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	e8 37 fc ff ff       	call   80045a <getuint>
  800823:	89 c3                	mov    %eax,%ebx
  800825:	89 d6                	mov    %edx,%esi
			base = 16;
  800827:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80082c:	83 ec 0c             	sub    $0xc,%esp
  80082f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800833:	52                   	push   %edx
  800834:	ff 75 e4             	pushl  -0x1c(%ebp)
  800837:	50                   	push   %eax
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	89 fa                	mov    %edi,%edx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	e8 68 fb ff ff       	call   8003ac <printnum>
			break;
  800844:	83 c4 20             	add    $0x20,%esp
  800847:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80084a:	e9 d2 fc ff ff       	jmp    800521 <vprintfmt+0x24>
  80084f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	57                   	push   %edi
  800856:	52                   	push   %edx
  800857:	ff 55 08             	call   *0x8(%ebp)
			break;
  80085a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800860:	e9 bc fc ff ff       	jmp    800521 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	57                   	push   %edi
  800869:	6a 25                	push   $0x25
  80086b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 02                	jmp    800875 <vprintfmt+0x378>
  800873:	89 c6                	mov    %eax,%esi
  800875:	8d 46 ff             	lea    -0x1(%esi),%eax
  800878:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80087c:	75 f5                	jne    800873 <vprintfmt+0x376>
  80087e:	e9 9e fc ff ff       	jmp    800521 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800883:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5f                   	pop    %edi
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 18             	sub    $0x18,%esp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800897:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	74 26                	je     8008d2 <vsnprintf+0x47>
  8008ac:	85 d2                	test   %edx,%edx
  8008ae:	7e 29                	jle    8008d9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b0:	ff 75 14             	pushl  0x14(%ebp)
  8008b3:	ff 75 10             	pushl  0x10(%ebp)
  8008b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	68 c6 04 80 00       	push   $0x8004c6
  8008bf:	e8 39 fc ff ff       	call   8004fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	eb 0c                	jmp    8008de <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d7:	eb 05                	jmp    8008de <vsnprintf+0x53>
  8008d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e9:	50                   	push   %eax
  8008ea:	ff 75 10             	pushl  0x10(%ebp)
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	ff 75 08             	pushl  0x8(%ebp)
  8008f3:	e8 93 ff ff ff       	call   80088b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    
	...

008008fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	80 3a 00             	cmpb   $0x0,(%edx)
  800905:	74 0e                	je     800915 <strlen+0x19>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80090c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800911:	75 f9                	jne    80090c <strlen+0x10>
  800913:	eb 05                	jmp    80091a <strlen+0x1e>
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	85 d2                	test   %edx,%edx
  800927:	74 17                	je     800940 <strnlen+0x24>
  800929:	80 39 00             	cmpb   $0x0,(%ecx)
  80092c:	74 19                	je     800947 <strnlen+0x2b>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800933:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	39 d0                	cmp    %edx,%eax
  800936:	74 14                	je     80094c <strnlen+0x30>
  800938:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093c:	75 f5                	jne    800933 <strnlen+0x17>
  80093e:	eb 0c                	jmp    80094c <strnlen+0x30>
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb 05                	jmp    80094c <strnlen+0x30>
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800960:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800963:	42                   	inc    %edx
  800964:	84 c9                	test   %cl,%cl
  800966:	75 f5                	jne    80095d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800968:	5b                   	pop    %ebx
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800972:	53                   	push   %ebx
  800973:	e8 84 ff ff ff       	call   8008fc <strlen>
  800978:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800981:	50                   	push   %eax
  800982:	e8 c7 ff ff ff       	call   80094e <strcpy>
	return dst;
}
  800987:	89 d8                	mov    %ebx,%eax
  800989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	85 f6                	test   %esi,%esi
  80099e:	74 15                	je     8009b5 <strncpy+0x27>
  8009a0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009a5:	8a 1a                	mov    (%edx),%bl
  8009a7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009aa:	80 3a 01             	cmpb   $0x1,(%edx)
  8009ad:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b0:	41                   	inc    %ecx
  8009b1:	39 ce                	cmp    %ecx,%esi
  8009b3:	77 f0                	ja     8009a5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c8:	85 f6                	test   %esi,%esi
  8009ca:	74 32                	je     8009fe <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009cc:	83 fe 01             	cmp    $0x1,%esi
  8009cf:	74 22                	je     8009f3 <strlcpy+0x3a>
  8009d1:	8a 0b                	mov    (%ebx),%cl
  8009d3:	84 c9                	test   %cl,%cl
  8009d5:	74 20                	je     8009f7 <strlcpy+0x3e>
  8009d7:	89 f8                	mov    %edi,%eax
  8009d9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009de:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e1:	88 08                	mov    %cl,(%eax)
  8009e3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e4:	39 f2                	cmp    %esi,%edx
  8009e6:	74 11                	je     8009f9 <strlcpy+0x40>
  8009e8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009ec:	42                   	inc    %edx
  8009ed:	84 c9                	test   %cl,%cl
  8009ef:	75 f0                	jne    8009e1 <strlcpy+0x28>
  8009f1:	eb 06                	jmp    8009f9 <strlcpy+0x40>
  8009f3:	89 f8                	mov    %edi,%eax
  8009f5:	eb 02                	jmp    8009f9 <strlcpy+0x40>
  8009f7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f9:	c6 00 00             	movb   $0x0,(%eax)
  8009fc:	eb 02                	jmp    800a00 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fe:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a00:	29 f8                	sub    %edi,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a10:	8a 01                	mov    (%ecx),%al
  800a12:	84 c0                	test   %al,%al
  800a14:	74 10                	je     800a26 <strcmp+0x1f>
  800a16:	3a 02                	cmp    (%edx),%al
  800a18:	75 0c                	jne    800a26 <strcmp+0x1f>
		p++, q++;
  800a1a:	41                   	inc    %ecx
  800a1b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1c:	8a 01                	mov    (%ecx),%al
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 04                	je     800a26 <strcmp+0x1f>
  800a22:	3a 02                	cmp    (%edx),%al
  800a24:	74 f4                	je     800a1a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a26:	0f b6 c0             	movzbl %al,%eax
  800a29:	0f b6 12             	movzbl (%edx),%edx
  800a2c:	29 d0                	sub    %edx,%eax
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	74 1b                	je     800a5c <strncmp+0x2c>
  800a41:	8a 1a                	mov    (%edx),%bl
  800a43:	84 db                	test   %bl,%bl
  800a45:	74 24                	je     800a6b <strncmp+0x3b>
  800a47:	3a 19                	cmp    (%ecx),%bl
  800a49:	75 20                	jne    800a6b <strncmp+0x3b>
  800a4b:	48                   	dec    %eax
  800a4c:	74 15                	je     800a63 <strncmp+0x33>
		n--, p++, q++;
  800a4e:	42                   	inc    %edx
  800a4f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a50:	8a 1a                	mov    (%edx),%bl
  800a52:	84 db                	test   %bl,%bl
  800a54:	74 15                	je     800a6b <strncmp+0x3b>
  800a56:	3a 19                	cmp    (%ecx),%bl
  800a58:	74 f1                	je     800a4b <strncmp+0x1b>
  800a5a:	eb 0f                	jmp    800a6b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	eb 05                	jmp    800a68 <strncmp+0x38>
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a68:	5b                   	pop    %ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 02             	movzbl (%edx),%eax
  800a6e:	0f b6 11             	movzbl (%ecx),%edx
  800a71:	29 d0                	sub    %edx,%eax
  800a73:	eb f3                	jmp    800a68 <strncmp+0x38>

00800a75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7e:	8a 10                	mov    (%eax),%dl
  800a80:	84 d2                	test   %dl,%dl
  800a82:	74 18                	je     800a9c <strchr+0x27>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	75 06                	jne    800a8e <strchr+0x19>
  800a88:	eb 17                	jmp    800aa1 <strchr+0x2c>
  800a8a:	38 ca                	cmp    %cl,%dl
  800a8c:	74 13                	je     800aa1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8e:	40                   	inc    %eax
  800a8f:	8a 10                	mov    (%eax),%dl
  800a91:	84 d2                	test   %dl,%dl
  800a93:	75 f5                	jne    800a8a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	eb 05                	jmp    800aa1 <strchr+0x2c>
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aac:	8a 10                	mov    (%eax),%dl
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	74 11                	je     800ac3 <strfind+0x20>
		if (*s == c)
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	75 06                	jne    800abc <strfind+0x19>
  800ab6:	eb 0b                	jmp    800ac3 <strfind+0x20>
  800ab8:	38 ca                	cmp    %cl,%dl
  800aba:	74 07                	je     800ac3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800abc:	40                   	inc    %eax
  800abd:	8a 10                	mov    (%eax),%dl
  800abf:	84 d2                	test   %dl,%dl
  800ac1:	75 f5                	jne    800ab8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad4:	85 c9                	test   %ecx,%ecx
  800ad6:	74 30                	je     800b08 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ade:	75 25                	jne    800b05 <memset+0x40>
  800ae0:	f6 c1 03             	test   $0x3,%cl
  800ae3:	75 20                	jne    800b05 <memset+0x40>
		c &= 0xFF;
  800ae5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 d0                	or     %edx,%eax
  800afb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800afd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b00:	fc                   	cld    
  800b01:	f3 ab                	rep stos %eax,%es:(%edi)
  800b03:	eb 03                	jmp    800b08 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b05:	fc                   	cld    
  800b06:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b08:	89 f8                	mov    %edi,%eax
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b1d:	39 c6                	cmp    %eax,%esi
  800b1f:	73 34                	jae    800b55 <memmove+0x46>
  800b21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b24:	39 d0                	cmp    %edx,%eax
  800b26:	73 2d                	jae    800b55 <memmove+0x46>
		s += n;
		d += n;
  800b28:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2b:	f6 c2 03             	test   $0x3,%dl
  800b2e:	75 1b                	jne    800b4b <memmove+0x3c>
  800b30:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b36:	75 13                	jne    800b4b <memmove+0x3c>
  800b38:	f6 c1 03             	test   $0x3,%cl
  800b3b:	75 0e                	jne    800b4b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b3d:	83 ef 04             	sub    $0x4,%edi
  800b40:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b43:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b46:	fd                   	std    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 07                	jmp    800b52 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4b:	4f                   	dec    %edi
  800b4c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	fd                   	std    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b52:	fc                   	cld    
  800b53:	eb 20                	jmp    800b75 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5b:	75 13                	jne    800b70 <memmove+0x61>
  800b5d:	a8 03                	test   $0x3,%al
  800b5f:	75 0f                	jne    800b70 <memmove+0x61>
  800b61:	f6 c1 03             	test   $0x3,%cl
  800b64:	75 0a                	jne    800b70 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b66:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	fc                   	cld    
  800b6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6e:	eb 05                	jmp    800b75 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b70:	89 c7                	mov    %eax,%edi
  800b72:	fc                   	cld    
  800b73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7c:	ff 75 10             	pushl  0x10(%ebp)
  800b7f:	ff 75 0c             	pushl  0xc(%ebp)
  800b82:	ff 75 08             	pushl  0x8(%ebp)
  800b85:	e8 85 ff ff ff       	call   800b0f <memmove>
}
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9b:	85 ff                	test   %edi,%edi
  800b9d:	74 32                	je     800bd1 <memcmp+0x45>
		if (*s1 != *s2)
  800b9f:	8a 03                	mov    (%ebx),%al
  800ba1:	8a 0e                	mov    (%esi),%cl
  800ba3:	38 c8                	cmp    %cl,%al
  800ba5:	74 19                	je     800bc0 <memcmp+0x34>
  800ba7:	eb 0d                	jmp    800bb6 <memcmp+0x2a>
  800ba9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bad:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bb1:	42                   	inc    %edx
  800bb2:	38 c8                	cmp    %cl,%al
  800bb4:	74 10                	je     800bc6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bb6:	0f b6 c0             	movzbl %al,%eax
  800bb9:	0f b6 c9             	movzbl %cl,%ecx
  800bbc:	29 c8                	sub    %ecx,%eax
  800bbe:	eb 16                	jmp    800bd6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc0:	4f                   	dec    %edi
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	39 fa                	cmp    %edi,%edx
  800bc8:	75 df                	jne    800ba9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	eb 05                	jmp    800bd6 <memcmp+0x4a>
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be6:	39 d0                	cmp    %edx,%eax
  800be8:	73 12                	jae    800bfc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bea:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bed:	38 08                	cmp    %cl,(%eax)
  800bef:	75 06                	jne    800bf7 <memfind+0x1c>
  800bf1:	eb 09                	jmp    800bfc <memfind+0x21>
  800bf3:	38 08                	cmp    %cl,(%eax)
  800bf5:	74 05                	je     800bfc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf7:	40                   	inc    %eax
  800bf8:	39 c2                	cmp    %eax,%edx
  800bfa:	77 f7                	ja     800bf3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	eb 01                	jmp    800c0d <strtol+0xf>
		s++;
  800c0c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0d:	8a 02                	mov    (%edx),%al
  800c0f:	3c 20                	cmp    $0x20,%al
  800c11:	74 f9                	je     800c0c <strtol+0xe>
  800c13:	3c 09                	cmp    $0x9,%al
  800c15:	74 f5                	je     800c0c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c17:	3c 2b                	cmp    $0x2b,%al
  800c19:	75 08                	jne    800c23 <strtol+0x25>
		s++;
  800c1b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c21:	eb 13                	jmp    800c36 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c23:	3c 2d                	cmp    $0x2d,%al
  800c25:	75 0a                	jne    800c31 <strtol+0x33>
		s++, neg = 1;
  800c27:	8d 52 01             	lea    0x1(%edx),%edx
  800c2a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c2f:	eb 05                	jmp    800c36 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c36:	85 db                	test   %ebx,%ebx
  800c38:	74 05                	je     800c3f <strtol+0x41>
  800c3a:	83 fb 10             	cmp    $0x10,%ebx
  800c3d:	75 28                	jne    800c67 <strtol+0x69>
  800c3f:	8a 02                	mov    (%edx),%al
  800c41:	3c 30                	cmp    $0x30,%al
  800c43:	75 10                	jne    800c55 <strtol+0x57>
  800c45:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c49:	75 0a                	jne    800c55 <strtol+0x57>
		s += 2, base = 16;
  800c4b:	83 c2 02             	add    $0x2,%edx
  800c4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c53:	eb 12                	jmp    800c67 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c55:	85 db                	test   %ebx,%ebx
  800c57:	75 0e                	jne    800c67 <strtol+0x69>
  800c59:	3c 30                	cmp    $0x30,%al
  800c5b:	75 05                	jne    800c62 <strtol+0x64>
		s++, base = 8;
  800c5d:	42                   	inc    %edx
  800c5e:	b3 08                	mov    $0x8,%bl
  800c60:	eb 05                	jmp    800c67 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6e:	8a 0a                	mov    (%edx),%cl
  800c70:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c73:	80 fb 09             	cmp    $0x9,%bl
  800c76:	77 08                	ja     800c80 <strtol+0x82>
			dig = *s - '0';
  800c78:	0f be c9             	movsbl %cl,%ecx
  800c7b:	83 e9 30             	sub    $0x30,%ecx
  800c7e:	eb 1e                	jmp    800c9e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c80:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c83:	80 fb 19             	cmp    $0x19,%bl
  800c86:	77 08                	ja     800c90 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c88:	0f be c9             	movsbl %cl,%ecx
  800c8b:	83 e9 57             	sub    $0x57,%ecx
  800c8e:	eb 0e                	jmp    800c9e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c90:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c93:	80 fb 19             	cmp    $0x19,%bl
  800c96:	77 13                	ja     800cab <strtol+0xad>
			dig = *s - 'A' + 10;
  800c98:	0f be c9             	movsbl %cl,%ecx
  800c9b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9e:	39 f1                	cmp    %esi,%ecx
  800ca0:	7d 0d                	jge    800caf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ca2:	42                   	inc    %edx
  800ca3:	0f af c6             	imul   %esi,%eax
  800ca6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ca9:	eb c3                	jmp    800c6e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cab:	89 c1                	mov    %eax,%ecx
  800cad:	eb 02                	jmp    800cb1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800caf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb5:	74 05                	je     800cbc <strtol+0xbe>
		*endptr = (char *) s;
  800cb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cba:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cbc:	85 ff                	test   %edi,%edi
  800cbe:	74 04                	je     800cc4 <strtol+0xc6>
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	f7 d8                	neg    %eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    
  800cc9:	00 00                	add    %al,(%eax)
	...

00800ccc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	83 ec 10             	sub    $0x10,%esp
  800cd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cda:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ce3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	75 2e                	jne    800d18 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cea:	39 f1                	cmp    %esi,%ecx
  800cec:	77 5a                	ja     800d48 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cee:	85 c9                	test   %ecx,%ecx
  800cf0:	75 0b                	jne    800cfd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	31 d2                	xor    %edx,%edx
  800cf9:	f7 f1                	div    %ecx
  800cfb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cfd:	31 d2                	xor    %edx,%edx
  800cff:	89 f0                	mov    %esi,%eax
  800d01:	f7 f1                	div    %ecx
  800d03:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	f7 f1                	div    %ecx
  800d09:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0b:	89 f8                	mov    %edi,%eax
  800d0d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    
  800d16:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d18:	39 f0                	cmp    %esi,%eax
  800d1a:	77 1c                	ja     800d38 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d1c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d1f:	83 f7 1f             	xor    $0x1f,%edi
  800d22:	75 3c                	jne    800d60 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d24:	39 f0                	cmp    %esi,%eax
  800d26:	0f 82 90 00 00 00    	jb     800dbc <__udivdi3+0xf0>
  800d2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d2f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d32:	0f 86 84 00 00 00    	jbe    800dbc <__udivdi3+0xf0>
  800d38:	31 f6                	xor    %esi,%esi
  800d3a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3c:	89 f8                	mov    %edi,%eax
  800d3e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    
  800d47:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	89 f8                	mov    %edi,%eax
  800d4c:	f7 f1                	div    %ecx
  800d4e:	89 c7                	mov    %eax,%edi
  800d50:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d60:	89 f9                	mov    %edi,%ecx
  800d62:	d3 e0                	shl    %cl,%eax
  800d64:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d67:	b8 20 00 00 00       	mov    $0x20,%eax
  800d6c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d71:	88 c1                	mov    %al,%cl
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d78:	09 ca                	or     %ecx,%edx
  800d7a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d80:	89 f9                	mov    %edi,%ecx
  800d82:	d3 e2                	shl    %cl,%edx
  800d84:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d87:	89 f2                	mov    %esi,%edx
  800d89:	88 c1                	mov    %al,%cl
  800d8b:	d3 ea                	shr    %cl,%edx
  800d8d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d90:	89 f2                	mov    %esi,%edx
  800d92:	89 f9                	mov    %edi,%ecx
  800d94:	d3 e2                	shl    %cl,%edx
  800d96:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ee                	shr    %cl,%esi
  800d9d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d9f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	89 ca                	mov    %ecx,%edx
  800da6:	f7 75 ec             	divl   -0x14(%ebp)
  800da9:	89 d1                	mov    %edx,%ecx
  800dab:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dad:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db0:	39 d1                	cmp    %edx,%ecx
  800db2:	72 28                	jb     800ddc <__udivdi3+0x110>
  800db4:	74 1a                	je     800dd0 <__udivdi3+0x104>
  800db6:	89 f7                	mov    %esi,%edi
  800db8:	31 f6                	xor    %esi,%esi
  800dba:	eb 80                	jmp    800d3c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dbc:	31 f6                	xor    %esi,%esi
  800dbe:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc3:	89 f8                	mov    %edi,%eax
  800dc5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    
  800dce:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd3:	89 f9                	mov    %edi,%ecx
  800dd5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd7:	39 c2                	cmp    %eax,%edx
  800dd9:	73 db                	jae    800db6 <__udivdi3+0xea>
  800ddb:	90                   	nop
		{
		  q0--;
  800ddc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ddf:	31 f6                	xor    %esi,%esi
  800de1:	e9 56 ff ff ff       	jmp    800d3c <__udivdi3+0x70>
	...

00800de8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	83 ec 20             	sub    $0x20,%esp
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800df6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800df9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800dfc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dff:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e05:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e07:	85 ff                	test   %edi,%edi
  800e09:	75 15                	jne    800e20 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e0b:	39 f1                	cmp    %esi,%ecx
  800e0d:	0f 86 99 00 00 00    	jbe    800eac <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e13:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e15:	89 d0                	mov    %edx,%eax
  800e17:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e19:	83 c4 20             	add    $0x20,%esp
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e20:	39 f7                	cmp    %esi,%edi
  800e22:	0f 87 a4 00 00 00    	ja     800ecc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e28:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e2b:	83 f0 1f             	xor    $0x1f,%eax
  800e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e31:	0f 84 a1 00 00 00    	je     800ed8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e37:	89 f8                	mov    %edi,%eax
  800e39:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e3c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e43:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e49:	89 f9                	mov    %edi,%ecx
  800e4b:	d3 ea                	shr    %cl,%edx
  800e4d:	09 c2                	or     %eax,%edx
  800e4f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e55:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e58:	d3 e0                	shl    %cl,%eax
  800e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e5d:	89 f2                	mov    %esi,%edx
  800e5f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e64:	d3 e0                	shl    %cl,%eax
  800e66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e6c:	89 f9                	mov    %edi,%ecx
  800e6e:	d3 e8                	shr    %cl,%eax
  800e70:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e72:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e74:	89 f2                	mov    %esi,%edx
  800e76:	f7 75 f0             	divl   -0x10(%ebp)
  800e79:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e7b:	f7 65 f4             	mull   -0xc(%ebp)
  800e7e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e81:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e83:	39 d6                	cmp    %edx,%esi
  800e85:	72 71                	jb     800ef8 <__umoddi3+0x110>
  800e87:	74 7f                	je     800f08 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e8c:	29 c8                	sub    %ecx,%eax
  800e8e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e90:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e93:	d3 e8                	shr    %cl,%eax
  800e95:	89 f2                	mov    %esi,%edx
  800e97:	89 f9                	mov    %edi,%ecx
  800e99:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e9b:	09 d0                	or     %edx,%eax
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ea2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eac:	85 c9                	test   %ecx,%ecx
  800eae:	75 0b                	jne    800ebb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb5:	31 d2                	xor    %edx,%edx
  800eb7:	f7 f1                	div    %ecx
  800eb9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ebb:	89 f0                	mov    %esi,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec4:	f7 f1                	div    %ecx
  800ec6:	e9 4a ff ff ff       	jmp    800e15 <__umoddi3+0x2d>
  800ecb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ecc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ece:	83 c4 20             	add    $0x20,%esp
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed8:	39 f7                	cmp    %esi,%edi
  800eda:	72 05                	jb     800ee1 <__umoddi3+0xf9>
  800edc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800edf:	77 0c                	ja     800eed <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee1:	89 f2                	mov    %esi,%edx
  800ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee6:	29 c8                	sub    %ecx,%eax
  800ee8:	19 fa                	sbb    %edi,%edx
  800eea:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef0:	83 c4 20             	add    $0x20,%esp
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    
  800ef7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800efb:	89 c1                	mov    %eax,%ecx
  800efd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f00:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f03:	eb 84                	jmp    800e89 <__umoddi3+0xa1>
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f08:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f0b:	72 eb                	jb     800ef8 <__umoddi3+0x110>
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	e9 75 ff ff ff       	jmp    800e89 <__umoddi3+0xa1>
