
obj/user/buggyhello:     file format elf32-i386


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
  80003e:	e8 ae 00 00 00       	call   8000f1 <sys_cputs>
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
  800053:	e8 05 01 00 00       	call   80015d <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	c1 e0 07             	shl    $0x7,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 f6                	test   %esi,%esi
  80006c:	7e 07                	jle    800075 <libmain+0x2d>
		binaryname = argv[0];
  80006e:	8b 03                	mov    (%ebx),%eax
  800070:	a3 00 20 80 00       	mov    %eax,0x802000
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
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 9e 00 00 00       	call   80013b <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 1c             	sub    $0x1c,%esp
  8000ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c1:	cd 30                	int    $0x30
  8000c3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c9:	74 1c                	je     8000e7 <syscall+0x43>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7e 18                	jle    8000e7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	50                   	push   %eax
  8000d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000d6:	68 2a 0f 80 00       	push   $0x800f2a
  8000db:	6a 42                	push   $0x42
  8000dd:	68 47 0f 80 00       	push   $0x800f47
  8000e2:	e8 e1 01 00 00       	call   8002c8 <_panic>

	return ret;
}
  8000e7:	89 d0                	mov    %edx,%eax
  8000e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f7:	6a 00                	push   $0x0
  8000f9:	6a 00                	push   $0x0
  8000fb:	6a 00                	push   $0x0
  8000fd:	ff 75 0c             	pushl  0xc(%ebp)
  800100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800103:	ba 00 00 00 00       	mov    $0x0,%edx
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 92 ff ff ff       	call   8000a4 <syscall>
  800112:	83 c4 10             	add    $0x10,%esp
	return;
}
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <sys_cgetc>:

int
sys_cgetc(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 01 00 00 00       	mov    $0x1,%eax
  800134:	e8 6b ff ff ff       	call   8000a4 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014c:	ba 01 00 00 00       	mov    $0x1,%edx
  800151:	b8 03 00 00 00       	mov    $0x3,%eax
  800156:	e8 49 ff ff ff       	call   8000a4 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 02 00 00 00       	mov    $0x2,%eax
  80017a:	e8 25 ff ff ff       	call   8000a4 <syscall>
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <sys_yield>:

void
sys_yield(void)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019e:	e8 01 ff ff ff       	call   8000a4 <syscall>
  8001a3:	83 c4 10             	add    $0x10,%esp
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001ae:	6a 00                	push   $0x0
  8001b0:	6a 00                	push   $0x0
  8001b2:	ff 75 10             	pushl  0x10(%ebp)
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c5:	e8 da fe ff ff       	call   8000a4 <syscall>
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff 75 14             	pushl  0x14(%ebp)
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	e8 b4 fe ff ff       	call   8000a4 <syscall>
}
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8001f8:	6a 00                	push   $0x0
  8001fa:	6a 00                	push   $0x0
  8001fc:	6a 00                	push   $0x0
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800204:	ba 01 00 00 00       	mov    $0x1,%edx
  800209:	b8 06 00 00 00       	mov    $0x6,%eax
  80020e:	e8 91 fe ff ff       	call   8000a4 <syscall>
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80021b:	6a 00                	push   $0x0
  80021d:	6a 00                	push   $0x0
  80021f:	6a 00                	push   $0x0
  800221:	ff 75 0c             	pushl  0xc(%ebp)
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	ba 01 00 00 00       	mov    $0x1,%edx
  80022c:	b8 08 00 00 00       	mov    $0x8,%eax
  800231:	e8 6e fe ff ff       	call   8000a4 <syscall>
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80023e:	6a 00                	push   $0x0
  800240:	6a 00                	push   $0x0
  800242:	6a 00                	push   $0x0
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024a:	ba 01 00 00 00       	mov    $0x1,%edx
  80024f:	b8 09 00 00 00       	mov    $0x9,%eax
  800254:	e8 4b fe ff ff       	call   8000a4 <syscall>
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800261:	6a 00                	push   $0x0
  800263:	ff 75 14             	pushl  0x14(%ebp)
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	ff 75 0c             	pushl  0xc(%ebp)
  80026c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026f:	ba 00 00 00 00       	mov    $0x0,%edx
  800274:	b8 0b 00 00 00       	mov    $0xb,%eax
  800279:	e8 26 fe ff ff       	call   8000a4 <syscall>
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800286:	6a 00                	push   $0x0
  800288:	6a 00                	push   $0x0
  80028a:	6a 00                	push   $0x0
  80028c:	6a 00                	push   $0x0
  80028e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800291:	ba 01 00 00 00       	mov    $0x1,%edx
  800296:	b8 0c 00 00 00       	mov    $0xc,%eax
  80029b:	e8 04 fe ff ff       	call   8000a4 <syscall>
}
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  8002a8:	6a 00                	push   $0x0
  8002aa:	6a 00                	push   $0x0
  8002ac:	6a 00                	push   $0x0
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002be:	e8 e1 fd ff ff       	call   8000a4 <syscall>
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002cd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002d6:	e8 82 fe ff ff       	call   80015d <sys_getenvid>
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	53                   	push   %ebx
  8002e5:	50                   	push   %eax
  8002e6:	68 58 0f 80 00       	push   $0x800f58
  8002eb:	e8 b0 00 00 00       	call   8003a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f0:	83 c4 18             	add    $0x18,%esp
  8002f3:	56                   	push   %esi
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	e8 53 00 00 00       	call   80034f <vcprintf>
	cprintf("\n");
  8002fc:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  800303:	e8 98 00 00 00       	call   8003a0 <cprintf>
  800308:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030b:	cc                   	int3   
  80030c:	eb fd                	jmp    80030b <_panic+0x43>
	...

