
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
  800041:	e8 af 00 00 00       	call   8000f5 <sys_cputs>
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
  800057:	e8 05 01 00 00       	call   800161 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	c1 e0 07             	shl    $0x7,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x2d>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	53                   	push   %ebx
  80007d:	56                   	push   %esi
  80007e:	e8 b1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800083:	e8 0c 00 00 00       	call   800094 <exit>
  800088:	83 c4 10             	add    $0x10,%esp
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 9e 00 00 00       	call   80013f <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 1c             	sub    $0x1c,%esp
  8000b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	cd 30                	int    $0x30
  8000c7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000cd:	74 1c                	je     8000eb <syscall+0x43>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7e 18                	jle    8000eb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000da:	68 2a 0f 80 00       	push   $0x800f2a
  8000df:	6a 42                	push   $0x42
  8000e1:	68 47 0f 80 00       	push   $0x800f47
  8000e6:	e8 e1 01 00 00       	call   8002cc <_panic>

	return ret;
}
  8000eb:	89 d0                	mov    %edx,%eax
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 00 00 00 00       	mov    $0x0,%eax
  800111:	e8 92 ff ff ff       	call   8000a8 <syscall>
  800116:	83 c4 10             	add    $0x10,%esp
	return;
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <sys_cgetc>:

int
sys_cgetc(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 01 00 00 00       	mov    $0x1,%eax
  800138:	e8 6b ff ff ff       	call   8000a8 <syscall>
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	ba 01 00 00 00       	mov    $0x1,%edx
  800155:	b8 03 00 00 00       	mov    $0x3,%eax
  80015a:	e8 49 ff ff ff       	call   8000a8 <syscall>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	e8 25 ff ff ff       	call   8000a8 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_yield>:

void
sys_yield(void)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	b9 00 00 00 00       	mov    $0x0,%ecx
  800198:	ba 00 00 00 00       	mov    $0x0,%edx
  80019d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a2:	e8 01 ff ff ff       	call   8000a8 <syscall>
  8001a7:	83 c4 10             	add    $0x10,%esp
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001b2:	6a 00                	push   $0x0
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	ff 75 0c             	pushl  0xc(%ebp)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c9:	e8 da fe ff ff       	call   8000a8 <syscall>
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d6:	ff 75 18             	pushl  0x18(%ebp)
  8001d9:	ff 75 14             	pushl  0x14(%ebp)
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	e8 b4 fe ff ff       	call   8000a8 <syscall>
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001fc:	6a 00                	push   $0x0
  8001fe:	6a 00                	push   $0x0
  800200:	6a 00                	push   $0x0
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800208:	ba 01 00 00 00       	mov    $0x1,%edx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	e8 91 fe ff ff       	call   8000a8 <syscall>
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021f:	6a 00                	push   $0x0
  800221:	6a 00                	push   $0x0
  800223:	6a 00                	push   $0x0
  800225:	ff 75 0c             	pushl  0xc(%ebp)
  800228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022b:	ba 01 00 00 00       	mov    $0x1,%edx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	e8 6e fe ff ff       	call   8000a8 <syscall>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800242:	6a 00                	push   $0x0
  800244:	6a 00                	push   $0x0
  800246:	6a 00                	push   $0x0
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024e:	ba 01 00 00 00       	mov    $0x1,%edx
  800253:	b8 09 00 00 00       	mov    $0x9,%eax
  800258:	e8 4b fe ff ff       	call   8000a8 <syscall>
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800265:	6a 00                	push   $0x0
  800267:	ff 75 14             	pushl  0x14(%ebp)
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	ff 75 0c             	pushl  0xc(%ebp)
  800270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	b8 0b 00 00 00       	mov    $0xb,%eax
  80027d:	e8 26 fe ff ff       	call   8000a8 <syscall>
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80028a:	6a 00                	push   $0x0
  80028c:	6a 00                	push   $0x0
  80028e:	6a 00                	push   $0x0
  800290:	6a 00                	push   $0x0
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	ba 01 00 00 00       	mov    $0x1,%edx
  80029a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029f:	e8 04 fe ff ff       	call   8000a8 <syscall>
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002ac:	6a 00                	push   $0x0
  8002ae:	6a 00                	push   $0x0
  8002b0:	6a 00                	push   $0x0
  8002b2:	ff 75 0c             	pushl  0xc(%ebp)
  8002b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c2:	e8 e1 fd ff ff       	call   8000a8 <syscall>
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
	...

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002da:	e8 82 fe ff ff       	call   800161 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	53                   	push   %ebx
  8002e9:	50                   	push   %eax
  8002ea:	68 58 0f 80 00       	push   $0x800f58
  8002ef:	e8 b0 00 00 00       	call   8003a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	56                   	push   %esi
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 53 00 00 00       	call   800353 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  800307:	e8 98 00 00 00       	call   8003a4 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>
	...

00800314 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	53                   	push   %ebx
  800318:	83 ec 04             	sub    $0x4,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031e:	8b 03                	mov    (%ebx),%eax
  800320:	8b 55 08             	mov    0x8(%ebp),%edx
  800323:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800327:	40                   	inc    %eax
  800328:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 b3 fd ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	ff 43 04             	incl   0x4(%ebx)
}
  80034e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800363:	00 00 00 
	b.cnt = 0;
  800366:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800370:	ff 75 0c             	pushl  0xc(%ebp)
  800373:	ff 75 08             	pushl  0x8(%ebp)
  800376:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037c:	50                   	push   %eax
  80037d:	68 14 03 80 00       	push   $0x800314
  800382:	e8 82 01 00 00       	call   800509 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800387:	83 c4 08             	add    $0x8,%esp
  80038a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800390:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800396:	50                   	push   %eax
  800397:	e8 59 fd ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  80039c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ad:	50                   	push   %eax
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 9d ff ff ff       	call   800353 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    

