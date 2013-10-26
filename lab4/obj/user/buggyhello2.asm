
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
  800045:	e8 af 00 00 00       	call   8000f9 <sys_cputs>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005b:	e8 05 01 00 00       	call   800165 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	c1 e0 07             	shl    $0x7,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x2d>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	53                   	push   %ebx
  800081:	56                   	push   %esi
  800082:	e8 ad ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800087:	e8 0c 00 00 00       	call   800098 <exit>
  80008c:	83 c4 10             	add    $0x10,%esp
}
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  8000de:	68 58 0f 80 00       	push   $0x800f58
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 75 0f 80 00       	push   $0x800f75
  8000ea:	e8 e1 01 00 00       	call   8002d0 <_panic>

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
  8001a1:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800240 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

00800263 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800269:	6a 00                	push   $0x0
  80026b:	ff 75 14             	pushl  0x14(%ebp)
  80026e:	ff 75 10             	pushl  0x10(%ebp)
  800271:	ff 75 0c             	pushl  0xc(%ebp)
  800274:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800277:	ba 00 00 00 00       	mov    $0x0,%edx
  80027c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800281:	e8 26 fe ff ff       	call   8000ac <syscall>
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80028e:	6a 00                	push   $0x0
  800290:	6a 00                	push   $0x0
  800292:	6a 00                	push   $0x0
  800294:	6a 00                	push   $0x0
  800296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800299:	ba 01 00 00 00       	mov    $0x1,%edx
  80029e:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002a3:	e8 04 fe ff ff       	call   8000ac <syscall>
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002b0:	6a 00                	push   $0x0
  8002b2:	6a 00                	push   $0x0
  8002b4:	6a 00                	push   $0x0
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002c6:	e8 e1 fd ff ff       	call   8000ac <syscall>
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d8:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8002de:	e8 82 fe ff ff       	call   800165 <sys_getenvid>
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	ff 75 0c             	pushl  0xc(%ebp)
  8002e9:	ff 75 08             	pushl  0x8(%ebp)
  8002ec:	53                   	push   %ebx
  8002ed:	50                   	push   %eax
  8002ee:	68 84 0f 80 00       	push   $0x800f84
  8002f3:	e8 b0 00 00 00       	call   8003a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	56                   	push   %esi
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	e8 53 00 00 00       	call   800357 <vcprintf>
	cprintf("\n");
  800304:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  80030b:	e8 98 00 00 00       	call   8003a8 <cprintf>
  800310:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800313:	cc                   	int3   
  800314:	eb fd                	jmp    800313 <_panic+0x43>
	...

00800318 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	53                   	push   %ebx
  80031c:	83 ec 04             	sub    $0x4,%esp
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800322:	8b 03                	mov    (%ebx),%eax
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80032b:	40                   	inc    %eax
  80032c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80032e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800333:	75 1a                	jne    80034f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 ff 00 00 00       	push   $0xff
  80033d:	8d 43 08             	lea    0x8(%ebx),%eax
  800340:	50                   	push   %eax
  800341:	e8 b3 fd ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  800346:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80034c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034f:	ff 43 04             	incl   0x4(%ebx)
}
  800352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800355:	c9                   	leave  
  800356:	c3                   	ret    