00800310 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	53                   	push   %ebx
  800314:	83 ec 04             	sub    $0x4,%esp
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031a:	8b 03                	mov    (%ebx),%eax
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800323:	40                   	inc    %eax
  800324:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800326:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032b:	75 1a                	jne    800347 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	68 ff 00 00 00       	push   $0xff
  800335:	8d 43 08             	lea    0x8(%ebx),%eax
  800338:	50                   	push   %eax
  800339:	e8 b3 fd ff ff       	call   8000f1 <sys_cputs>
		b->idx = 0;
  80033e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800344:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800347:	ff 43 04             	incl   0x4(%ebx)
}
  80034a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    

0080034f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800358:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035f:	00 00 00 
	b.cnt = 0;
  800362:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800369:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036c:	ff 75 0c             	pushl  0xc(%ebp)
  80036f:	ff 75 08             	pushl  0x8(%ebp)
  800372:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800378:	50                   	push   %eax
  800379:	68 10 03 80 00       	push   $0x800310
  80037e:	e8 82 01 00 00       	call   800505 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80038c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800392:	50                   	push   %eax
  800393:	e8 59 fd ff ff       	call   8000f1 <sys_cputs>

	return b.cnt;
}
  800398:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a9:	50                   	push   %eax
  8003aa:	ff 75 08             	pushl  0x8(%ebp)
  8003ad:	e8 9d ff ff ff       	call   80034f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 2c             	sub    $0x2c,%esp
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	89 d6                	mov    %edx,%esi
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003da:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003e1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003e4:	72 0c                	jb     8003f2 <printnum+0x3e>
  8003e6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003e9:	76 07                	jbe    8003f2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003eb:	4b                   	dec    %ebx
  8003ec:	85 db                	test   %ebx,%ebx
  8003ee:	7f 31                	jg     800421 <printnum+0x6d>
  8003f0:	eb 3f                	jmp    800431 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f2:	83 ec 0c             	sub    $0xc,%esp
  8003f5:	57                   	push   %edi
  8003f6:	4b                   	dec    %ebx
  8003f7:	53                   	push   %ebx
  8003f8:	50                   	push   %eax
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 c7 08 00 00       	call   800cd4 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800417:	e8 98 ff ff ff       	call   8003b4 <printnum>
  80041c:	83 c4 20             	add    $0x20,%esp
  80041f:	eb 10                	jmp    800431 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	56                   	push   %esi
  800425:	57                   	push   %edi
  800426:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800429:	4b                   	dec    %ebx
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	85 db                	test   %ebx,%ebx
  80042f:	7f f0                	jg     800421 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	56                   	push   %esi
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	ff 75 d4             	pushl  -0x2c(%ebp)
  80043b:	ff 75 d0             	pushl  -0x30(%ebp)
  80043e:	ff 75 dc             	pushl  -0x24(%ebp)
  800441:	ff 75 d8             	pushl  -0x28(%ebp)
  800444:	e8 a7 09 00 00       	call   800df0 <__umoddi3>
  800449:	83 c4 14             	add    $0x14,%esp
  80044c:	0f be 80 7e 0f 80 00 	movsbl 0x800f7e(%eax),%eax
  800453:	50                   	push   %eax
  800454:	ff 55 e4             	call   *-0x1c(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
}
  80045a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80045d:	5b                   	pop    %ebx
  80045e:	5e                   	pop    %esi
  80045f:	5f                   	pop    %edi
  800460:	c9                   	leave  
  800461:	c3                   	ret    

00800462 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800465:	83 fa 01             	cmp    $0x1,%edx
  800468:	7e 0e                	jle    800478 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	8b 52 04             	mov    0x4(%edx),%edx
  800476:	eb 22                	jmp    80049a <getuint+0x38>
	else if (lflag)
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 10                	je     80048c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047c:	8b 10                	mov    (%eax),%edx
  80047e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800481:	89 08                	mov    %ecx,(%eax)
  800483:	8b 02                	mov    (%edx),%eax
  800485:	ba 00 00 00 00       	mov    $0x0,%edx
  80048a:	eb 0e                	jmp    80049a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800491:	89 08                	mov    %ecx,(%eax)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049a:	c9                   	leave  
  80049b:	c3                   	ret    

0080049c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049f:	83 fa 01             	cmp    $0x1,%edx
  8004a2:	7e 0e                	jle    8004b2 <getint+0x16>
		return va_arg(*ap, long long);
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a9:	89 08                	mov    %ecx,(%eax)
  8004ab:	8b 02                	mov    (%edx),%eax
  8004ad:	8b 52 04             	mov    0x4(%edx),%edx
  8004b0:	eb 1a                	jmp    8004cc <getint+0x30>
	else if (lflag)
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	74 0c                	je     8004c2 <getint+0x26>
		return va_arg(*ap, long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	99                   	cltd   
  8004c0:	eb 0a                	jmp    8004cc <getint+0x30>
	else
		return va_arg(*ap, int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	99                   	cltd   
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    

008004ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dc:	73 08                	jae    8004e6 <sprintputch+0x18>
		*b->buf++ = ch;
  8004de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e1:	88 0a                	mov    %cl,(%edx)
  8004e3:	42                   	inc    %edx
  8004e4:	89 10                	mov    %edx,(%eax)
}
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f1:	50                   	push   %eax
  8004f2:	ff 75 10             	pushl  0x10(%ebp)
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	ff 75 08             	pushl  0x8(%ebp)
  8004fb:	e8 05 00 00 00       	call   800505 <vprintfmt>
	va_end(ap);
  800500:	83 c4 10             	add    $0x10,%esp
}
  800503:	c9                   	leave  
  800504:	c3                   	ret    