008003b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 2c             	sub    $0x2c,%esp
  8003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003e5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003e8:	72 0c                	jb     8003f6 <printnum+0x3e>
  8003ea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003ed:	76 07                	jbe    8003f6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ef:	4b                   	dec    %ebx
  8003f0:	85 db                	test   %ebx,%ebx
  8003f2:	7f 31                	jg     800425 <printnum+0x6d>
  8003f4:	eb 3f                	jmp    800435 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f6:	83 ec 0c             	sub    $0xc,%esp
  8003f9:	57                   	push   %edi
  8003fa:	4b                   	dec    %ebx
  8003fb:	53                   	push   %ebx
  8003fc:	50                   	push   %eax
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	ff 75 d4             	pushl  -0x2c(%ebp)
  800403:	ff 75 d0             	pushl  -0x30(%ebp)
  800406:	ff 75 dc             	pushl  -0x24(%ebp)
  800409:	ff 75 d8             	pushl  -0x28(%ebp)
  80040c:	e8 c7 08 00 00       	call   800cd8 <__udivdi3>
  800411:	83 c4 18             	add    $0x18,%esp
  800414:	52                   	push   %edx
  800415:	50                   	push   %eax
  800416:	89 f2                	mov    %esi,%edx
  800418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041b:	e8 98 ff ff ff       	call   8003b8 <printnum>
  800420:	83 c4 20             	add    $0x20,%esp
  800423:	eb 10                	jmp    800435 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	56                   	push   %esi
  800429:	57                   	push   %edi
  80042a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042d:	4b                   	dec    %ebx
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	85 db                	test   %ebx,%ebx
  800433:	7f f0                	jg     800425 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	56                   	push   %esi
  800439:	83 ec 04             	sub    $0x4,%esp
  80043c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80043f:	ff 75 d0             	pushl  -0x30(%ebp)
  800442:	ff 75 dc             	pushl  -0x24(%ebp)
  800445:	ff 75 d8             	pushl  -0x28(%ebp)
  800448:	e8 a7 09 00 00       	call   800df4 <__umoddi3>
  80044d:	83 c4 14             	add    $0x14,%esp
  800450:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  800457:	50                   	push   %eax
  800458:	ff 55 e4             	call   *-0x1c(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
}
  80045e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800461:	5b                   	pop    %ebx
  800462:	5e                   	pop    %esi
  800463:	5f                   	pop    %edi
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800469:	83 fa 01             	cmp    $0x1,%edx
  80046c:	7e 0e                	jle    80047c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 08             	lea    0x8(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	8b 52 04             	mov    0x4(%edx),%edx
  80047a:	eb 22                	jmp    80049e <getuint+0x38>
	else if (lflag)
  80047c:	85 d2                	test   %edx,%edx
  80047e:	74 10                	je     800490 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800480:	8b 10                	mov    (%eax),%edx
  800482:	8d 4a 04             	lea    0x4(%edx),%ecx
  800485:	89 08                	mov    %ecx,(%eax)
  800487:	8b 02                	mov    (%edx),%eax
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	eb 0e                	jmp    80049e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 04             	lea    0x4(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a3:	83 fa 01             	cmp    $0x1,%edx
  8004a6:	7e 0e                	jle    8004b6 <getint+0x16>
		return va_arg(*ap, long long);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	8b 52 04             	mov    0x4(%edx),%edx
  8004b4:	eb 1a                	jmp    8004d0 <getint+0x30>
	else if (lflag)
  8004b6:	85 d2                	test   %edx,%edx
  8004b8:	74 0c                	je     8004c6 <getint+0x26>
		return va_arg(*ap, long);
  8004ba:	8b 10                	mov    (%eax),%edx
  8004bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bf:	89 08                	mov    %ecx,(%eax)
  8004c1:	8b 02                	mov    (%edx),%eax
  8004c3:	99                   	cltd   
  8004c4:	eb 0a                	jmp    8004d0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cb:	89 08                	mov    %ecx,(%eax)
  8004cd:	8b 02                	mov    (%edx),%eax
  8004cf:	99                   	cltd   
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    

008004d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004db:	8b 10                	mov    (%eax),%edx
  8004dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e0:	73 08                	jae    8004ea <sprintputch+0x18>
		*b->buf++ = ch;
  8004e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e5:	88 0a                	mov    %cl,(%edx)
  8004e7:	42                   	inc    %edx
  8004e8:	89 10                	mov    %edx,(%eax)
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f5:	50                   	push   %eax
  8004f6:	ff 75 10             	pushl  0x10(%ebp)
  8004f9:	ff 75 0c             	pushl  0xc(%ebp)
  8004fc:	ff 75 08             	pushl  0x8(%ebp)
  8004ff:	e8 05 00 00 00       	call   800509 <vprintfmt>
	va_end(ap);
  800504:	83 c4 10             	add    $0x10,%esp
}
  800507:	c9                   	leave  
  800508:	c3                   	ret    

00800509 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	57                   	push   %edi
  80050d:	56                   	push   %esi
  80050e:	53                   	push   %ebx
  80050f:	83 ec 2c             	sub    $0x2c,%esp
  800512:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800515:	8b 75 10             	mov    0x10(%ebp),%esi
  800518:	eb 13                	jmp    80052d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051a:	85 c0                	test   %eax,%eax
  80051c:	0f 84 6d 03 00 00    	je     80088f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	57                   	push   %edi
  800526:	50                   	push   %eax
  800527:	ff 55 08             	call   *0x8(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052d:	0f b6 06             	movzbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	83 f8 25             	cmp    $0x25,%eax
  800534:	75 e4                	jne    80051a <vprintfmt+0x11>
  800536:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80053a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800541:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800548:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800554:	eb 28                	jmp    80057e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800558:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80055c:	eb 20                	jmp    80057e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800560:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800564:	eb 18                	jmp    80057e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800568:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80056f:	eb 0d                	jmp    80057e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800571:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800577:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8a 06                	mov    (%esi),%al
  800580:	0f b6 d0             	movzbl %al,%edx
  800583:	8d 5e 01             	lea    0x1(%esi),%ebx
  800586:	83 e8 23             	sub    $0x23,%eax
  800589:	3c 55                	cmp    $0x55,%al
  80058b:	0f 87 e0 02 00 00    	ja     800871 <vprintfmt+0x368>
  800591:	0f b6 c0             	movzbl %al,%eax
  800594:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059b:	83 ea 30             	sub    $0x30,%edx
  80059e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005a1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a7:	83 fa 09             	cmp    $0x9,%edx
  8005aa:	77 44                	ja     8005f0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	89 de                	mov    %ebx,%esi
  8005ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005b2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005bf:	83 fb 09             	cmp    $0x9,%ebx
  8005c2:	76 ed                	jbe    8005b1 <vprintfmt+0xa8>
  8005c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c7:	eb 29                	jmp    8005f2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d9:	eb 17                	jmp    8005f2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005df:	78 85                	js     800566 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	eb 99                	jmp    80057e <vprintfmt+0x75>
  8005e5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ee:	eb 8e                	jmp    80057e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f6:	79 86                	jns    80057e <vprintfmt+0x75>
  8005f8:	e9 74 ff ff ff       	jmp    800571 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	89 de                	mov    %ebx,%esi
  800600:	e9 79 ff ff ff       	jmp    80057e <vprintfmt+0x75>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	57                   	push   %edi
  800615:	ff 30                	pushl  (%eax)
  800617:	ff 55 08             	call   *0x8(%ebp)
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800620:	e9 08 ff ff ff       	jmp    80052d <vprintfmt+0x24>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	85 c0                	test   %eax,%eax
  800635:	79 02                	jns    800639 <vprintfmt+0x130>
  800637:	f7 d8                	neg    %eax
  800639:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063b:	83 f8 08             	cmp    $0x8,%eax
  80063e:	7f 0b                	jg     80064b <vprintfmt+0x142>
  800640:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  800647:	85 c0                	test   %eax,%eax
  800649:	75 1a                	jne    800665 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80064b:	52                   	push   %edx
  80064c:	68 96 0f 80 00       	push   $0x800f96
  800651:	57                   	push   %edi
  800652:	ff 75 08             	pushl  0x8(%ebp)
  800655:	e8 92 fe ff ff       	call   8004ec <printfmt>
  80065a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800660:	e9 c8 fe ff ff       	jmp    80052d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800665:	50                   	push   %eax
  800666:	68 9f 0f 80 00       	push   $0x800f9f
  80066b:	57                   	push   %edi
  80066c:	ff 75 08             	pushl  0x8(%ebp)
  80066f:	e8 78 fe ff ff       	call   8004ec <printfmt>
  800674:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80067a:	e9 ae fe ff ff       	jmp    80052d <vprintfmt+0x24>
  80067f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800682:	89 de                	mov    %ebx,%esi
  800684:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800687:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800698:	85 c0                	test   %eax,%eax
  80069a:	75 07                	jne    8006a3 <vprintfmt+0x19a>
				p = "(null)";
  80069c:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006a3:	85 db                	test   %ebx,%ebx
  8006a5:	7e 42                	jle    8006e9 <vprintfmt+0x1e0>
  8006a7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006ab:	74 3c                	je     8006e9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	51                   	push   %ecx
  8006b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b4:	e8 6f 02 00 00       	call   800928 <strnlen>
  8006b9:	29 c3                	sub    %eax,%ebx
  8006bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	85 db                	test   %ebx,%ebx
  8006c3:	7e 24                	jle    8006e9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006c5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006c9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	57                   	push   %edi
  8006d3:	53                   	push   %ebx
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	4e                   	dec    %esi
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	85 f6                	test   %esi,%esi
  8006dd:	7f f0                	jg     8006cf <vprintfmt+0x1c6>
  8006df:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ec:	0f be 02             	movsbl (%edx),%eax
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	75 47                	jne    80073a <vprintfmt+0x231>
  8006f3:	eb 37                	jmp    80072c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f9:	74 16                	je     800711 <vprintfmt+0x208>
  8006fb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006fe:	83 fa 5e             	cmp    $0x5e,%edx
  800701:	76 0e                	jbe    800711 <vprintfmt+0x208>
					putch('?', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	57                   	push   %edi
  800707:	6a 3f                	push   $0x3f
  800709:	ff 55 08             	call   *0x8(%ebp)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 0b                	jmp    80071c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	57                   	push   %edi
  800715:	50                   	push   %eax
  800716:	ff 55 08             	call   *0x8(%ebp)
  800719:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071c:	ff 4d e4             	decl   -0x1c(%ebp)
  80071f:	0f be 03             	movsbl (%ebx),%eax
  800722:	85 c0                	test   %eax,%eax
  800724:	74 03                	je     800729 <vprintfmt+0x220>
  800726:	43                   	inc    %ebx
  800727:	eb 1b                	jmp    800744 <vprintfmt+0x23b>
  800729:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800730:	7f 1e                	jg     800750 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800735:	e9 f3 fd ff ff       	jmp    80052d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073d:	43                   	inc    %ebx
  80073e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800741:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800744:	85 f6                	test   %esi,%esi
  800746:	78 ad                	js     8006f5 <vprintfmt+0x1ec>
  800748:	4e                   	dec    %esi
  800749:	79 aa                	jns    8006f5 <vprintfmt+0x1ec>
  80074b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80074e:	eb dc                	jmp    80072c <vprintfmt+0x223>
  800750:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	57                   	push   %edi
  800757:	6a 20                	push   $0x20
  800759:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	4b                   	dec    %ebx
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 db                	test   %ebx,%ebx
  800762:	7f ef                	jg     800753 <vprintfmt+0x24a>
  800764:	e9 c4 fd ff ff       	jmp    80052d <vprintfmt+0x24>
  800769:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80076c:	89 ca                	mov    %ecx,%edx
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 2a fd ff ff       	call   8004a0 <getint>
  800776:	89 c3                	mov    %eax,%ebx
  800778:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80077a:	85 d2                	test   %edx,%edx
  80077c:	78 0a                	js     800788 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800783:	e9 b0 00 00 00       	jmp    800838 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	57                   	push   %edi
  80078c:	6a 2d                	push   $0x2d
  80078e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800791:	f7 db                	neg    %ebx
  800793:	83 d6 00             	adc    $0x0,%esi
  800796:	f7 de                	neg    %esi
  800798:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80079b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a0:	e9 93 00 00 00       	jmp    800838 <vprintfmt+0x32f>
  8007a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a8:	89 ca                	mov    %ecx,%edx
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 b4 fc ff ff       	call   800466 <getuint>
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	89 d6                	mov    %edx,%esi
			base = 10;
  8007b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007bb:	eb 7b                	jmp    800838 <vprintfmt+0x32f>
  8007bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007c0:	89 ca                	mov    %ecx,%edx
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 d6 fc ff ff       	call   8004a0 <getint>
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	78 07                	js     8007d9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d7:	eb 5f                	jmp    800838 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	57                   	push   %edi
  8007dd:	6a 2d                	push   $0x2d
  8007df:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007e2:	f7 db                	neg    %ebx
  8007e4:	83 d6 00             	adc    $0x0,%esi
  8007e7:	f7 de                	neg    %esi
  8007e9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8007f1:	eb 45                	jmp    800838 <vprintfmt+0x32f>
  8007f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	57                   	push   %edi
  8007fa:	6a 30                	push   $0x30
  8007fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ff:	83 c4 08             	add    $0x8,%esp
  800802:	57                   	push   %edi
  800803:	6a 78                	push   $0x78
  800805:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800811:	8b 18                	mov    (%eax),%ebx
  800813:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800818:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800820:	eb 16                	jmp    800838 <vprintfmt+0x32f>
  800822:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800825:	89 ca                	mov    %ecx,%edx
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	e8 37 fc ff ff       	call   800466 <getuint>
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	89 d6                	mov    %edx,%esi
			base = 16;
  800833:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800838:	83 ec 0c             	sub    $0xc,%esp
  80083b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80083f:	52                   	push   %edx
  800840:	ff 75 e4             	pushl  -0x1c(%ebp)
  800843:	50                   	push   %eax
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	89 fa                	mov    %edi,%edx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	e8 68 fb ff ff       	call   8003b8 <printnum>
			break;
  800850:	83 c4 20             	add    $0x20,%esp
  800853:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800856:	e9 d2 fc ff ff       	jmp    80052d <vprintfmt+0x24>
  80085b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	57                   	push   %edi
  800862:	52                   	push   %edx
  800863:	ff 55 08             	call   *0x8(%ebp)
			break;
  800866:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800869:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80086c:	e9 bc fc ff ff       	jmp    80052d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	57                   	push   %edi
  800875:	6a 25                	push   $0x25
  800877:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 02                	jmp    800881 <vprintfmt+0x378>
  80087f:	89 c6                	mov    %eax,%esi
  800881:	8d 46 ff             	lea    -0x1(%esi),%eax
  800884:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800888:	75 f5                	jne    80087f <vprintfmt+0x376>
  80088a:	e9 9e fc ff ff       	jmp    80052d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80088f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5f                   	pop    %edi
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 18             	sub    $0x18,%esp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	74 26                	je     8008de <vsnprintf+0x47>
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	7e 29                	jle    8008e5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bc:	ff 75 14             	pushl  0x14(%ebp)
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c5:	50                   	push   %eax
  8008c6:	68 d2 04 80 00       	push   $0x8004d2
  8008cb:	e8 39 fc ff ff       	call   800509 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	eb 0c                	jmp    8008ea <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e3:	eb 05                	jmp    8008ea <vsnprintf+0x53>
  8008e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f5:	50                   	push   %eax
  8008f6:	ff 75 10             	pushl  0x10(%ebp)
  8008f9:	ff 75 0c             	pushl  0xc(%ebp)
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 93 ff ff ff       	call   800897 <vsnprintf>
	va_end(ap);

	return rc;
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    
	...

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	80 3a 00             	cmpb   $0x0,(%edx)
  800911:	74 0e                	je     800921 <strlen+0x19>
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800918:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800919:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091d:	75 f9                	jne    800918 <strlen+0x10>
  80091f:	eb 05                	jmp    800926 <strlen+0x1e>
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	85 d2                	test   %edx,%edx
  800933:	74 17                	je     80094c <strnlen+0x24>
  800935:	80 39 00             	cmpb   $0x0,(%ecx)
  800938:	74 19                	je     800953 <strnlen+0x2b>
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80093f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800940:	39 d0                	cmp    %edx,%eax
  800942:	74 14                	je     800958 <strnlen+0x30>
  800944:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800948:	75 f5                	jne    80093f <strnlen+0x17>
  80094a:	eb 0c                	jmp    800958 <strnlen+0x30>
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 05                	jmp    800958 <strnlen+0x30>
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
  800969:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80096c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80096f:	42                   	inc    %edx
  800970:	84 c9                	test   %cl,%cl
  800972:	75 f5                	jne    800969 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800974:	5b                   	pop    %ebx
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097e:	53                   	push   %ebx
  80097f:	e8 84 ff ff ff       	call   800908 <strlen>
  800984:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80098d:	50                   	push   %eax
  80098e:	e8 c7 ff ff ff       	call   80095a <strcpy>
	return dst;
}
  800993:	89 d8                	mov    %ebx,%eax
  800995:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a8:	85 f6                	test   %esi,%esi
  8009aa:	74 15                	je     8009c1 <strncpy+0x27>
  8009ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009b1:	8a 1a                	mov    (%edx),%bl
  8009b3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b6:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bc:	41                   	inc    %ecx
  8009bd:	39 ce                	cmp    %ecx,%esi
  8009bf:	77 f0                	ja     8009b1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d4:	85 f6                	test   %esi,%esi
  8009d6:	74 32                	je     800a0a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009d8:	83 fe 01             	cmp    $0x1,%esi
  8009db:	74 22                	je     8009ff <strlcpy+0x3a>
  8009dd:	8a 0b                	mov    (%ebx),%cl
  8009df:	84 c9                	test   %cl,%cl
  8009e1:	74 20                	je     800a03 <strlcpy+0x3e>
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009ea:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ed:	88 08                	mov    %cl,(%eax)
  8009ef:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f0:	39 f2                	cmp    %esi,%edx
  8009f2:	74 11                	je     800a05 <strlcpy+0x40>
  8009f4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009f8:	42                   	inc    %edx
  8009f9:	84 c9                	test   %cl,%cl
  8009fb:	75 f0                	jne    8009ed <strlcpy+0x28>
  8009fd:	eb 06                	jmp    800a05 <strlcpy+0x40>
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	eb 02                	jmp    800a05 <strlcpy+0x40>
  800a03:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a05:	c6 00 00             	movb   $0x0,(%eax)
  800a08:	eb 02                	jmp    800a0c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a0c:	29 f8                	sub    %edi,%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1c:	8a 01                	mov    (%ecx),%al
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 10                	je     800a32 <strcmp+0x1f>
  800a22:	3a 02                	cmp    (%edx),%al
  800a24:	75 0c                	jne    800a32 <strcmp+0x1f>
		p++, q++;
  800a26:	41                   	inc    %ecx
  800a27:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a28:	8a 01                	mov    (%ecx),%al
  800a2a:	84 c0                	test   %al,%al
  800a2c:	74 04                	je     800a32 <strcmp+0x1f>
  800a2e:	3a 02                	cmp    (%edx),%al
  800a30:	74 f4                	je     800a26 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a32:	0f b6 c0             	movzbl %al,%eax
  800a35:	0f b6 12             	movzbl (%edx),%edx
  800a38:	29 d0                	sub    %edx,%eax
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	53                   	push   %ebx
  800a40:	8b 55 08             	mov    0x8(%ebp),%edx
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 1b                	je     800a68 <strncmp+0x2c>
  800a4d:	8a 1a                	mov    (%edx),%bl
  800a4f:	84 db                	test   %bl,%bl
  800a51:	74 24                	je     800a77 <strncmp+0x3b>
  800a53:	3a 19                	cmp    (%ecx),%bl
  800a55:	75 20                	jne    800a77 <strncmp+0x3b>
  800a57:	48                   	dec    %eax
  800a58:	74 15                	je     800a6f <strncmp+0x33>
		n--, p++, q++;
  800a5a:	42                   	inc    %edx
  800a5b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5c:	8a 1a                	mov    (%edx),%bl
  800a5e:	84 db                	test   %bl,%bl
  800a60:	74 15                	je     800a77 <strncmp+0x3b>
  800a62:	3a 19                	cmp    (%ecx),%bl
  800a64:	74 f1                	je     800a57 <strncmp+0x1b>
  800a66:	eb 0f                	jmp    800a77 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	eb 05                	jmp    800a74 <strncmp+0x38>
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a74:	5b                   	pop    %ebx
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a77:	0f b6 02             	movzbl (%edx),%eax
  800a7a:	0f b6 11             	movzbl (%ecx),%edx
  800a7d:	29 d0                	sub    %edx,%eax
  800a7f:	eb f3                	jmp    800a74 <strncmp+0x38>

00800a81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a8a:	8a 10                	mov    (%eax),%dl
  800a8c:	84 d2                	test   %dl,%dl
  800a8e:	74 18                	je     800aa8 <strchr+0x27>
		if (*s == c)
  800a90:	38 ca                	cmp    %cl,%dl
  800a92:	75 06                	jne    800a9a <strchr+0x19>
  800a94:	eb 17                	jmp    800aad <strchr+0x2c>
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 13                	je     800aad <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	40                   	inc    %eax
  800a9b:	8a 10                	mov    (%eax),%dl
  800a9d:	84 d2                	test   %dl,%dl
  800a9f:	75 f5                	jne    800a96 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	eb 05                	jmp    800aad <strchr+0x2c>
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ab8:	8a 10                	mov    (%eax),%dl
  800aba:	84 d2                	test   %dl,%dl
  800abc:	74 11                	je     800acf <strfind+0x20>
		if (*s == c)
  800abe:	38 ca                	cmp    %cl,%dl
  800ac0:	75 06                	jne    800ac8 <strfind+0x19>
  800ac2:	eb 0b                	jmp    800acf <strfind+0x20>
  800ac4:	38 ca                	cmp    %cl,%dl
  800ac6:	74 07                	je     800acf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac8:	40                   	inc    %eax
  800ac9:	8a 10                	mov    (%eax),%dl
  800acb:	84 d2                	test   %dl,%dl
  800acd:	75 f5                	jne    800ac4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae0:	85 c9                	test   %ecx,%ecx
  800ae2:	74 30                	je     800b14 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aea:	75 25                	jne    800b11 <memset+0x40>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 20                	jne    800b11 <memset+0x40>
		c &= 0xFF;
  800af1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	c1 e3 08             	shl    $0x8,%ebx
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	c1 e6 18             	shl    $0x18,%esi
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	c1 e0 10             	shl    $0x10,%eax
  800b03:	09 f0                	or     %esi,%eax
  800b05:	09 d0                	or     %edx,%eax
  800b07:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b09:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b0c:	fc                   	cld    
  800b0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0f:	eb 03                	jmp    800b14 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b11:	fc                   	cld    
  800b12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b29:	39 c6                	cmp    %eax,%esi
  800b2b:	73 34                	jae    800b61 <memmove+0x46>
  800b2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 2d                	jae    800b61 <memmove+0x46>
		s += n;
		d += n;
  800b34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b37:	f6 c2 03             	test   $0x3,%dl
  800b3a:	75 1b                	jne    800b57 <memmove+0x3c>
  800b3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b42:	75 13                	jne    800b57 <memmove+0x3c>
  800b44:	f6 c1 03             	test   $0x3,%cl
  800b47:	75 0e                	jne    800b57 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b49:	83 ef 04             	sub    $0x4,%edi
  800b4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b52:	fd                   	std    
  800b53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b55:	eb 07                	jmp    800b5e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b57:	4f                   	dec    %edi
  800b58:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5b:	fd                   	std    
  800b5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5e:	fc                   	cld    
  800b5f:	eb 20                	jmp    800b81 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b67:	75 13                	jne    800b7c <memmove+0x61>
  800b69:	a8 03                	test   $0x3,%al
  800b6b:	75 0f                	jne    800b7c <memmove+0x61>
  800b6d:	f6 c1 03             	test   $0x3,%cl
  800b70:	75 0a                	jne    800b7c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b72:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	fc                   	cld    
  800b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7a:	eb 05                	jmp    800b81 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7c:	89 c7                	mov    %eax,%edi
  800b7e:	fc                   	cld    
  800b7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 85 ff ff ff       	call   800b1b <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ba1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba7:	85 ff                	test   %edi,%edi
  800ba9:	74 32                	je     800bdd <memcmp+0x45>
		if (*s1 != *s2)
  800bab:	8a 03                	mov    (%ebx),%al
  800bad:	8a 0e                	mov    (%esi),%cl
  800baf:	38 c8                	cmp    %cl,%al
  800bb1:	74 19                	je     800bcc <memcmp+0x34>
  800bb3:	eb 0d                	jmp    800bc2 <memcmp+0x2a>
  800bb5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bb9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bbd:	42                   	inc    %edx
  800bbe:	38 c8                	cmp    %cl,%al
  800bc0:	74 10                	je     800bd2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bc2:	0f b6 c0             	movzbl %al,%eax
  800bc5:	0f b6 c9             	movzbl %cl,%ecx
  800bc8:	29 c8                	sub    %ecx,%eax
  800bca:	eb 16                	jmp    800be2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	4f                   	dec    %edi
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	39 fa                	cmp    %edi,%edx
  800bd4:	75 df                	jne    800bb5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdb:	eb 05                	jmp    800be2 <memcmp+0x4a>
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf2:	39 d0                	cmp    %edx,%eax
  800bf4:	73 12                	jae    800c08 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bf9:	38 08                	cmp    %cl,(%eax)
  800bfb:	75 06                	jne    800c03 <memfind+0x1c>
  800bfd:	eb 09                	jmp    800c08 <memfind+0x21>
  800bff:	38 08                	cmp    %cl,(%eax)
  800c01:	74 05                	je     800c08 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c03:	40                   	inc    %eax
  800c04:	39 c2                	cmp    %eax,%edx
  800c06:	77 f7                	ja     800bff <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c16:	eb 01                	jmp    800c19 <strtol+0xf>
		s++;
  800c18:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	8a 02                	mov    (%edx),%al
  800c1b:	3c 20                	cmp    $0x20,%al
  800c1d:	74 f9                	je     800c18 <strtol+0xe>
  800c1f:	3c 09                	cmp    $0x9,%al
  800c21:	74 f5                	je     800c18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c23:	3c 2b                	cmp    $0x2b,%al
  800c25:	75 08                	jne    800c2f <strtol+0x25>
		s++;
  800c27:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c28:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2d:	eb 13                	jmp    800c42 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2f:	3c 2d                	cmp    $0x2d,%al
  800c31:	75 0a                	jne    800c3d <strtol+0x33>
		s++, neg = 1;
  800c33:	8d 52 01             	lea    0x1(%edx),%edx
  800c36:	bf 01 00 00 00       	mov    $0x1,%edi
  800c3b:	eb 05                	jmp    800c42 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c42:	85 db                	test   %ebx,%ebx
  800c44:	74 05                	je     800c4b <strtol+0x41>
  800c46:	83 fb 10             	cmp    $0x10,%ebx
  800c49:	75 28                	jne    800c73 <strtol+0x69>
  800c4b:	8a 02                	mov    (%edx),%al
  800c4d:	3c 30                	cmp    $0x30,%al
  800c4f:	75 10                	jne    800c61 <strtol+0x57>
  800c51:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c55:	75 0a                	jne    800c61 <strtol+0x57>
		s += 2, base = 16;
  800c57:	83 c2 02             	add    $0x2,%edx
  800c5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5f:	eb 12                	jmp    800c73 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c61:	85 db                	test   %ebx,%ebx
  800c63:	75 0e                	jne    800c73 <strtol+0x69>
  800c65:	3c 30                	cmp    $0x30,%al
  800c67:	75 05                	jne    800c6e <strtol+0x64>
		s++, base = 8;
  800c69:	42                   	inc    %edx
  800c6a:	b3 08                	mov    $0x8,%bl
  800c6c:	eb 05                	jmp    800c73 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7a:	8a 0a                	mov    (%edx),%cl
  800c7c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c7f:	80 fb 09             	cmp    $0x9,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x82>
			dig = *s - '0';
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 30             	sub    $0x30,%ecx
  800c8a:	eb 1e                	jmp    800caa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c8c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c8f:	80 fb 19             	cmp    $0x19,%bl
  800c92:	77 08                	ja     800c9c <strtol+0x92>
			dig = *s - 'a' + 10;
  800c94:	0f be c9             	movsbl %cl,%ecx
  800c97:	83 e9 57             	sub    $0x57,%ecx
  800c9a:	eb 0e                	jmp    800caa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c9c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c9f:	80 fb 19             	cmp    $0x19,%bl
  800ca2:	77 13                	ja     800cb7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ca4:	0f be c9             	movsbl %cl,%ecx
  800ca7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800caa:	39 f1                	cmp    %esi,%ecx
  800cac:	7d 0d                	jge    800cbb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cae:	42                   	inc    %edx
  800caf:	0f af c6             	imul   %esi,%eax
  800cb2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cb5:	eb c3                	jmp    800c7a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cb7:	89 c1                	mov    %eax,%ecx
  800cb9:	eb 02                	jmp    800cbd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cbb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc1:	74 05                	je     800cc8 <strtol+0xbe>
		*endptr = (char *) s;
  800cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc8:	85 ff                	test   %edi,%edi
  800cca:	74 04                	je     800cd0 <strtol+0xc6>
  800ccc:	89 c8                	mov    %ecx,%eax
  800cce:	f7 d8                	neg    %eax
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    
  800cd5:	00 00                	add    %al,(%eax)
	...

00800cd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	83 ec 10             	sub    $0x10,%esp
  800ce0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ce9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cef:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	75 2e                	jne    800d24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cf6:	39 f1                	cmp    %esi,%ecx
  800cf8:	77 5a                	ja     800d54 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cfa:	85 c9                	test   %ecx,%ecx
  800cfc:	75 0b                	jne    800d09 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800d03:	31 d2                	xor    %edx,%edx
  800d05:	f7 f1                	div    %ecx
  800d07:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d09:	31 d2                	xor    %edx,%edx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	f7 f1                	div    %ecx
  800d0f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d11:	89 f8                	mov    %edi,%eax
  800d13:	f7 f1                	div    %ecx
  800d15:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d17:	89 f8                	mov    %edi,%eax
  800d19:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d1b:	83 c4 10             	add    $0x10,%esp
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    
  800d22:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d24:	39 f0                	cmp    %esi,%eax
  800d26:	77 1c                	ja     800d44 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d28:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d2b:	83 f7 1f             	xor    $0x1f,%edi
  800d2e:	75 3c                	jne    800d6c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d30:	39 f0                	cmp    %esi,%eax
  800d32:	0f 82 90 00 00 00    	jb     800dc8 <__udivdi3+0xf0>
  800d38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d3b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d3e:	0f 86 84 00 00 00    	jbe    800dc8 <__udivdi3+0xf0>
  800d44:	31 f6                	xor    %esi,%esi
  800d46:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d48:	89 f8                	mov    %edi,%eax
  800d4a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    
  800d53:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d54:	89 f2                	mov    %esi,%edx
  800d56:	89 f8                	mov    %edi,%eax
  800d58:	f7 f1                	div    %ecx
  800d5a:	89 c7                	mov    %eax,%edi
  800d5c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5e:	89 f8                	mov    %edi,%eax
  800d60:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    
  800d69:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d6c:	89 f9                	mov    %edi,%ecx
  800d6e:	d3 e0                	shl    %cl,%eax
  800d70:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d73:	b8 20 00 00 00       	mov    $0x20,%eax
  800d78:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d7d:	88 c1                	mov    %al,%cl
  800d7f:	d3 ea                	shr    %cl,%edx
  800d81:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d84:	09 ca                	or     %ecx,%edx
  800d86:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d8c:	89 f9                	mov    %edi,%ecx
  800d8e:	d3 e2                	shl    %cl,%edx
  800d90:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d93:	89 f2                	mov    %esi,%edx
  800d95:	88 c1                	mov    %al,%cl
  800d97:	d3 ea                	shr    %cl,%edx
  800d99:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d9c:	89 f2                	mov    %esi,%edx
  800d9e:	89 f9                	mov    %edi,%ecx
  800da0:	d3 e2                	shl    %cl,%edx
  800da2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800da5:	88 c1                	mov    %al,%cl
  800da7:	d3 ee                	shr    %cl,%esi
  800da9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800dae:	89 f0                	mov    %esi,%eax
  800db0:	89 ca                	mov    %ecx,%edx
  800db2:	f7 75 ec             	divl   -0x14(%ebp)
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800db9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dbc:	39 d1                	cmp    %edx,%ecx
  800dbe:	72 28                	jb     800de8 <__udivdi3+0x110>
  800dc0:	74 1a                	je     800ddc <__udivdi3+0x104>
  800dc2:	89 f7                	mov    %esi,%edi
  800dc4:	31 f6                	xor    %esi,%esi
  800dc6:	eb 80                	jmp    800d48 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc8:	31 f6                	xor    %esi,%esi
  800dca:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dcf:	89 f8                	mov    %edi,%eax
  800dd1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    
  800dda:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ddc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ddf:	89 f9                	mov    %edi,%ecx
  800de1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de3:	39 c2                	cmp    %eax,%edx
  800de5:	73 db                	jae    800dc2 <__udivdi3+0xea>
  800de7:	90                   	nop
		{
		  q0--;
  800de8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800deb:	31 f6                	xor    %esi,%esi
  800ded:	e9 56 ff ff ff       	jmp    800d48 <__udivdi3+0x70>
	...

00800df4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	83 ec 20             	sub    $0x20,%esp
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e02:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e05:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e11:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e13:	85 ff                	test   %edi,%edi
  800e15:	75 15                	jne    800e2c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e17:	39 f1                	cmp    %esi,%ecx
  800e19:	0f 86 99 00 00 00    	jbe    800eb8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e21:	89 d0                	mov    %edx,%eax
  800e23:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e2c:	39 f7                	cmp    %esi,%edi
  800e2e:	0f 87 a4 00 00 00    	ja     800ed8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e34:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e37:	83 f0 1f             	xor    $0x1f,%eax
  800e3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e3d:	0f 84 a1 00 00 00    	je     800ee4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e43:	89 f8                	mov    %edi,%eax
  800e45:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e48:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e4f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 ea                	shr    %cl,%edx
  800e59:	09 c2                	or     %eax,%edx
  800e5b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e61:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e64:	d3 e0                	shl    %cl,%eax
  800e66:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e69:	89 f2                	mov    %esi,%edx
  800e6b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e70:	d3 e0                	shl    %cl,%eax
  800e72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e75:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e78:	89 f9                	mov    %edi,%ecx
  800e7a:	d3 e8                	shr    %cl,%eax
  800e7c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e7e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e80:	89 f2                	mov    %esi,%edx
  800e82:	f7 75 f0             	divl   -0x10(%ebp)
  800e85:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e87:	f7 65 f4             	mull   -0xc(%ebp)
  800e8a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e8d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8f:	39 d6                	cmp    %edx,%esi
  800e91:	72 71                	jb     800f04 <__umoddi3+0x110>
  800e93:	74 7f                	je     800f14 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e98:	29 c8                	sub    %ecx,%eax
  800e9a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e9c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e9f:	d3 e8                	shr    %cl,%eax
  800ea1:	89 f2                	mov    %esi,%edx
  800ea3:	89 f9                	mov    %edi,%ecx
  800ea5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ea7:	09 d0                	or     %edx,%eax
  800ea9:	89 f2                	mov    %esi,%edx
  800eab:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eae:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb0:	83 c4 20             	add    $0x20,%esp
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb8:	85 c9                	test   %ecx,%ecx
  800eba:	75 0b                	jne    800ec7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 f1                	div    %ecx
  800ec5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec7:	89 f0                	mov    %esi,%eax
  800ec9:	31 d2                	xor    %edx,%edx
  800ecb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed0:	f7 f1                	div    %ecx
  800ed2:	e9 4a ff ff ff       	jmp    800e21 <__umoddi3+0x2d>
  800ed7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    
  800ee1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee4:	39 f7                	cmp    %esi,%edi
  800ee6:	72 05                	jb     800eed <__umoddi3+0xf9>
  800ee8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800eeb:	77 0c                	ja     800ef9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef2:	29 c8                	sub    %ecx,%eax
  800ef4:	19 fa                	sbb    %edi,%edx
  800ef6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    
  800f03:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f04:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f07:	89 c1                	mov    %eax,%ecx
  800f09:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f0c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f0f:	eb 84                	jmp    800e95 <__umoddi3+0xa1>
  800f11:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f14:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f17:	72 eb                	jb     800f04 <__umoddi3+0x110>
  800f19:	89 f2                	mov    %esi,%edx
  800f1b:	e9 75 ff ff ff       	jmp    800e95 <__umoddi3+0xa1>