00800357 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800360:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800367:	00 00 00 
	b.cnt = 0;
  80036a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800371:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800374:	ff 75 0c             	pushl  0xc(%ebp)
  800377:	ff 75 08             	pushl  0x8(%ebp)
  80037a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800380:	50                   	push   %eax
  800381:	68 18 03 80 00       	push   $0x800318
  800386:	e8 82 01 00 00       	call   80050d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80038b:	83 c4 08             	add    $0x8,%esp
  80038e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800394:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80039a:	50                   	push   %eax
  80039b:	e8 59 fd ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  8003a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b1:	50                   	push   %eax
  8003b2:	ff 75 08             	pushl  0x8(%ebp)
  8003b5:	e8 9d ff ff ff       	call   800357 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 2c             	sub    $0x2c,%esp
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	89 d6                	mov    %edx,%esi
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003dc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003e9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003ec:	72 0c                	jb     8003fa <printnum+0x3e>
  8003ee:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003f1:	76 07                	jbe    8003fa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f3:	4b                   	dec    %ebx
  8003f4:	85 db                	test   %ebx,%ebx
  8003f6:	7f 31                	jg     800429 <printnum+0x6d>
  8003f8:	eb 3f                	jmp    800439 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003fa:	83 ec 0c             	sub    $0xc,%esp
  8003fd:	57                   	push   %edi
  8003fe:	4b                   	dec    %ebx
  8003ff:	53                   	push   %ebx
  800400:	50                   	push   %eax
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	ff 75 d4             	pushl  -0x2c(%ebp)
  800407:	ff 75 d0             	pushl  -0x30(%ebp)
  80040a:	ff 75 dc             	pushl  -0x24(%ebp)
  80040d:	ff 75 d8             	pushl  -0x28(%ebp)
  800410:	e8 c7 08 00 00       	call   800cdc <__udivdi3>
  800415:	83 c4 18             	add    $0x18,%esp
  800418:	52                   	push   %edx
  800419:	50                   	push   %eax
  80041a:	89 f2                	mov    %esi,%edx
  80041c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041f:	e8 98 ff ff ff       	call   8003bc <printnum>
  800424:	83 c4 20             	add    $0x20,%esp
  800427:	eb 10                	jmp    800439 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	56                   	push   %esi
  80042d:	57                   	push   %edi
  80042e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	4b                   	dec    %ebx
  800432:	83 c4 10             	add    $0x10,%esp
  800435:	85 db                	test   %ebx,%ebx
  800437:	7f f0                	jg     800429 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	56                   	push   %esi
  80043d:	83 ec 04             	sub    $0x4,%esp
  800440:	ff 75 d4             	pushl  -0x2c(%ebp)
  800443:	ff 75 d0             	pushl  -0x30(%ebp)
  800446:	ff 75 dc             	pushl  -0x24(%ebp)
  800449:	ff 75 d8             	pushl  -0x28(%ebp)
  80044c:	e8 a7 09 00 00       	call   800df8 <__umoddi3>
  800451:	83 c4 14             	add    $0x14,%esp
  800454:	0f be 80 a8 0f 80 00 	movsbl 0x800fa8(%eax),%eax
  80045b:	50                   	push   %eax
  80045c:	ff 55 e4             	call   *-0x1c(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
}
  800462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7e 0e                	jle    800480 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 08             	lea    0x8(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	8b 52 04             	mov    0x4(%edx),%edx
  80047e:	eb 22                	jmp    8004a2 <getuint+0x38>
	else if (lflag)
  800480:	85 d2                	test   %edx,%edx
  800482:	74 10                	je     800494 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb 0e                	jmp    8004a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 04             	lea    0x4(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a7:	83 fa 01             	cmp    $0x1,%edx
  8004aa:	7e 0e                	jle    8004ba <getint+0x16>
		return va_arg(*ap, long long);
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	8b 52 04             	mov    0x4(%edx),%edx
  8004b8:	eb 1a                	jmp    8004d4 <getint+0x30>
	else if (lflag)
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	74 0c                	je     8004ca <getint+0x26>
		return va_arg(*ap, long);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	99                   	cltd   
  8004c8:	eb 0a                	jmp    8004d4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cf:	89 08                	mov    %ecx,(%eax)
  8004d1:	8b 02                	mov    (%edx),%eax
  8004d3:	99                   	cltd   
}
  8004d4:	c9                   	leave  
  8004d5:	c3                   	ret    

008004d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004dc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e4:	73 08                	jae    8004ee <sprintputch+0x18>
		*b->buf++ = ch;
  8004e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e9:	88 0a                	mov    %cl,(%edx)
  8004eb:	42                   	inc    %edx
  8004ec:	89 10                	mov    %edx,(%eax)
}
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f9:	50                   	push   %eax
  8004fa:	ff 75 10             	pushl  0x10(%ebp)
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 05 00 00 00       	call   80050d <vprintfmt>
	va_end(ap);
  800508:	83 c4 10             	add    $0x10,%esp
}
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 2c             	sub    $0x2c,%esp
  800516:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800519:	8b 75 10             	mov    0x10(%ebp),%esi
  80051c:	eb 13                	jmp    800531 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051e:	85 c0                	test   %eax,%eax
  800520:	0f 84 6d 03 00 00    	je     800893 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	57                   	push   %edi
  80052a:	50                   	push   %eax
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800531:	0f b6 06             	movzbl (%esi),%eax
  800534:	46                   	inc    %esi
  800535:	83 f8 25             	cmp    $0x25,%eax
  800538:	75 e4                	jne    80051e <vprintfmt+0x11>
  80053a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80053e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800545:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80054c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
  800558:	eb 28                	jmp    800582 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800560:	eb 20                	jmp    800582 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800564:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800568:	eb 18                	jmp    800582 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80056c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800573:	eb 0d                	jmp    800582 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800575:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800578:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8a 06                	mov    (%esi),%al
  800584:	0f b6 d0             	movzbl %al,%edx
  800587:	8d 5e 01             	lea    0x1(%esi),%ebx
  80058a:	83 e8 23             	sub    $0x23,%eax
  80058d:	3c 55                	cmp    $0x55,%al
  80058f:	0f 87 e0 02 00 00    	ja     800875 <vprintfmt+0x368>
  800595:	0f b6 c0             	movzbl %al,%eax
  800598:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059f:	83 ea 30             	sub    $0x30,%edx
  8005a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005a5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005a8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005ab:	83 fa 09             	cmp    $0x9,%edx
  8005ae:	77 44                	ja     8005f4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	89 de                	mov    %ebx,%esi
  8005b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005b6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005bd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005c0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005c3:	83 fb 09             	cmp    $0x9,%ebx
  8005c6:	76 ed                	jbe    8005b5 <vprintfmt+0xa8>
  8005c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005cb:	eb 29                	jmp    8005f6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dd:	eb 17                	jmp    8005f6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e3:	78 85                	js     80056a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	eb 99                	jmp    800582 <vprintfmt+0x75>
  8005e9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005eb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005f2:	eb 8e                	jmp    800582 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fa:	79 86                	jns    800582 <vprintfmt+0x75>
  8005fc:	e9 74 ff ff ff       	jmp    800575 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800601:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	89 de                	mov    %ebx,%esi
  800604:	e9 79 ff ff ff       	jmp    800582 <vprintfmt+0x75>
  800609:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	57                   	push   %edi
  800619:	ff 30                	pushl  (%eax)
  80061b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800624:	e9 08 ff ff ff       	jmp    800531 <vprintfmt+0x24>
  800629:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	85 c0                	test   %eax,%eax
  800639:	79 02                	jns    80063d <vprintfmt+0x130>
  80063b:	f7 d8                	neg    %eax
  80063d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063f:	83 f8 08             	cmp    $0x8,%eax
  800642:	7f 0b                	jg     80064f <vprintfmt+0x142>
  800644:	8b 04 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%eax
  80064b:	85 c0                	test   %eax,%eax
  80064d:	75 1a                	jne    800669 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80064f:	52                   	push   %edx
  800650:	68 c0 0f 80 00       	push   $0x800fc0
  800655:	57                   	push   %edi
  800656:	ff 75 08             	pushl  0x8(%ebp)
  800659:	e8 92 fe ff ff       	call   8004f0 <printfmt>
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800664:	e9 c8 fe ff ff       	jmp    800531 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800669:	50                   	push   %eax
  80066a:	68 c9 0f 80 00       	push   $0x800fc9
  80066f:	57                   	push   %edi
  800670:	ff 75 08             	pushl  0x8(%ebp)
  800673:	e8 78 fe ff ff       	call   8004f0 <printfmt>
  800678:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80067e:	e9 ae fe ff ff       	jmp    800531 <vprintfmt+0x24>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800686:	89 de                	mov    %ebx,%esi
  800688:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069c:	85 c0                	test   %eax,%eax
  80069e:	75 07                	jne    8006a7 <vprintfmt+0x19a>
				p = "(null)";
  8006a0:	c7 45 d0 b9 0f 80 00 	movl   $0x800fb9,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006a7:	85 db                	test   %ebx,%ebx
  8006a9:	7e 42                	jle    8006ed <vprintfmt+0x1e0>
  8006ab:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006af:	74 3c                	je     8006ed <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	51                   	push   %ecx
  8006b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b8:	e8 6f 02 00 00       	call   80092c <strnlen>
  8006bd:	29 c3                	sub    %eax,%ebx
  8006bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 db                	test   %ebx,%ebx
  8006c7:	7e 24                	jle    8006ed <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006c9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006cd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006d0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	57                   	push   %edi
  8006d7:	53                   	push   %ebx
  8006d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006db:	4e                   	dec    %esi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	85 f6                	test   %esi,%esi
  8006e1:	7f f0                	jg     8006d3 <vprintfmt+0x1c6>
  8006e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006f0:	0f be 02             	movsbl (%edx),%eax
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	75 47                	jne    80073e <vprintfmt+0x231>
  8006f7:	eb 37                	jmp    800730 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fd:	74 16                	je     800715 <vprintfmt+0x208>
  8006ff:	8d 50 e0             	lea    -0x20(%eax),%edx
  800702:	83 fa 5e             	cmp    $0x5e,%edx
  800705:	76 0e                	jbe    800715 <vprintfmt+0x208>
					putch('?', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	57                   	push   %edi
  80070b:	6a 3f                	push   $0x3f
  80070d:	ff 55 08             	call   *0x8(%ebp)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 0b                	jmp    800720 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	57                   	push   %edi
  800719:	50                   	push   %eax
  80071a:	ff 55 08             	call   *0x8(%ebp)
  80071d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	ff 4d e4             	decl   -0x1c(%ebp)
  800723:	0f be 03             	movsbl (%ebx),%eax
  800726:	85 c0                	test   %eax,%eax
  800728:	74 03                	je     80072d <vprintfmt+0x220>
  80072a:	43                   	inc    %ebx
  80072b:	eb 1b                	jmp    800748 <vprintfmt+0x23b>
  80072d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800730:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800734:	7f 1e                	jg     800754 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800739:	e9 f3 fd ff ff       	jmp    800531 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800741:	43                   	inc    %ebx
  800742:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800745:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800748:	85 f6                	test   %esi,%esi
  80074a:	78 ad                	js     8006f9 <vprintfmt+0x1ec>
  80074c:	4e                   	dec    %esi
  80074d:	79 aa                	jns    8006f9 <vprintfmt+0x1ec>
  80074f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800752:	eb dc                	jmp    800730 <vprintfmt+0x223>
  800754:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	57                   	push   %edi
  80075b:	6a 20                	push   $0x20
  80075d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800760:	4b                   	dec    %ebx
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	85 db                	test   %ebx,%ebx
  800766:	7f ef                	jg     800757 <vprintfmt+0x24a>
  800768:	e9 c4 fd ff ff       	jmp    800531 <vprintfmt+0x24>
  80076d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800770:	89 ca                	mov    %ecx,%edx
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
  800775:	e8 2a fd ff ff       	call   8004a4 <getint>
  80077a:	89 c3                	mov    %eax,%ebx
  80077c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80077e:	85 d2                	test   %edx,%edx
  800780:	78 0a                	js     80078c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800782:	b8 0a 00 00 00       	mov    $0xa,%eax
  800787:	e9 b0 00 00 00       	jmp    80083c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	57                   	push   %edi
  800790:	6a 2d                	push   $0x2d
  800792:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800795:	f7 db                	neg    %ebx
  800797:	83 d6 00             	adc    $0x0,%esi
  80079a:	f7 de                	neg    %esi
  80079c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80079f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a4:	e9 93 00 00 00       	jmp    80083c <vprintfmt+0x32f>
  8007a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ac:	89 ca                	mov    %ecx,%edx
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	e8 b4 fc ff ff       	call   80046a <getuint>
  8007b6:	89 c3                	mov    %eax,%ebx
  8007b8:	89 d6                	mov    %edx,%esi
			base = 10;
  8007ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007bf:	eb 7b                	jmp    80083c <vprintfmt+0x32f>
  8007c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 d6 fc ff ff       	call   8004a4 <getint>
  8007ce:	89 c3                	mov    %eax,%ebx
  8007d0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	78 07                	js     8007dd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007db:	eb 5f                	jmp    80083c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	57                   	push   %edi
  8007e1:	6a 2d                	push   $0x2d
  8007e3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007e6:	f7 db                	neg    %ebx
  8007e8:	83 d6 00             	adc    $0x0,%esi
  8007eb:	f7 de                	neg    %esi
  8007ed:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007f5:	eb 45                	jmp    80083c <vprintfmt+0x32f>
  8007f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	57                   	push   %edi
  8007fe:	6a 30                	push   $0x30
  800800:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	57                   	push   %edi
  800807:	6a 78                	push   $0x78
  800809:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 04             	lea    0x4(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800815:	8b 18                	mov    (%eax),%ebx
  800817:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800824:	eb 16                	jmp    80083c <vprintfmt+0x32f>
  800826:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800829:	89 ca                	mov    %ecx,%edx
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
  80082e:	e8 37 fc ff ff       	call   80046a <getuint>
  800833:	89 c3                	mov    %eax,%ebx
  800835:	89 d6                	mov    %edx,%esi
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083c:	83 ec 0c             	sub    $0xc,%esp
  80083f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800843:	52                   	push   %edx
  800844:	ff 75 e4             	pushl  -0x1c(%ebp)
  800847:	50                   	push   %eax
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	89 fa                	mov    %edi,%edx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	e8 68 fb ff ff       	call   8003bc <printnum>
			break;
  800854:	83 c4 20             	add    $0x20,%esp
  800857:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80085a:	e9 d2 fc ff ff       	jmp    800531 <vprintfmt+0x24>
  80085f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	57                   	push   %edi
  800866:	52                   	push   %edx
  800867:	ff 55 08             	call   *0x8(%ebp)
			break;
  80086a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800870:	e9 bc fc ff ff       	jmp    800531 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	57                   	push   %edi
  800879:	6a 25                	push   $0x25
  80087b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	eb 02                	jmp    800885 <vprintfmt+0x378>
  800883:	89 c6                	mov    %eax,%esi
  800885:	8d 46 ff             	lea    -0x1(%esi),%eax
  800888:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80088c:	75 f5                	jne    800883 <vprintfmt+0x376>
  80088e:	e9 9e fc ff ff       	jmp    800531 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800893:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 18             	sub    $0x18,%esp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	74 26                	je     8008e2 <vsnprintf+0x47>
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	7e 29                	jle    8008e9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c0:	ff 75 14             	pushl  0x14(%ebp)
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	68 d6 04 80 00       	push   $0x8004d6
  8008cf:	e8 39 fc ff ff       	call   80050d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	eb 0c                	jmp    8008ee <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e7:	eb 05                	jmp    8008ee <vsnprintf+0x53>
  8008e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f9:	50                   	push   %eax
  8008fa:	ff 75 10             	pushl  0x10(%ebp)
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 93 ff ff ff       	call   80089b <vsnprintf>
	va_end(ap);

	return rc;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    
	...

0080090c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800912:	80 3a 00             	cmpb   $0x0,(%edx)
  800915:	74 0e                	je     800925 <strlen+0x19>
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800921:	75 f9                	jne    80091c <strlen+0x10>
  800923:	eb 05                	jmp    80092a <strlen+0x1e>
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	85 d2                	test   %edx,%edx
  800937:	74 17                	je     800950 <strnlen+0x24>
  800939:	80 39 00             	cmpb   $0x0,(%ecx)
  80093c:	74 19                	je     800957 <strnlen+0x2b>
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800943:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800944:	39 d0                	cmp    %edx,%eax
  800946:	74 14                	je     80095c <strnlen+0x30>
  800948:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80094c:	75 f5                	jne    800943 <strnlen+0x17>
  80094e:	eb 0c                	jmp    80095c <strnlen+0x30>
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
  800955:	eb 05                	jmp    80095c <strnlen+0x30>
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
  80096d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800970:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800973:	42                   	inc    %edx
  800974:	84 c9                	test   %cl,%cl
  800976:	75 f5                	jne    80096d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800978:	5b                   	pop    %ebx
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800982:	53                   	push   %ebx
  800983:	e8 84 ff ff ff       	call   80090c <strlen>
  800988:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800991:	50                   	push   %eax
  800992:	e8 c7 ff ff ff       	call   80095e <strcpy>
	return dst;
}
  800997:	89 d8                	mov    %ebx,%eax
  800999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	85 f6                	test   %esi,%esi
  8009ae:	74 15                	je     8009c5 <strncpy+0x27>
  8009b0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009b5:	8a 1a                	mov    (%edx),%bl
  8009b7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ba:	80 3a 01             	cmpb   $0x1,(%edx)
  8009bd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c0:	41                   	inc    %ecx
  8009c1:	39 ce                	cmp    %ecx,%esi
  8009c3:	77 f0                	ja     8009b5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d8:	85 f6                	test   %esi,%esi
  8009da:	74 32                	je     800a0e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009dc:	83 fe 01             	cmp    $0x1,%esi
  8009df:	74 22                	je     800a03 <strlcpy+0x3a>
  8009e1:	8a 0b                	mov    (%ebx),%cl
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	74 20                	je     800a07 <strlcpy+0x3e>
  8009e7:	89 f8                	mov    %edi,%eax
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009ee:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f1:	88 08                	mov    %cl,(%eax)
  8009f3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f4:	39 f2                	cmp    %esi,%edx
  8009f6:	74 11                	je     800a09 <strlcpy+0x40>
  8009f8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009fc:	42                   	inc    %edx
  8009fd:	84 c9                	test   %cl,%cl
  8009ff:	75 f0                	jne    8009f1 <strlcpy+0x28>
  800a01:	eb 06                	jmp    800a09 <strlcpy+0x40>
  800a03:	89 f8                	mov    %edi,%eax
  800a05:	eb 02                	jmp    800a09 <strlcpy+0x40>
  800a07:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a09:	c6 00 00             	movb   $0x0,(%eax)
  800a0c:	eb 02                	jmp    800a10 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a10:	29 f8                	sub    %edi,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a20:	8a 01                	mov    (%ecx),%al
  800a22:	84 c0                	test   %al,%al
  800a24:	74 10                	je     800a36 <strcmp+0x1f>
  800a26:	3a 02                	cmp    (%edx),%al
  800a28:	75 0c                	jne    800a36 <strcmp+0x1f>
		p++, q++;
  800a2a:	41                   	inc    %ecx
  800a2b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2c:	8a 01                	mov    (%ecx),%al
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strcmp+0x1f>
  800a32:	3a 02                	cmp    (%edx),%al
  800a34:	74 f4                	je     800a2a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 1b                	je     800a6c <strncmp+0x2c>
  800a51:	8a 1a                	mov    (%edx),%bl
  800a53:	84 db                	test   %bl,%bl
  800a55:	74 24                	je     800a7b <strncmp+0x3b>
  800a57:	3a 19                	cmp    (%ecx),%bl
  800a59:	75 20                	jne    800a7b <strncmp+0x3b>
  800a5b:	48                   	dec    %eax
  800a5c:	74 15                	je     800a73 <strncmp+0x33>
		n--, p++, q++;
  800a5e:	42                   	inc    %edx
  800a5f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a60:	8a 1a                	mov    (%edx),%bl
  800a62:	84 db                	test   %bl,%bl
  800a64:	74 15                	je     800a7b <strncmp+0x3b>
  800a66:	3a 19                	cmp    (%ecx),%bl
  800a68:	74 f1                	je     800a5b <strncmp+0x1b>
  800a6a:	eb 0f                	jmp    800a7b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	eb 05                	jmp    800a78 <strncmp+0x38>
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a78:	5b                   	pop    %ebx
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7b:	0f b6 02             	movzbl (%edx),%eax
  800a7e:	0f b6 11             	movzbl (%ecx),%edx
  800a81:	29 d0                	sub    %edx,%eax
  800a83:	eb f3                	jmp    800a78 <strncmp+0x38>

00800a85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a8e:	8a 10                	mov    (%eax),%dl
  800a90:	84 d2                	test   %dl,%dl
  800a92:	74 18                	je     800aac <strchr+0x27>
		if (*s == c)
  800a94:	38 ca                	cmp    %cl,%dl
  800a96:	75 06                	jne    800a9e <strchr+0x19>
  800a98:	eb 17                	jmp    800ab1 <strchr+0x2c>
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	74 13                	je     800ab1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9e:	40                   	inc    %eax
  800a9f:	8a 10                	mov    (%eax),%dl
  800aa1:	84 d2                	test   %dl,%dl
  800aa3:	75 f5                	jne    800a9a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	eb 05                	jmp    800ab1 <strchr+0x2c>
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800abc:	8a 10                	mov    (%eax),%dl
  800abe:	84 d2                	test   %dl,%dl
  800ac0:	74 11                	je     800ad3 <strfind+0x20>
		if (*s == c)
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	75 06                	jne    800acc <strfind+0x19>
  800ac6:	eb 0b                	jmp    800ad3 <strfind+0x20>
  800ac8:	38 ca                	cmp    %cl,%dl
  800aca:	74 07                	je     800ad3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800acc:	40                   	inc    %eax
  800acd:	8a 10                	mov    (%eax),%dl
  800acf:	84 d2                	test   %dl,%dl
  800ad1:	75 f5                	jne    800ac8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    

00800ad5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 30                	je     800b18 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aee:	75 25                	jne    800b15 <memset+0x40>
  800af0:	f6 c1 03             	test   $0x3,%cl
  800af3:	75 20                	jne    800b15 <memset+0x40>
		c &= 0xFF;
  800af5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	c1 e3 08             	shl    $0x8,%ebx
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	c1 e6 18             	shl    $0x18,%esi
  800b02:	89 d0                	mov    %edx,%eax
  800b04:	c1 e0 10             	shl    $0x10,%eax
  800b07:	09 f0                	or     %esi,%eax
  800b09:	09 d0                	or     %edx,%eax
  800b0b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b0d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b10:	fc                   	cld    
  800b11:	f3 ab                	rep stos %eax,%es:(%edi)
  800b13:	eb 03                	jmp    800b18 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b15:	fc                   	cld    
  800b16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b18:	89 f8                	mov    %edi,%eax
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2d:	39 c6                	cmp    %eax,%esi
  800b2f:	73 34                	jae    800b65 <memmove+0x46>
  800b31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 2d                	jae    800b65 <memmove+0x46>
		s += n;
		d += n;
  800b38:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3b:	f6 c2 03             	test   $0x3,%dl
  800b3e:	75 1b                	jne    800b5b <memmove+0x3c>
  800b40:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b46:	75 13                	jne    800b5b <memmove+0x3c>
  800b48:	f6 c1 03             	test   $0x3,%cl
  800b4b:	75 0e                	jne    800b5b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b4d:	83 ef 04             	sub    $0x4,%edi
  800b50:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b53:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b56:	fd                   	std    
  800b57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b59:	eb 07                	jmp    800b62 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b5b:	4f                   	dec    %edi
  800b5c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5f:	fd                   	std    
  800b60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b62:	fc                   	cld    
  800b63:	eb 20                	jmp    800b85 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6b:	75 13                	jne    800b80 <memmove+0x61>
  800b6d:	a8 03                	test   $0x3,%al
  800b6f:	75 0f                	jne    800b80 <memmove+0x61>
  800b71:	f6 c1 03             	test   $0x3,%cl
  800b74:	75 0a                	jne    800b80 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b76:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b79:	89 c7                	mov    %eax,%edi
  800b7b:	fc                   	cld    
  800b7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7e:	eb 05                	jmp    800b85 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b80:	89 c7                	mov    %eax,%edi
  800b82:	fc                   	cld    
  800b83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b8c:	ff 75 10             	pushl  0x10(%ebp)
  800b8f:	ff 75 0c             	pushl  0xc(%ebp)
  800b92:	ff 75 08             	pushl  0x8(%ebp)
  800b95:	e8 85 ff ff ff       	call   800b1f <memmove>
}
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bab:	85 ff                	test   %edi,%edi
  800bad:	74 32                	je     800be1 <memcmp+0x45>
		if (*s1 != *s2)
  800baf:	8a 03                	mov    (%ebx),%al
  800bb1:	8a 0e                	mov    (%esi),%cl
  800bb3:	38 c8                	cmp    %cl,%al
  800bb5:	74 19                	je     800bd0 <memcmp+0x34>
  800bb7:	eb 0d                	jmp    800bc6 <memcmp+0x2a>
  800bb9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bbd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bc1:	42                   	inc    %edx
  800bc2:	38 c8                	cmp    %cl,%al
  800bc4:	74 10                	je     800bd6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bc6:	0f b6 c0             	movzbl %al,%eax
  800bc9:	0f b6 c9             	movzbl %cl,%ecx
  800bcc:	29 c8                	sub    %ecx,%eax
  800bce:	eb 16                	jmp    800be6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd0:	4f                   	dec    %edi
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	39 fa                	cmp    %edi,%edx
  800bd8:	75 df                	jne    800bb9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	eb 05                	jmp    800be6 <memcmp+0x4a>
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf1:	89 c2                	mov    %eax,%edx
  800bf3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf6:	39 d0                	cmp    %edx,%eax
  800bf8:	73 12                	jae    800c0c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bfd:	38 08                	cmp    %cl,(%eax)
  800bff:	75 06                	jne    800c07 <memfind+0x1c>
  800c01:	eb 09                	jmp    800c0c <memfind+0x21>
  800c03:	38 08                	cmp    %cl,(%eax)
  800c05:	74 05                	je     800c0c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c07:	40                   	inc    %eax
  800c08:	39 c2                	cmp    %eax,%edx
  800c0a:	77 f7                	ja     800c03 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	eb 01                	jmp    800c1d <strtol+0xf>
		s++;
  800c1c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1d:	8a 02                	mov    (%edx),%al
  800c1f:	3c 20                	cmp    $0x20,%al
  800c21:	74 f9                	je     800c1c <strtol+0xe>
  800c23:	3c 09                	cmp    $0x9,%al
  800c25:	74 f5                	je     800c1c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c27:	3c 2b                	cmp    $0x2b,%al
  800c29:	75 08                	jne    800c33 <strtol+0x25>
		s++;
  800c2b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	eb 13                	jmp    800c46 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c33:	3c 2d                	cmp    $0x2d,%al
  800c35:	75 0a                	jne    800c41 <strtol+0x33>
		s++, neg = 1;
  800c37:	8d 52 01             	lea    0x1(%edx),%edx
  800c3a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c3f:	eb 05                	jmp    800c46 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c41:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c46:	85 db                	test   %ebx,%ebx
  800c48:	74 05                	je     800c4f <strtol+0x41>
  800c4a:	83 fb 10             	cmp    $0x10,%ebx
  800c4d:	75 28                	jne    800c77 <strtol+0x69>
  800c4f:	8a 02                	mov    (%edx),%al
  800c51:	3c 30                	cmp    $0x30,%al
  800c53:	75 10                	jne    800c65 <strtol+0x57>
  800c55:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c59:	75 0a                	jne    800c65 <strtol+0x57>
		s += 2, base = 16;
  800c5b:	83 c2 02             	add    $0x2,%edx
  800c5e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c63:	eb 12                	jmp    800c77 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c65:	85 db                	test   %ebx,%ebx
  800c67:	75 0e                	jne    800c77 <strtol+0x69>
  800c69:	3c 30                	cmp    $0x30,%al
  800c6b:	75 05                	jne    800c72 <strtol+0x64>
		s++, base = 8;
  800c6d:	42                   	inc    %edx
  800c6e:	b3 08                	mov    $0x8,%bl
  800c70:	eb 05                	jmp    800c77 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7e:	8a 0a                	mov    (%edx),%cl
  800c80:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c83:	80 fb 09             	cmp    $0x9,%bl
  800c86:	77 08                	ja     800c90 <strtol+0x82>
			dig = *s - '0';
  800c88:	0f be c9             	movsbl %cl,%ecx
  800c8b:	83 e9 30             	sub    $0x30,%ecx
  800c8e:	eb 1e                	jmp    800cae <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c90:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c93:	80 fb 19             	cmp    $0x19,%bl
  800c96:	77 08                	ja     800ca0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c98:	0f be c9             	movsbl %cl,%ecx
  800c9b:	83 e9 57             	sub    $0x57,%ecx
  800c9e:	eb 0e                	jmp    800cae <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ca0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 13                	ja     800cbb <strtol+0xad>
			dig = *s - 'A' + 10;
  800ca8:	0f be c9             	movsbl %cl,%ecx
  800cab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cae:	39 f1                	cmp    %esi,%ecx
  800cb0:	7d 0d                	jge    800cbf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cb2:	42                   	inc    %edx
  800cb3:	0f af c6             	imul   %esi,%eax
  800cb6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cb9:	eb c3                	jmp    800c7e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cbb:	89 c1                	mov    %eax,%ecx
  800cbd:	eb 02                	jmp    800cc1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cbf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc5:	74 05                	je     800ccc <strtol+0xbe>
		*endptr = (char *) s;
  800cc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cca:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ccc:	85 ff                	test   %edi,%edi
  800cce:	74 04                	je     800cd4 <strtol+0xc6>
  800cd0:	89 c8                	mov    %ecx,%eax
  800cd2:	f7 d8                	neg    %eax
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    
  800cd9:	00 00                	add    %al,(%eax)
	...