00800505 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	53                   	push   %ebx
  80050b:	83 ec 2c             	sub    $0x2c,%esp
  80050e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800511:	8b 75 10             	mov    0x10(%ebp),%esi
  800514:	eb 13                	jmp    800529 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800516:	85 c0                	test   %eax,%eax
  800518:	0f 84 6d 03 00 00    	je     80088b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	57                   	push   %edi
  800522:	50                   	push   %eax
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800529:	0f b6 06             	movzbl (%esi),%eax
  80052c:	46                   	inc    %esi
  80052d:	83 f8 25             	cmp    $0x25,%eax
  800530:	75 e4                	jne    800516 <vprintfmt+0x11>
  800532:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800536:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80053d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800544:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800550:	eb 28                	jmp    80057a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800554:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800558:	eb 20                	jmp    80057a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80055c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800560:	eb 18                	jmp    80057a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800564:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80056b:	eb 0d                	jmp    80057a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80056d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800573:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8a 06                	mov    (%esi),%al
  80057c:	0f b6 d0             	movzbl %al,%edx
  80057f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800582:	83 e8 23             	sub    $0x23,%eax
  800585:	3c 55                	cmp    $0x55,%al
  800587:	0f 87 e0 02 00 00    	ja     80086d <vprintfmt+0x368>
  80058d:	0f b6 c0             	movzbl %al,%eax
  800590:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800597:	83 ea 30             	sub    $0x30,%edx
  80059a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80059d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005a0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a3:	83 fa 09             	cmp    $0x9,%edx
  8005a6:	77 44                	ja     8005ec <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	89 de                	mov    %ebx,%esi
  8005aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005ae:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005b5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005bb:	83 fb 09             	cmp    $0x9,%ebx
  8005be:	76 ed                	jbe    8005ad <vprintfmt+0xa8>
  8005c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c3:	eb 29                	jmp    8005ee <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d5:	eb 17                	jmp    8005ee <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005db:	78 85                	js     800562 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	89 de                	mov    %ebx,%esi
  8005df:	eb 99                	jmp    80057a <vprintfmt+0x75>
  8005e1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ea:	eb 8e                	jmp    80057a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f2:	79 86                	jns    80057a <vprintfmt+0x75>
  8005f4:	e9 74 ff ff ff       	jmp    80056d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	89 de                	mov    %ebx,%esi
  8005fc:	e9 79 ff ff ff       	jmp    80057a <vprintfmt+0x75>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	ff 30                	pushl  (%eax)
  800613:	ff 55 08             	call   *0x8(%ebp)
			break;
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061c:	e9 08 ff ff ff       	jmp    800529 <vprintfmt+0x24>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	85 c0                	test   %eax,%eax
  800631:	79 02                	jns    800635 <vprintfmt+0x130>
  800633:	f7 d8                	neg    %eax
  800635:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800637:	83 f8 08             	cmp    $0x8,%eax
  80063a:	7f 0b                	jg     800647 <vprintfmt+0x142>
  80063c:	8b 04 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%eax
  800643:	85 c0                	test   %eax,%eax
  800645:	75 1a                	jne    800661 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800647:	52                   	push   %edx
  800648:	68 96 0f 80 00       	push   $0x800f96
  80064d:	57                   	push   %edi
  80064e:	ff 75 08             	pushl  0x8(%ebp)
  800651:	e8 92 fe ff ff       	call   8004e8 <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065c:	e9 c8 fe ff ff       	jmp    800529 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800661:	50                   	push   %eax
  800662:	68 9f 0f 80 00       	push   $0x800f9f
  800667:	57                   	push   %edi
  800668:	ff 75 08             	pushl  0x8(%ebp)
  80066b:	e8 78 fe ff ff       	call   8004e8 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800676:	e9 ae fe ff ff       	jmp    800529 <vprintfmt+0x24>
  80067b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80067e:	89 de                	mov    %ebx,%esi
  800680:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800683:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800694:	85 c0                	test   %eax,%eax
  800696:	75 07                	jne    80069f <vprintfmt+0x19a>
				p = "(null)";
  800698:	c7 45 d0 8f 0f 80 00 	movl   $0x800f8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80069f:	85 db                	test   %ebx,%ebx
  8006a1:	7e 42                	jle    8006e5 <vprintfmt+0x1e0>
  8006a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006a7:	74 3c                	je     8006e5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	51                   	push   %ecx
  8006ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b0:	e8 6f 02 00 00       	call   800924 <strnlen>
  8006b5:	29 c3                	sub    %eax,%ebx
  8006b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 db                	test   %ebx,%ebx
  8006bf:	7e 24                	jle    8006e5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006c1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006c5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	57                   	push   %edi
  8006cf:	53                   	push   %ebx
  8006d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	4e                   	dec    %esi
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 f6                	test   %esi,%esi
  8006d9:	7f f0                	jg     8006cb <vprintfmt+0x1c6>
  8006db:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e8:	0f be 02             	movsbl (%edx),%eax
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	75 47                	jne    800736 <vprintfmt+0x231>
  8006ef:	eb 37                	jmp    800728 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f5:	74 16                	je     80070d <vprintfmt+0x208>
  8006f7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006fa:	83 fa 5e             	cmp    $0x5e,%edx
  8006fd:	76 0e                	jbe    80070d <vprintfmt+0x208>
					putch('?', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	57                   	push   %edi
  800703:	6a 3f                	push   $0x3f
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 0b                	jmp    800718 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	57                   	push   %edi
  800711:	50                   	push   %eax
  800712:	ff 55 08             	call   *0x8(%ebp)
  800715:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800718:	ff 4d e4             	decl   -0x1c(%ebp)
  80071b:	0f be 03             	movsbl (%ebx),%eax
  80071e:	85 c0                	test   %eax,%eax
  800720:	74 03                	je     800725 <vprintfmt+0x220>
  800722:	43                   	inc    %ebx
  800723:	eb 1b                	jmp    800740 <vprintfmt+0x23b>
  800725:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800728:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072c:	7f 1e                	jg     80074c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800731:	e9 f3 fd ff ff       	jmp    800529 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800736:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800739:	43                   	inc    %ebx
  80073a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80073d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800740:	85 f6                	test   %esi,%esi
  800742:	78 ad                	js     8006f1 <vprintfmt+0x1ec>
  800744:	4e                   	dec    %esi
  800745:	79 aa                	jns    8006f1 <vprintfmt+0x1ec>
  800747:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80074a:	eb dc                	jmp    800728 <vprintfmt+0x223>
  80074c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	57                   	push   %edi
  800753:	6a 20                	push   $0x20
  800755:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800758:	4b                   	dec    %ebx
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 db                	test   %ebx,%ebx
  80075e:	7f ef                	jg     80074f <vprintfmt+0x24a>
  800760:	e9 c4 fd ff ff       	jmp    800529 <vprintfmt+0x24>
  800765:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800768:	89 ca                	mov    %ecx,%edx
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 2a fd ff ff       	call   80049c <getint>
  800772:	89 c3                	mov    %eax,%ebx
  800774:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800776:	85 d2                	test   %edx,%edx
  800778:	78 0a                	js     800784 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 b0 00 00 00       	jmp    800834 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	57                   	push   %edi
  800788:	6a 2d                	push   $0x2d
  80078a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80078d:	f7 db                	neg    %ebx
  80078f:	83 d6 00             	adc    $0x0,%esi
  800792:	f7 de                	neg    %esi
  800794:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800797:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079c:	e9 93 00 00 00       	jmp    800834 <vprintfmt+0x32f>
  8007a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a4:	89 ca                	mov    %ecx,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 b4 fc ff ff       	call   800462 <getuint>
  8007ae:	89 c3                	mov    %eax,%ebx
  8007b0:	89 d6                	mov    %edx,%esi
			base = 10;
  8007b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b7:	eb 7b                	jmp    800834 <vprintfmt+0x32f>
  8007b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007bc:	89 ca                	mov    %ecx,%edx
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	e8 d6 fc ff ff       	call   80049c <getint>
  8007c6:	89 c3                	mov    %eax,%ebx
  8007c8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	78 07                	js     8007d5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d3:	eb 5f                	jmp    800834 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	57                   	push   %edi
  8007d9:	6a 2d                	push   $0x2d
  8007db:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007de:	f7 db                	neg    %ebx
  8007e0:	83 d6 00             	adc    $0x0,%esi
  8007e3:	f7 de                	neg    %esi
  8007e5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8007ed:	eb 45                	jmp    800834 <vprintfmt+0x32f>
  8007ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	57                   	push   %edi
  8007f6:	6a 30                	push   $0x30
  8007f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	57                   	push   %edi
  8007ff:	6a 78                	push   $0x78
  800801:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8d 50 04             	lea    0x4(%eax),%edx
  80080a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80080d:	8b 18                	mov    (%eax),%ebx
  80080f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800814:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800817:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80081c:	eb 16                	jmp    800834 <vprintfmt+0x32f>
  80081e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800821:	89 ca                	mov    %ecx,%edx
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 37 fc ff ff       	call   800462 <getuint>
  80082b:	89 c3                	mov    %eax,%ebx
  80082d:	89 d6                	mov    %edx,%esi
			base = 16;
  80082f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800834:	83 ec 0c             	sub    $0xc,%esp
  800837:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80083b:	52                   	push   %edx
  80083c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80083f:	50                   	push   %eax
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	89 fa                	mov    %edi,%edx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	e8 68 fb ff ff       	call   8003b4 <printnum>
			break;
  80084c:	83 c4 20             	add    $0x20,%esp
  80084f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800852:	e9 d2 fc ff ff       	jmp    800529 <vprintfmt+0x24>
  800857:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	57                   	push   %edi
  80085e:	52                   	push   %edx
  80085f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800862:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800865:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800868:	e9 bc fc ff ff       	jmp    800529 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	57                   	push   %edi
  800871:	6a 25                	push   $0x25
  800873:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	eb 02                	jmp    80087d <vprintfmt+0x378>
  80087b:	89 c6                	mov    %eax,%esi
  80087d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800880:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800884:	75 f5                	jne    80087b <vprintfmt+0x376>
  800886:	e9 9e fc ff ff       	jmp    800529 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80088b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5f                   	pop    %edi
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	83 ec 18             	sub    $0x18,%esp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	74 26                	je     8008da <vsnprintf+0x47>
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	7e 29                	jle    8008e1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b8:	ff 75 14             	pushl  0x14(%ebp)
  8008bb:	ff 75 10             	pushl  0x10(%ebp)
  8008be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	68 ce 04 80 00       	push   $0x8004ce
  8008c7:	e8 39 fc ff ff       	call   800505 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	eb 0c                	jmp    8008e6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008df:	eb 05                	jmp    8008e6 <vsnprintf+0x53>
  8008e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f1:	50                   	push   %eax
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 93 ff ff ff       	call   800893 <vsnprintf>
	va_end(ap);

	return rc;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    
	...

00800904 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090a:	80 3a 00             	cmpb   $0x0,(%edx)
  80090d:	74 0e                	je     80091d <strlen+0x19>
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800914:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800919:	75 f9                	jne    800914 <strlen+0x10>
  80091b:	eb 05                	jmp    800922 <strlen+0x1e>
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092d:	85 d2                	test   %edx,%edx
  80092f:	74 17                	je     800948 <strnlen+0x24>
  800931:	80 39 00             	cmpb   $0x0,(%ecx)
  800934:	74 19                	je     80094f <strnlen+0x2b>
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80093b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093c:	39 d0                	cmp    %edx,%eax
  80093e:	74 14                	je     800954 <strnlen+0x30>
  800940:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800944:	75 f5                	jne    80093b <strnlen+0x17>
  800946:	eb 0c                	jmp    800954 <strnlen+0x30>
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
  80094d:	eb 05                	jmp    800954 <strnlen+0x30>
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800968:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80096b:	42                   	inc    %edx
  80096c:	84 c9                	test   %cl,%cl
  80096e:	75 f5                	jne    800965 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800970:	5b                   	pop    %ebx
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097a:	53                   	push   %ebx
  80097b:	e8 84 ff ff ff       	call   800904 <strlen>
  800980:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800989:	50                   	push   %eax
  80098a:	e8 c7 ff ff ff       	call   800956 <strcpy>
	return dst;
}
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	85 f6                	test   %esi,%esi
  8009a6:	74 15                	je     8009bd <strncpy+0x27>
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ad:	8a 1a                	mov    (%edx),%bl
  8009af:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b2:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b8:	41                   	inc    %ecx
  8009b9:	39 ce                	cmp    %ecx,%esi
  8009bb:	77 f0                	ja     8009ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009cd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d0:	85 f6                	test   %esi,%esi
  8009d2:	74 32                	je     800a06 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009d4:	83 fe 01             	cmp    $0x1,%esi
  8009d7:	74 22                	je     8009fb <strlcpy+0x3a>
  8009d9:	8a 0b                	mov    (%ebx),%cl
  8009db:	84 c9                	test   %cl,%cl
  8009dd:	74 20                	je     8009ff <strlcpy+0x3e>
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009e6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e9:	88 08                	mov    %cl,(%eax)
  8009eb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ec:	39 f2                	cmp    %esi,%edx
  8009ee:	74 11                	je     800a01 <strlcpy+0x40>
  8009f0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009f4:	42                   	inc    %edx
  8009f5:	84 c9                	test   %cl,%cl
  8009f7:	75 f0                	jne    8009e9 <strlcpy+0x28>
  8009f9:	eb 06                	jmp    800a01 <strlcpy+0x40>
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	eb 02                	jmp    800a01 <strlcpy+0x40>
  8009ff:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a01:	c6 00 00             	movb   $0x0,(%eax)
  800a04:	eb 02                	jmp    800a08 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a06:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a08:	29 f8                	sub    %edi,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a18:	8a 01                	mov    (%ecx),%al
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 10                	je     800a2e <strcmp+0x1f>
  800a1e:	3a 02                	cmp    (%edx),%al
  800a20:	75 0c                	jne    800a2e <strcmp+0x1f>
		p++, q++;
  800a22:	41                   	inc    %ecx
  800a23:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a24:	8a 01                	mov    (%ecx),%al
  800a26:	84 c0                	test   %al,%al
  800a28:	74 04                	je     800a2e <strcmp+0x1f>
  800a2a:	3a 02                	cmp    (%edx),%al
  800a2c:	74 f4                	je     800a22 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2e:	0f b6 c0             	movzbl %al,%eax
  800a31:	0f b6 12             	movzbl (%edx),%edx
  800a34:	29 d0                	sub    %edx,%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	74 1b                	je     800a64 <strncmp+0x2c>
  800a49:	8a 1a                	mov    (%edx),%bl
  800a4b:	84 db                	test   %bl,%bl
  800a4d:	74 24                	je     800a73 <strncmp+0x3b>
  800a4f:	3a 19                	cmp    (%ecx),%bl
  800a51:	75 20                	jne    800a73 <strncmp+0x3b>
  800a53:	48                   	dec    %eax
  800a54:	74 15                	je     800a6b <strncmp+0x33>
		n--, p++, q++;
  800a56:	42                   	inc    %edx
  800a57:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a58:	8a 1a                	mov    (%edx),%bl
  800a5a:	84 db                	test   %bl,%bl
  800a5c:	74 15                	je     800a73 <strncmp+0x3b>
  800a5e:	3a 19                	cmp    (%ecx),%bl
  800a60:	74 f1                	je     800a53 <strncmp+0x1b>
  800a62:	eb 0f                	jmp    800a73 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
  800a69:	eb 05                	jmp    800a70 <strncmp+0x38>
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a70:	5b                   	pop    %ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a73:	0f b6 02             	movzbl (%edx),%eax
  800a76:	0f b6 11             	movzbl (%ecx),%edx
  800a79:	29 d0                	sub    %edx,%eax
  800a7b:	eb f3                	jmp    800a70 <strncmp+0x38>

00800a7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a86:	8a 10                	mov    (%eax),%dl
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	74 18                	je     800aa4 <strchr+0x27>
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	75 06                	jne    800a96 <strchr+0x19>
  800a90:	eb 17                	jmp    800aa9 <strchr+0x2c>
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	74 13                	je     800aa9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a96:	40                   	inc    %eax
  800a97:	8a 10                	mov    (%eax),%dl
  800a99:	84 d2                	test   %dl,%dl
  800a9b:	75 f5                	jne    800a92 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	eb 05                	jmp    800aa9 <strchr+0x2c>
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ab4:	8a 10                	mov    (%eax),%dl
  800ab6:	84 d2                	test   %dl,%dl
  800ab8:	74 11                	je     800acb <strfind+0x20>
		if (*s == c)
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	75 06                	jne    800ac4 <strfind+0x19>
  800abe:	eb 0b                	jmp    800acb <strfind+0x20>
  800ac0:	38 ca                	cmp    %cl,%dl
  800ac2:	74 07                	je     800acb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac4:	40                   	inc    %eax
  800ac5:	8a 10                	mov    (%eax),%dl
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	75 f5                	jne    800ac0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 30                	je     800b10 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae6:	75 25                	jne    800b0d <memset+0x40>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 20                	jne    800b0d <memset+0x40>
		c &= 0xFF;
  800aed:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	c1 e3 08             	shl    $0x8,%ebx
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	c1 e6 18             	shl    $0x18,%esi
  800afa:	89 d0                	mov    %edx,%eax
  800afc:	c1 e0 10             	shl    $0x10,%eax
  800aff:	09 f0                	or     %esi,%eax
  800b01:	09 d0                	or     %edx,%eax
  800b03:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b05:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b08:	fc                   	cld    
  800b09:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0b:	eb 03                	jmp    800b10 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b0d:	fc                   	cld    
  800b0e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b10:	89 f8                	mov    %edi,%eax
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b25:	39 c6                	cmp    %eax,%esi
  800b27:	73 34                	jae    800b5d <memmove+0x46>
  800b29:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2c:	39 d0                	cmp    %edx,%eax
  800b2e:	73 2d                	jae    800b5d <memmove+0x46>
		s += n;
		d += n;
  800b30:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b33:	f6 c2 03             	test   $0x3,%dl
  800b36:	75 1b                	jne    800b53 <memmove+0x3c>
  800b38:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3e:	75 13                	jne    800b53 <memmove+0x3c>
  800b40:	f6 c1 03             	test   $0x3,%cl
  800b43:	75 0e                	jne    800b53 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b45:	83 ef 04             	sub    $0x4,%edi
  800b48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4e:	fd                   	std    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b51:	eb 07                	jmp    800b5a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b53:	4f                   	dec    %edi
  800b54:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b57:	fd                   	std    
  800b58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5a:	fc                   	cld    
  800b5b:	eb 20                	jmp    800b7d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b63:	75 13                	jne    800b78 <memmove+0x61>
  800b65:	a8 03                	test   $0x3,%al
  800b67:	75 0f                	jne    800b78 <memmove+0x61>
  800b69:	f6 c1 03             	test   $0x3,%cl
  800b6c:	75 0a                	jne    800b78 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b6e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b71:	89 c7                	mov    %eax,%edi
  800b73:	fc                   	cld    
  800b74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b76:	eb 05                	jmp    800b7d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b78:	89 c7                	mov    %eax,%edi
  800b7a:	fc                   	cld    
  800b7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b84:	ff 75 10             	pushl  0x10(%ebp)
  800b87:	ff 75 0c             	pushl  0xc(%ebp)
  800b8a:	ff 75 08             	pushl  0x8(%ebp)
  800b8d:	e8 85 ff ff ff       	call   800b17 <memmove>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba3:	85 ff                	test   %edi,%edi
  800ba5:	74 32                	je     800bd9 <memcmp+0x45>
		if (*s1 != *s2)
  800ba7:	8a 03                	mov    (%ebx),%al
  800ba9:	8a 0e                	mov    (%esi),%cl
  800bab:	38 c8                	cmp    %cl,%al
  800bad:	74 19                	je     800bc8 <memcmp+0x34>
  800baf:	eb 0d                	jmp    800bbe <memcmp+0x2a>
  800bb1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800bb5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800bb9:	42                   	inc    %edx
  800bba:	38 c8                	cmp    %cl,%al
  800bbc:	74 10                	je     800bce <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800bbe:	0f b6 c0             	movzbl %al,%eax
  800bc1:	0f b6 c9             	movzbl %cl,%ecx
  800bc4:	29 c8                	sub    %ecx,%eax
  800bc6:	eb 16                	jmp    800bde <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc8:	4f                   	dec    %edi
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	39 fa                	cmp    %edi,%edx
  800bd0:	75 df                	jne    800bb1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	eb 05                	jmp    800bde <memcmp+0x4a>
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bee:	39 d0                	cmp    %edx,%eax
  800bf0:	73 12                	jae    800c04 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bf5:	38 08                	cmp    %cl,(%eax)
  800bf7:	75 06                	jne    800bff <memfind+0x1c>
  800bf9:	eb 09                	jmp    800c04 <memfind+0x21>
  800bfb:	38 08                	cmp    %cl,(%eax)
  800bfd:	74 05                	je     800c04 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bff:	40                   	inc    %eax
  800c00:	39 c2                	cmp    %eax,%edx
  800c02:	77 f7                	ja     800bfb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c12:	eb 01                	jmp    800c15 <strtol+0xf>
		s++;
  800c14:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c15:	8a 02                	mov    (%edx),%al
  800c17:	3c 20                	cmp    $0x20,%al
  800c19:	74 f9                	je     800c14 <strtol+0xe>
  800c1b:	3c 09                	cmp    $0x9,%al
  800c1d:	74 f5                	je     800c14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1f:	3c 2b                	cmp    $0x2b,%al
  800c21:	75 08                	jne    800c2b <strtol+0x25>
		s++;
  800c23:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c24:	bf 00 00 00 00       	mov    $0x0,%edi
  800c29:	eb 13                	jmp    800c3e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2b:	3c 2d                	cmp    $0x2d,%al
  800c2d:	75 0a                	jne    800c39 <strtol+0x33>
		s++, neg = 1;
  800c2f:	8d 52 01             	lea    0x1(%edx),%edx
  800c32:	bf 01 00 00 00       	mov    $0x1,%edi
  800c37:	eb 05                	jmp    800c3e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3e:	85 db                	test   %ebx,%ebx
  800c40:	74 05                	je     800c47 <strtol+0x41>
  800c42:	83 fb 10             	cmp    $0x10,%ebx
  800c45:	75 28                	jne    800c6f <strtol+0x69>
  800c47:	8a 02                	mov    (%edx),%al
  800c49:	3c 30                	cmp    $0x30,%al
  800c4b:	75 10                	jne    800c5d <strtol+0x57>
  800c4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c51:	75 0a                	jne    800c5d <strtol+0x57>
		s += 2, base = 16;
  800c53:	83 c2 02             	add    $0x2,%edx
  800c56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5b:	eb 12                	jmp    800c6f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c5d:	85 db                	test   %ebx,%ebx
  800c5f:	75 0e                	jne    800c6f <strtol+0x69>
  800c61:	3c 30                	cmp    $0x30,%al
  800c63:	75 05                	jne    800c6a <strtol+0x64>
		s++, base = 8;
  800c65:	42                   	inc    %edx
  800c66:	b3 08                	mov    $0x8,%bl
  800c68:	eb 05                	jmp    800c6f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c76:	8a 0a                	mov    (%edx),%cl
  800c78:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c7b:	80 fb 09             	cmp    $0x9,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x82>
			dig = *s - '0';
  800c80:	0f be c9             	movsbl %cl,%ecx
  800c83:	83 e9 30             	sub    $0x30,%ecx
  800c86:	eb 1e                	jmp    800ca6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c88:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c8b:	80 fb 19             	cmp    $0x19,%bl
  800c8e:	77 08                	ja     800c98 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c90:	0f be c9             	movsbl %cl,%ecx
  800c93:	83 e9 57             	sub    $0x57,%ecx
  800c96:	eb 0e                	jmp    800ca6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c98:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c9b:	80 fb 19             	cmp    $0x19,%bl
  800c9e:	77 13                	ja     800cb3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ca0:	0f be c9             	movsbl %cl,%ecx
  800ca3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ca6:	39 f1                	cmp    %esi,%ecx
  800ca8:	7d 0d                	jge    800cb7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800caa:	42                   	inc    %edx
  800cab:	0f af c6             	imul   %esi,%eax
  800cae:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cb1:	eb c3                	jmp    800c76 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	eb 02                	jmp    800cb9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cbd:	74 05                	je     800cc4 <strtol+0xbe>
		*endptr = (char *) s;
  800cbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc4:	85 ff                	test   %edi,%edi
  800cc6:	74 04                	je     800ccc <strtol+0xc6>
  800cc8:	89 c8                	mov    %ecx,%eax
  800cca:	f7 d8                	neg    %eax
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    
  800cd1:	00 00                	add    %al,(%eax)
	...