00800cdc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	83 ec 10             	sub    $0x10,%esp
  800ce4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cea:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cf0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cf3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	75 2e                	jne    800d28 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cfa:	39 f1                	cmp    %esi,%ecx
  800cfc:	77 5a                	ja     800d58 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cfe:	85 c9                	test   %ecx,%ecx
  800d00:	75 0b                	jne    800d0d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d02:	b8 01 00 00 00       	mov    $0x1,%eax
  800d07:	31 d2                	xor    %edx,%edx
  800d09:	f7 f1                	div    %ecx
  800d0b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	89 f0                	mov    %esi,%eax
  800d11:	f7 f1                	div    %ecx
  800d13:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	f7 f1                	div    %ecx
  800d19:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    
  800d26:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	77 1c                	ja     800d48 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d2c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d2f:	83 f7 1f             	xor    $0x1f,%edi
  800d32:	75 3c                	jne    800d70 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d34:	39 f0                	cmp    %esi,%eax
  800d36:	0f 82 90 00 00 00    	jb     800dcc <__udivdi3+0xf0>
  800d3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d3f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d42:	0f 86 84 00 00 00    	jbe    800dcc <__udivdi3+0xf0>
  800d48:	31 f6                	xor    %esi,%esi
  800d4a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d4c:	89 f8                	mov    %edi,%eax
  800d4e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    
  800d57:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	89 f8                	mov    %edi,%eax
  800d5c:	f7 f1                	div    %ecx
  800d5e:	89 c7                	mov    %eax,%edi
  800d60:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d62:	89 f8                	mov    %edi,%eax
  800d64:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d70:	89 f9                	mov    %edi,%ecx
  800d72:	d3 e0                	shl    %cl,%eax
  800d74:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d77:	b8 20 00 00 00       	mov    $0x20,%eax
  800d7c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d81:	88 c1                	mov    %al,%cl
  800d83:	d3 ea                	shr    %cl,%edx
  800d85:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d88:	09 ca                	or     %ecx,%edx
  800d8a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	d3 e2                	shl    %cl,%edx
  800d94:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d97:	89 f2                	mov    %esi,%edx
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800da0:	89 f2                	mov    %esi,%edx
  800da2:	89 f9                	mov    %edi,%ecx
  800da4:	d3 e2                	shl    %cl,%edx
  800da6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800da9:	88 c1                	mov    %al,%cl
  800dab:	d3 ee                	shr    %cl,%esi
  800dad:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800daf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	89 ca                	mov    %ecx,%edx
  800db6:	f7 75 ec             	divl   -0x14(%ebp)
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dbd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc0:	39 d1                	cmp    %edx,%ecx
  800dc2:	72 28                	jb     800dec <__udivdi3+0x110>
  800dc4:	74 1a                	je     800de0 <__udivdi3+0x104>
  800dc6:	89 f7                	mov    %esi,%edi
  800dc8:	31 f6                	xor    %esi,%esi
  800dca:	eb 80                	jmp    800d4c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dcc:	31 f6                	xor    %esi,%esi
  800dce:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd3:	89 f8                	mov    %edi,%eax
  800dd5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800de0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de3:	89 f9                	mov    %edi,%ecx
  800de5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de7:	39 c2                	cmp    %eax,%edx
  800de9:	73 db                	jae    800dc6 <__udivdi3+0xea>
  800deb:	90                   	nop
		{
		  q0--;
  800dec:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800def:	31 f6                	xor    %esi,%esi
  800df1:	e9 56 ff ff ff       	jmp    800d4c <__udivdi3+0x70>
	...

00800df8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	83 ec 20             	sub    $0x20,%esp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e06:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e09:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e0c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e15:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e17:	85 ff                	test   %edi,%edi
  800e19:	75 15                	jne    800e30 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	0f 86 99 00 00 00    	jbe    800ebc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e23:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e25:	89 d0                	mov    %edx,%eax
  800e27:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e29:	83 c4 20             	add    $0x20,%esp
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e30:	39 f7                	cmp    %esi,%edi
  800e32:	0f 87 a4 00 00 00    	ja     800edc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e38:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e3b:	83 f0 1f             	xor    $0x1f,%eax
  800e3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e41:	0f 84 a1 00 00 00    	je     800ee8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e47:	89 f8                	mov    %edi,%eax
  800e49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e4c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e53:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e59:	89 f9                	mov    %edi,%ecx
  800e5b:	d3 ea                	shr    %cl,%edx
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e65:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e68:	d3 e0                	shl    %cl,%eax
  800e6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e6d:	89 f2                	mov    %esi,%edx
  800e6f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e74:	d3 e0                	shl    %cl,%eax
  800e76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e7c:	89 f9                	mov    %edi,%ecx
  800e7e:	d3 e8                	shr    %cl,%eax
  800e80:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e82:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e84:	89 f2                	mov    %esi,%edx
  800e86:	f7 75 f0             	divl   -0x10(%ebp)
  800e89:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e8b:	f7 65 f4             	mull   -0xc(%ebp)
  800e8e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e91:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	72 71                	jb     800f08 <__umoddi3+0x110>
  800e97:	74 7f                	je     800f18 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9c:	29 c8                	sub    %ecx,%eax
  800e9e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ea3:	d3 e8                	shr    %cl,%eax
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	89 f9                	mov    %edi,%ecx
  800ea9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eab:	09 d0                	or     %edx,%eax
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eb2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ebc:	85 c9                	test   %ecx,%ecx
  800ebe:	75 0b                	jne    800ecb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 f1                	div    %ecx
  800ec9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed4:	f7 f1                	div    %ecx
  800ed6:	e9 4a ff ff ff       	jmp    800e25 <__umoddi3+0x2d>
  800edb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800edc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ede:	83 c4 20             	add    $0x20,%esp
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee8:	39 f7                	cmp    %esi,%edi
  800eea:	72 05                	jb     800ef1 <__umoddi3+0xf9>
  800eec:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800eef:	77 0c                	ja     800efd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef1:	89 f2                	mov    %esi,%edx
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	29 c8                	sub    %ecx,%eax
  800ef8:	19 fa                	sbb    %edi,%edx
  800efa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    
  800f07:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f08:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f0b:	89 c1                	mov    %eax,%ecx
  800f0d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f10:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f13:	eb 84                	jmp    800e99 <__umoddi3+0xa1>
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f1b:	72 eb                	jb     800f08 <__umoddi3+0x110>
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	e9 75 ff ff ff       	jmp    800e99 <__umoddi3+0xa1>