00800cd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	83 ec 10             	sub    $0x10,%esp
  800cdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ceb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	75 2e                	jne    800d20 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cf2:	39 f1                	cmp    %esi,%ecx
  800cf4:	77 5a                	ja     800d50 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf6:	85 c9                	test   %ecx,%ecx
  800cf8:	75 0b                	jne    800d05 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800cff:	31 d2                	xor    %edx,%edx
  800d01:	f7 f1                	div    %ecx
  800d03:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	89 f0                	mov    %esi,%eax
  800d09:	f7 f1                	div    %ecx
  800d0b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0d:	89 f8                	mov    %edi,%eax
  800d0f:	f7 f1                	div    %ecx
  800d11:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d13:	89 f8                	mov    %edi,%eax
  800d15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d17:	83 c4 10             	add    $0x10,%esp
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d20:	39 f0                	cmp    %esi,%eax
  800d22:	77 1c                	ja     800d40 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d24:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	75 3c                	jne    800d68 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d2c:	39 f0                	cmp    %esi,%eax
  800d2e:	0f 82 90 00 00 00    	jb     800dc4 <__udivdi3+0xf0>
  800d34:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d37:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d3a:	0f 86 84 00 00 00    	jbe    800dc4 <__udivdi3+0xf0>
  800d40:	31 f6                	xor    %esi,%esi
  800d42:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    
  800d4f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	f7 f1                	div    %ecx
  800d56:	89 c7                	mov    %eax,%edi
  800d58:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5a:	89 f8                	mov    %edi,%eax
  800d5c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d68:	89 f9                	mov    %edi,%ecx
  800d6a:	d3 e0                	shl    %cl,%eax
  800d6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d6f:	b8 20 00 00 00       	mov    $0x20,%eax
  800d74:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d79:	88 c1                	mov    %al,%cl
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d80:	09 ca                	or     %ecx,%edx
  800d82:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d88:	89 f9                	mov    %edi,%ecx
  800d8a:	d3 e2                	shl    %cl,%edx
  800d8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d8f:	89 f2                	mov    %esi,%edx
  800d91:	88 c1                	mov    %al,%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	89 f9                	mov    %edi,%ecx
  800d9c:	d3 e2                	shl    %cl,%edx
  800d9e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800da1:	88 c1                	mov    %al,%cl
  800da3:	d3 ee                	shr    %cl,%esi
  800da5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800daa:	89 f0                	mov    %esi,%eax
  800dac:	89 ca                	mov    %ecx,%edx
  800dae:	f7 75 ec             	divl   -0x14(%ebp)
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800db5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db8:	39 d1                	cmp    %edx,%ecx
  800dba:	72 28                	jb     800de4 <__udivdi3+0x110>
  800dbc:	74 1a                	je     800dd8 <__udivdi3+0x104>
  800dbe:	89 f7                	mov    %esi,%edi
  800dc0:	31 f6                	xor    %esi,%esi
  800dc2:	eb 80                	jmp    800d44 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc4:	31 f6                	xor    %esi,%esi
  800dc6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dcb:	89 f8                	mov    %edi,%eax
  800dcd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    
  800dd6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ddb:	89 f9                	mov    %edi,%ecx
  800ddd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ddf:	39 c2                	cmp    %eax,%edx
  800de1:	73 db                	jae    800dbe <__udivdi3+0xea>
  800de3:	90                   	nop
		{
		  q0--;
  800de4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de7:	31 f6                	xor    %esi,%esi
  800de9:	e9 56 ff ff ff       	jmp    800d44 <__udivdi3+0x70>
	...

00800df0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	83 ec 20             	sub    $0x20,%esp
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e01:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e04:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e07:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e0d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e0f:	85 ff                	test   %edi,%edi
  800e11:	75 15                	jne    800e28 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e13:	39 f1                	cmp    %esi,%ecx
  800e15:	0f 86 99 00 00 00    	jbe    800eb4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e1d:	89 d0                	mov    %edx,%eax
  800e1f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e28:	39 f7                	cmp    %esi,%edi
  800e2a:	0f 87 a4 00 00 00    	ja     800ed4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e30:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e33:	83 f0 1f             	xor    $0x1f,%eax
  800e36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e39:	0f 84 a1 00 00 00    	je     800ee0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e44:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e46:	bf 20 00 00 00       	mov    $0x20,%edi
  800e4b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	09 c2                	or     %eax,%edx
  800e57:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e60:	d3 e0                	shl    %cl,%eax
  800e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e65:	89 f2                	mov    %esi,%edx
  800e67:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e6c:	d3 e0                	shl    %cl,%eax
  800e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e74:	89 f9                	mov    %edi,%ecx
  800e76:	d3 e8                	shr    %cl,%eax
  800e78:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e7a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e7c:	89 f2                	mov    %esi,%edx
  800e7e:	f7 75 f0             	divl   -0x10(%ebp)
  800e81:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e83:	f7 65 f4             	mull   -0xc(%ebp)
  800e86:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e89:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8b:	39 d6                	cmp    %edx,%esi
  800e8d:	72 71                	jb     800f00 <__umoddi3+0x110>
  800e8f:	74 7f                	je     800f10 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e94:	29 c8                	sub    %ecx,%eax
  800e96:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e98:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e9b:	d3 e8                	shr    %cl,%eax
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	89 f9                	mov    %edi,%ecx
  800ea1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ea3:	09 d0                	or     %edx,%eax
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eaa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb4:	85 c9                	test   %ecx,%ecx
  800eb6:	75 0b                	jne    800ec3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	f7 f1                	div    %ecx
  800ec1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecc:	f7 f1                	div    %ecx
  800ece:	e9 4a ff ff ff       	jmp    800e1d <__umoddi3+0x2d>
  800ed3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee0:	39 f7                	cmp    %esi,%edi
  800ee2:	72 05                	jb     800ee9 <__umoddi3+0xf9>
  800ee4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ee7:	77 0c                	ja     800ef5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee9:	89 f2                	mov    %esi,%edx
  800eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eee:	29 c8                	sub    %ecx,%eax
  800ef0:	19 fa                	sbb    %edi,%edx
  800ef2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    
  800eff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f00:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f08:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f0b:	eb 84                	jmp    800e91 <__umoddi3+0xa1>
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f10:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f13:	72 eb                	jb     800f00 <__umoddi3+0x110>
  800f15:	89 f2                	mov    %esi,%edx
  800f17:	e9 75 ff ff ff       	jmp    800e91 <__umoddi3+0xa1>
