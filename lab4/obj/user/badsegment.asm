
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
  80004b:	e8 0d 01 00 00       	call   80015d <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	29 d0                	sub    %edx,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 f6                	test   %esi,%esi
  80006d:	7e 07                	jle    800076 <libmain+0x36>
		binaryname = argv[0];
  80006f:	8b 03                	mov    (%ebx),%eax
  800071:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
  800085:	83 c4 10             	add    $0x10,%esp
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    
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
  8000d6:	68 0a 0f 80 00       	push   $0x800f0a
  8000db:	6a 42                	push   $0x42
  8000dd:	68 27 0f 80 00       	push   $0x800f27
  8000e2:	e8 bd 01 00 00       	call   8002a4 <_panic>

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
	...

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ac:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002b2:	e8 a6 fe ff ff       	call   80015d <sys_getenvid>
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	ff 75 08             	pushl  0x8(%ebp)
  8002c0:	53                   	push   %ebx
  8002c1:	50                   	push   %eax
  8002c2:	68 38 0f 80 00       	push   $0x800f38
  8002c7:	e8 b0 00 00 00       	call   80037c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cc:	83 c4 18             	add    $0x18,%esp
  8002cf:	56                   	push   %esi
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	e8 53 00 00 00       	call   80032b <vcprintf>
	cprintf("\n");
  8002d8:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  8002df:	e8 98 00 00 00       	call   80037c <cprintf>
  8002e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e7:	cc                   	int3   
  8002e8:	eb fd                	jmp    8002e7 <_panic+0x43>
	...

008002ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 04             	sub    $0x4,%esp
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f6:	8b 03                	mov    (%ebx),%eax
  8002f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ff:	40                   	inc    %eax
  800300:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800302:	3d ff 00 00 00       	cmp    $0xff,%eax
  800307:	75 1a                	jne    800323 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	68 ff 00 00 00       	push   $0xff
  800311:	8d 43 08             	lea    0x8(%ebx),%eax
  800314:	50                   	push   %eax
  800315:	e8 d7 fd ff ff       	call   8000f1 <sys_cputs>
		b->idx = 0;
  80031a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800320:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800323:	ff 43 04             	incl   0x4(%ebx)
}
  800326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800334:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033b:	00 00 00 
	b.cnt = 0;
  80033e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800345:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	50                   	push   %eax
  800355:	68 ec 02 80 00       	push   $0x8002ec
  80035a:	e8 82 01 00 00       	call   8004e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035f:	83 c4 08             	add    $0x8,%esp
  800362:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800368:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036e:	50                   	push   %eax
  80036f:	e8 7d fd ff ff       	call   8000f1 <sys_cputs>

	return b.cnt;
}
  800374:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800382:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800385:	50                   	push   %eax
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	e8 9d ff ff ff       	call   80032b <vcprintf>
	va_end(ap);

	return cnt;
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 2c             	sub    $0x2c,%esp
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	89 d6                	mov    %edx,%esi
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003bd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003c0:	72 0c                	jb     8003ce <printnum+0x3e>
  8003c2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003c5:	76 07                	jbe    8003ce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f 31                	jg     8003fd <printnum+0x6d>
  8003cc:	eb 3f                	jmp    80040d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ce:	83 ec 0c             	sub    $0xc,%esp
  8003d1:	57                   	push   %edi
  8003d2:	4b                   	dec    %ebx
  8003d3:	53                   	push   %ebx
  8003d4:	50                   	push   %eax
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003db:	ff 75 d0             	pushl  -0x30(%ebp)
  8003de:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e4:	e8 c7 08 00 00       	call   800cb0 <__udivdi3>
  8003e9:	83 c4 18             	add    $0x18,%esp
  8003ec:	52                   	push   %edx
  8003ed:	50                   	push   %eax
  8003ee:	89 f2                	mov    %esi,%edx
  8003f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f3:	e8 98 ff ff ff       	call   800390 <printnum>
  8003f8:	83 c4 20             	add    $0x20,%esp
  8003fb:	eb 10                	jmp    80040d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	56                   	push   %esi
  800401:	57                   	push   %edi
  800402:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800405:	4b                   	dec    %ebx
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	85 db                	test   %ebx,%ebx
  80040b:	7f f0                	jg     8003fd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	56                   	push   %esi
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	ff 75 d4             	pushl  -0x2c(%ebp)
  800417:	ff 75 d0             	pushl  -0x30(%ebp)
  80041a:	ff 75 dc             	pushl  -0x24(%ebp)
  80041d:	ff 75 d8             	pushl  -0x28(%ebp)
  800420:	e8 a7 09 00 00       	call   800dcc <__umoddi3>
  800425:	83 c4 14             	add    $0x14,%esp
  800428:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  80042f:	50                   	push   %eax
  800430:	ff 55 e4             	call   *-0x1c(%ebp)
  800433:	83 c4 10             	add    $0x10,%esp
}
  800436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800441:	83 fa 01             	cmp    $0x1,%edx
  800444:	7e 0e                	jle    800454 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800446:	8b 10                	mov    (%eax),%edx
  800448:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044b:	89 08                	mov    %ecx,(%eax)
  80044d:	8b 02                	mov    (%edx),%eax
  80044f:	8b 52 04             	mov    0x4(%edx),%edx
  800452:	eb 22                	jmp    800476 <getuint+0x38>
	else if (lflag)
  800454:	85 d2                	test   %edx,%edx
  800456:	74 10                	je     800468 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	eb 0e                	jmp    800476 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800468:	8b 10                	mov    (%eax),%edx
  80046a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 02                	mov    (%edx),%eax
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047b:	83 fa 01             	cmp    $0x1,%edx
  80047e:	7e 0e                	jle    80048e <getint+0x16>
		return va_arg(*ap, long long);
  800480:	8b 10                	mov    (%eax),%edx
  800482:	8d 4a 08             	lea    0x8(%edx),%ecx
  800485:	89 08                	mov    %ecx,(%eax)
  800487:	8b 02                	mov    (%edx),%eax
  800489:	8b 52 04             	mov    0x4(%edx),%edx
  80048c:	eb 1a                	jmp    8004a8 <getint+0x30>
	else if (lflag)
  80048e:	85 d2                	test   %edx,%edx
  800490:	74 0c                	je     80049e <getint+0x26>
		return va_arg(*ap, long);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	99                   	cltd   
  80049c:	eb 0a                	jmp    8004a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80049e:	8b 10                	mov    (%eax),%edx
  8004a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a3:	89 08                	mov    %ecx,(%eax)
  8004a5:	8b 02                	mov    (%edx),%eax
  8004a7:	99                   	cltd   
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b8:	73 08                	jae    8004c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8004ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004bd:	88 0a                	mov    %cl,(%edx)
  8004bf:	42                   	inc    %edx
  8004c0:	89 10                	mov    %edx,(%eax)
}
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cd:	50                   	push   %eax
  8004ce:	ff 75 10             	pushl  0x10(%ebp)
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	ff 75 08             	pushl  0x8(%ebp)
  8004d7:	e8 05 00 00 00       	call   8004e1 <vprintfmt>
	va_end(ap);
  8004dc:	83 c4 10             	add    $0x10,%esp
}
  8004df:	c9                   	leave  
  8004e0:	c3                   	ret    

008004e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	57                   	push   %edi
  8004e5:	56                   	push   %esi
  8004e6:	53                   	push   %ebx
  8004e7:	83 ec 2c             	sub    $0x2c,%esp
  8004ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f0:	eb 13                	jmp    800505 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	0f 84 6d 03 00 00    	je     800867 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	57                   	push   %edi
  8004fe:	50                   	push   %eax
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800505:	0f b6 06             	movzbl (%esi),%eax
  800508:	46                   	inc    %esi
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e4                	jne    8004f2 <vprintfmt+0x11>
  80050e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800512:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800519:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800520:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800527:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052c:	eb 28                	jmp    800556 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800530:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800534:	eb 20                	jmp    800556 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800538:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800540:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800547:	eb 0d                	jmp    800556 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800549:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80054c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8a 06                	mov    (%esi),%al
  800558:	0f b6 d0             	movzbl %al,%edx
  80055b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80055e:	83 e8 23             	sub    $0x23,%eax
  800561:	3c 55                	cmp    $0x55,%al
  800563:	0f 87 e0 02 00 00    	ja     800849 <vprintfmt+0x368>
  800569:	0f b6 c0             	movzbl %al,%eax
  80056c:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800573:	83 ea 30             	sub    $0x30,%edx
  800576:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800579:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80057c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80057f:	83 fa 09             	cmp    $0x9,%edx
  800582:	77 44                	ja     8005c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	89 de                	mov    %ebx,%esi
  800586:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800589:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80058a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80058d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800591:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800594:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800597:	83 fb 09             	cmp    $0x9,%ebx
  80059a:	76 ed                	jbe    800589 <vprintfmt+0xa8>
  80059c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059f:	eb 29                	jmp    8005ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b1:	eb 17                	jmp    8005ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b7:	78 85                	js     80053e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	89 de                	mov    %ebx,%esi
  8005bb:	eb 99                	jmp    800556 <vprintfmt+0x75>
  8005bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005c6:	eb 8e                	jmp    800556 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ce:	79 86                	jns    800556 <vprintfmt+0x75>
  8005d0:	e9 74 ff ff ff       	jmp    800549 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	89 de                	mov    %ebx,%esi
  8005d8:	e9 79 ff ff ff       	jmp    800556 <vprintfmt+0x75>
  8005dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	ff 30                	pushl  (%eax)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f8:	e9 08 ff ff ff       	jmp    800505 <vprintfmt+0x24>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	85 c0                	test   %eax,%eax
  80060d:	79 02                	jns    800611 <vprintfmt+0x130>
  80060f:	f7 d8                	neg    %eax
  800611:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800613:	83 f8 08             	cmp    $0x8,%eax
  800616:	7f 0b                	jg     800623 <vprintfmt+0x142>
  800618:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  80061f:	85 c0                	test   %eax,%eax
  800621:	75 1a                	jne    80063d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800623:	52                   	push   %edx
  800624:	68 76 0f 80 00       	push   $0x800f76
  800629:	57                   	push   %edi
  80062a:	ff 75 08             	pushl  0x8(%ebp)
  80062d:	e8 92 fe ff ff       	call   8004c4 <printfmt>
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800638:	e9 c8 fe ff ff       	jmp    800505 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80063d:	50                   	push   %eax
  80063e:	68 7f 0f 80 00       	push   $0x800f7f
  800643:	57                   	push   %edi
  800644:	ff 75 08             	pushl  0x8(%ebp)
  800647:	e8 78 fe ff ff       	call   8004c4 <printfmt>
  80064c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800652:	e9 ae fe ff ff       	jmp    800505 <vprintfmt+0x24>
  800657:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80065a:	89 de                	mov    %ebx,%esi
  80065c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80065f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800670:	85 c0                	test   %eax,%eax
  800672:	75 07                	jne    80067b <vprintfmt+0x19a>
				p = "(null)";
  800674:	c7 45 d0 6f 0f 80 00 	movl   $0x800f6f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80067b:	85 db                	test   %ebx,%ebx
  80067d:	7e 42                	jle    8006c1 <vprintfmt+0x1e0>
  80067f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800683:	74 3c                	je     8006c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	51                   	push   %ecx
  800689:	ff 75 d0             	pushl  -0x30(%ebp)
  80068c:	e8 6f 02 00 00       	call   800900 <strnlen>
  800691:	29 c3                	sub    %eax,%ebx
  800693:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	85 db                	test   %ebx,%ebx
  80069b:	7e 24                	jle    8006c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80069d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	57                   	push   %edi
  8006ab:	53                   	push   %ebx
  8006ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006af:	4e                   	dec    %esi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 f6                	test   %esi,%esi
  8006b5:	7f f0                	jg     8006a7 <vprintfmt+0x1c6>
  8006b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c4:	0f be 02             	movsbl (%edx),%eax
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	75 47                	jne    800712 <vprintfmt+0x231>
  8006cb:	eb 37                	jmp    800704 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d1:	74 16                	je     8006e9 <vprintfmt+0x208>
  8006d3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d6:	83 fa 5e             	cmp    $0x5e,%edx
  8006d9:	76 0e                	jbe    8006e9 <vprintfmt+0x208>
					putch('?', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	57                   	push   %edi
  8006df:	6a 3f                	push   $0x3f
  8006e1:	ff 55 08             	call   *0x8(%ebp)
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb 0b                	jmp    8006f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	57                   	push   %edi
  8006ed:	50                   	push   %eax
  8006ee:	ff 55 08             	call   *0x8(%ebp)
  8006f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f4:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f7:	0f be 03             	movsbl (%ebx),%eax
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 03                	je     800701 <vprintfmt+0x220>
  8006fe:	43                   	inc    %ebx
  8006ff:	eb 1b                	jmp    80071c <vprintfmt+0x23b>
  800701:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800704:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800708:	7f 1e                	jg     800728 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80070d:	e9 f3 fd ff ff       	jmp    800505 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800712:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800715:	43                   	inc    %ebx
  800716:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800719:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80071c:	85 f6                	test   %esi,%esi
  80071e:	78 ad                	js     8006cd <vprintfmt+0x1ec>
  800720:	4e                   	dec    %esi
  800721:	79 aa                	jns    8006cd <vprintfmt+0x1ec>
  800723:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800726:	eb dc                	jmp    800704 <vprintfmt+0x223>
  800728:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	57                   	push   %edi
  80072f:	6a 20                	push   $0x20
  800731:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800734:	4b                   	dec    %ebx
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 db                	test   %ebx,%ebx
  80073a:	7f ef                	jg     80072b <vprintfmt+0x24a>
  80073c:	e9 c4 fd ff ff       	jmp    800505 <vprintfmt+0x24>
  800741:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 2a fd ff ff       	call   800478 <getint>
  80074e:	89 c3                	mov    %eax,%ebx
  800750:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800752:	85 d2                	test   %edx,%edx
  800754:	78 0a                	js     800760 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800756:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075b:	e9 b0 00 00 00       	jmp    800810 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	57                   	push   %edi
  800764:	6a 2d                	push   $0x2d
  800766:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800769:	f7 db                	neg    %ebx
  80076b:	83 d6 00             	adc    $0x0,%esi
  80076e:	f7 de                	neg    %esi
  800770:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800773:	b8 0a 00 00 00       	mov    $0xa,%eax
  800778:	e9 93 00 00 00       	jmp    800810 <vprintfmt+0x32f>
  80077d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800780:	89 ca                	mov    %ecx,%edx
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
  800785:	e8 b4 fc ff ff       	call   80043e <getuint>
  80078a:	89 c3                	mov    %eax,%ebx
  80078c:	89 d6                	mov    %edx,%esi
			base = 10;
  80078e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800793:	eb 7b                	jmp    800810 <vprintfmt+0x32f>
  800795:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800798:	89 ca                	mov    %ecx,%edx
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
  80079d:	e8 d6 fc ff ff       	call   800478 <getint>
  8007a2:	89 c3                	mov    %eax,%ebx
  8007a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	78 07                	js     8007b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8007af:	eb 5f                	jmp    800810 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	57                   	push   %edi
  8007b5:	6a 2d                	push   $0x2d
  8007b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007ba:	f7 db                	neg    %ebx
  8007bc:	83 d6 00             	adc    $0x0,%esi
  8007bf:	f7 de                	neg    %esi
  8007c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007c9:	eb 45                	jmp    800810 <vprintfmt+0x32f>
  8007cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	57                   	push   %edi
  8007d2:	6a 30                	push   $0x30
  8007d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d7:	83 c4 08             	add    $0x8,%esp
  8007da:	57                   	push   %edi
  8007db:	6a 78                	push   $0x78
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e9:	8b 18                	mov    (%eax),%ebx
  8007eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f8:	eb 16                	jmp    800810 <vprintfmt+0x32f>
  8007fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fd:	89 ca                	mov    %ecx,%edx
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 37 fc ff ff       	call   80043e <getuint>
  800807:	89 c3                	mov    %eax,%ebx
  800809:	89 d6                	mov    %edx,%esi
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800810:	83 ec 0c             	sub    $0xc,%esp
  800813:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800817:	52                   	push   %edx
  800818:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081b:	50                   	push   %eax
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	89 fa                	mov    %edi,%edx
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	e8 68 fb ff ff       	call   800390 <printnum>
			break;
  800828:	83 c4 20             	add    $0x20,%esp
  80082b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80082e:	e9 d2 fc ff ff       	jmp    800505 <vprintfmt+0x24>
  800833:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	57                   	push   %edi
  80083a:	52                   	push   %edx
  80083b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80083e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800841:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800844:	e9 bc fc ff ff       	jmp    800505 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	57                   	push   %edi
  80084d:	6a 25                	push   $0x25
  80084f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	eb 02                	jmp    800859 <vprintfmt+0x378>
  800857:	89 c6                	mov    %eax,%esi
  800859:	8d 46 ff             	lea    -0x1(%esi),%eax
  80085c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800860:	75 f5                	jne    800857 <vprintfmt+0x376>
  800862:	e9 9e fc ff ff       	jmp    800505 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800867:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5f                   	pop    %edi
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 18             	sub    $0x18,%esp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800882:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088c:	85 c0                	test   %eax,%eax
  80088e:	74 26                	je     8008b6 <vsnprintf+0x47>
  800890:	85 d2                	test   %edx,%edx
  800892:	7e 29                	jle    8008bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800894:	ff 75 14             	pushl  0x14(%ebp)
  800897:	ff 75 10             	pushl  0x10(%ebp)
  80089a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	68 aa 04 80 00       	push   $0x8004aa
  8008a3:	e8 39 fc ff ff       	call   8004e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 0c                	jmp    8008c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bb:	eb 05                	jmp    8008c2 <vsnprintf+0x53>
  8008bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008cd:	50                   	push   %eax
  8008ce:	ff 75 10             	pushl  0x10(%ebp)
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	ff 75 08             	pushl  0x8(%ebp)
  8008d7:	e8 93 ff ff ff       	call   80086f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    
	...

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e9:	74 0e                	je     8008f9 <strlen+0x19>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f5:	75 f9                	jne    8008f0 <strlen+0x10>
  8008f7:	eb 05                	jmp    8008fe <strlen+0x1e>
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 17                	je     800924 <strnlen+0x24>
  80090d:	80 39 00             	cmpb   $0x0,(%ecx)
  800910:	74 19                	je     80092b <strnlen+0x2b>
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800917:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800918:	39 d0                	cmp    %edx,%eax
  80091a:	74 14                	je     800930 <strnlen+0x30>
  80091c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800920:	75 f5                	jne    800917 <strnlen+0x17>
  800922:	eb 0c                	jmp    800930 <strnlen+0x30>
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
  800929:	eb 05                	jmp    800930 <strnlen+0x30>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80093c:	ba 00 00 00 00       	mov    $0x0,%edx
  800941:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800944:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800947:	42                   	inc    %edx
  800948:	84 c9                	test   %cl,%cl
  80094a:	75 f5                	jne    800941 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80094c:	5b                   	pop    %ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800956:	53                   	push   %ebx
  800957:	e8 84 ff ff ff       	call   8008e0 <strlen>
  80095c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800965:	50                   	push   %eax
  800966:	e8 c7 ff ff ff       	call   800932 <strcpy>
	return dst;
}
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800980:	85 f6                	test   %esi,%esi
  800982:	74 15                	je     800999 <strncpy+0x27>
  800984:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800989:	8a 1a                	mov    (%edx),%bl
  80098b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098e:	80 3a 01             	cmpb   $0x1,(%edx)
  800991:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800994:	41                   	inc    %ecx
  800995:	39 ce                	cmp    %ecx,%esi
  800997:	77 f0                	ja     800989 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	57                   	push   %edi
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ac:	85 f6                	test   %esi,%esi
  8009ae:	74 32                	je     8009e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009b0:	83 fe 01             	cmp    $0x1,%esi
  8009b3:	74 22                	je     8009d7 <strlcpy+0x3a>
  8009b5:	8a 0b                	mov    (%ebx),%cl
  8009b7:	84 c9                	test   %cl,%cl
  8009b9:	74 20                	je     8009db <strlcpy+0x3e>
  8009bb:	89 f8                	mov    %edi,%eax
  8009bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c5:	88 08                	mov    %cl,(%eax)
  8009c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c8:	39 f2                	cmp    %esi,%edx
  8009ca:	74 11                	je     8009dd <strlcpy+0x40>
  8009cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009d0:	42                   	inc    %edx
  8009d1:	84 c9                	test   %cl,%cl
  8009d3:	75 f0                	jne    8009c5 <strlcpy+0x28>
  8009d5:	eb 06                	jmp    8009dd <strlcpy+0x40>
  8009d7:	89 f8                	mov    %edi,%eax
  8009d9:	eb 02                	jmp    8009dd <strlcpy+0x40>
  8009db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009dd:	c6 00 00             	movb   $0x0,(%eax)
  8009e0:	eb 02                	jmp    8009e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009e4:	29 f8                	sub    %edi,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f4:	8a 01                	mov    (%ecx),%al
  8009f6:	84 c0                	test   %al,%al
  8009f8:	74 10                	je     800a0a <strcmp+0x1f>
  8009fa:	3a 02                	cmp    (%edx),%al
  8009fc:	75 0c                	jne    800a0a <strcmp+0x1f>
		p++, q++;
  8009fe:	41                   	inc    %ecx
  8009ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a00:	8a 01                	mov    (%ecx),%al
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strcmp+0x1f>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	74 f4                	je     8009fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 1b                	je     800a40 <strncmp+0x2c>
  800a25:	8a 1a                	mov    (%edx),%bl
  800a27:	84 db                	test   %bl,%bl
  800a29:	74 24                	je     800a4f <strncmp+0x3b>
  800a2b:	3a 19                	cmp    (%ecx),%bl
  800a2d:	75 20                	jne    800a4f <strncmp+0x3b>
  800a2f:	48                   	dec    %eax
  800a30:	74 15                	je     800a47 <strncmp+0x33>
		n--, p++, q++;
  800a32:	42                   	inc    %edx
  800a33:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a34:	8a 1a                	mov    (%edx),%bl
  800a36:	84 db                	test   %bl,%bl
  800a38:	74 15                	je     800a4f <strncmp+0x3b>
  800a3a:	3a 19                	cmp    (%ecx),%bl
  800a3c:	74 f1                	je     800a2f <strncmp+0x1b>
  800a3e:	eb 0f                	jmp    800a4f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	eb 05                	jmp    800a4c <strncmp+0x38>
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4f:	0f b6 02             	movzbl (%edx),%eax
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	29 d0                	sub    %edx,%eax
  800a57:	eb f3                	jmp    800a4c <strncmp+0x38>

00800a59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a62:	8a 10                	mov    (%eax),%dl
  800a64:	84 d2                	test   %dl,%dl
  800a66:	74 18                	je     800a80 <strchr+0x27>
		if (*s == c)
  800a68:	38 ca                	cmp    %cl,%dl
  800a6a:	75 06                	jne    800a72 <strchr+0x19>
  800a6c:	eb 17                	jmp    800a85 <strchr+0x2c>
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 13                	je     800a85 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	40                   	inc    %eax
  800a73:	8a 10                	mov    (%eax),%dl
  800a75:	84 d2                	test   %dl,%dl
  800a77:	75 f5                	jne    800a6e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	eb 05                	jmp    800a85 <strchr+0x2c>
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a90:	8a 10                	mov    (%eax),%dl
  800a92:	84 d2                	test   %dl,%dl
  800a94:	74 11                	je     800aa7 <strfind+0x20>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	75 06                	jne    800aa0 <strfind+0x19>
  800a9a:	eb 0b                	jmp    800aa7 <strfind+0x20>
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	74 07                	je     800aa7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa0:	40                   	inc    %eax
  800aa1:	8a 10                	mov    (%eax),%dl
  800aa3:	84 d2                	test   %dl,%dl
  800aa5:	75 f5                	jne    800a9c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab8:	85 c9                	test   %ecx,%ecx
  800aba:	74 30                	je     800aec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac2:	75 25                	jne    800ae9 <memset+0x40>
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 20                	jne    800ae9 <memset+0x40>
		c &= 0xFF;
  800ac9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	c1 e3 08             	shl    $0x8,%ebx
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	c1 e6 18             	shl    $0x18,%esi
  800ad6:	89 d0                	mov    %edx,%eax
  800ad8:	c1 e0 10             	shl    $0x10,%eax
  800adb:	09 f0                	or     %esi,%eax
  800add:	09 d0                	or     %edx,%eax
  800adf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae4:	fc                   	cld    
  800ae5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae7:	eb 03                	jmp    800aec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae9:	fc                   	cld    
  800aea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b01:	39 c6                	cmp    %eax,%esi
  800b03:	73 34                	jae    800b39 <memmove+0x46>
  800b05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b08:	39 d0                	cmp    %edx,%eax
  800b0a:	73 2d                	jae    800b39 <memmove+0x46>
		s += n;
		d += n;
  800b0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0f:	f6 c2 03             	test   $0x3,%dl
  800b12:	75 1b                	jne    800b2f <memmove+0x3c>
  800b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1a:	75 13                	jne    800b2f <memmove+0x3c>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 0e                	jne    800b2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b21:	83 ef 04             	sub    $0x4,%edi
  800b24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2a:	fd                   	std    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 07                	jmp    800b36 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2f:	4f                   	dec    %edi
  800b30:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b33:	fd                   	std    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b36:	fc                   	cld    
  800b37:	eb 20                	jmp    800b59 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3f:	75 13                	jne    800b54 <memmove+0x61>
  800b41:	a8 03                	test   $0x3,%al
  800b43:	75 0f                	jne    800b54 <memmove+0x61>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 0a                	jne    800b54 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b52:	eb 05                	jmp    800b59 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	fc                   	cld    
  800b57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b60:	ff 75 10             	pushl  0x10(%ebp)
  800b63:	ff 75 0c             	pushl  0xc(%ebp)
  800b66:	ff 75 08             	pushl  0x8(%ebp)
  800b69:	e8 85 ff ff ff       	call   800af3 <memmove>
}
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	85 ff                	test   %edi,%edi
  800b81:	74 32                	je     800bb5 <memcmp+0x45>
		if (*s1 != *s2)
  800b83:	8a 03                	mov    (%ebx),%al
  800b85:	8a 0e                	mov    (%esi),%cl
  800b87:	38 c8                	cmp    %cl,%al
  800b89:	74 19                	je     800ba4 <memcmp+0x34>
  800b8b:	eb 0d                	jmp    800b9a <memcmp+0x2a>
  800b8d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b91:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b95:	42                   	inc    %edx
  800b96:	38 c8                	cmp    %cl,%al
  800b98:	74 10                	je     800baa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b9a:	0f b6 c0             	movzbl %al,%eax
  800b9d:	0f b6 c9             	movzbl %cl,%ecx
  800ba0:	29 c8                	sub    %ecx,%eax
  800ba2:	eb 16                	jmp    800bba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba4:	4f                   	dec    %edi
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	39 fa                	cmp    %edi,%edx
  800bac:	75 df                	jne    800b8d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	eb 05                	jmp    800bba <memcmp+0x4a>
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bca:	39 d0                	cmp    %edx,%eax
  800bcc:	73 12                	jae    800be0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bce:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bd1:	38 08                	cmp    %cl,(%eax)
  800bd3:	75 06                	jne    800bdb <memfind+0x1c>
  800bd5:	eb 09                	jmp    800be0 <memfind+0x21>
  800bd7:	38 08                	cmp    %cl,(%eax)
  800bd9:	74 05                	je     800be0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bdb:	40                   	inc    %eax
  800bdc:	39 c2                	cmp    %eax,%edx
  800bde:	77 f7                	ja     800bd7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bee:	eb 01                	jmp    800bf1 <strtol+0xf>
		s++;
  800bf0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf1:	8a 02                	mov    (%edx),%al
  800bf3:	3c 20                	cmp    $0x20,%al
  800bf5:	74 f9                	je     800bf0 <strtol+0xe>
  800bf7:	3c 09                	cmp    $0x9,%al
  800bf9:	74 f5                	je     800bf0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfb:	3c 2b                	cmp    $0x2b,%al
  800bfd:	75 08                	jne    800c07 <strtol+0x25>
		s++;
  800bff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c00:	bf 00 00 00 00       	mov    $0x0,%edi
  800c05:	eb 13                	jmp    800c1a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c07:	3c 2d                	cmp    $0x2d,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x33>
		s++, neg = 1;
  800c0b:	8d 52 01             	lea    0x1(%edx),%edx
  800c0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c13:	eb 05                	jmp    800c1a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1a:	85 db                	test   %ebx,%ebx
  800c1c:	74 05                	je     800c23 <strtol+0x41>
  800c1e:	83 fb 10             	cmp    $0x10,%ebx
  800c21:	75 28                	jne    800c4b <strtol+0x69>
  800c23:	8a 02                	mov    (%edx),%al
  800c25:	3c 30                	cmp    $0x30,%al
  800c27:	75 10                	jne    800c39 <strtol+0x57>
  800c29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c2d:	75 0a                	jne    800c39 <strtol+0x57>
		s += 2, base = 16;
  800c2f:	83 c2 02             	add    $0x2,%edx
  800c32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c37:	eb 12                	jmp    800c4b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c39:	85 db                	test   %ebx,%ebx
  800c3b:	75 0e                	jne    800c4b <strtol+0x69>
  800c3d:	3c 30                	cmp    $0x30,%al
  800c3f:	75 05                	jne    800c46 <strtol+0x64>
		s++, base = 8;
  800c41:	42                   	inc    %edx
  800c42:	b3 08                	mov    $0x8,%bl
  800c44:	eb 05                	jmp    800c4b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c46:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c52:	8a 0a                	mov    (%edx),%cl
  800c54:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c57:	80 fb 09             	cmp    $0x9,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0x82>
			dig = *s - '0';
  800c5c:	0f be c9             	movsbl %cl,%ecx
  800c5f:	83 e9 30             	sub    $0x30,%ecx
  800c62:	eb 1e                	jmp    800c82 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c64:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c67:	80 fb 19             	cmp    $0x19,%bl
  800c6a:	77 08                	ja     800c74 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c6c:	0f be c9             	movsbl %cl,%ecx
  800c6f:	83 e9 57             	sub    $0x57,%ecx
  800c72:	eb 0e                	jmp    800c82 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c74:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 13                	ja     800c8f <strtol+0xad>
			dig = *s - 'A' + 10;
  800c7c:	0f be c9             	movsbl %cl,%ecx
  800c7f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c82:	39 f1                	cmp    %esi,%ecx
  800c84:	7d 0d                	jge    800c93 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c86:	42                   	inc    %edx
  800c87:	0f af c6             	imul   %esi,%eax
  800c8a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c8d:	eb c3                	jmp    800c52 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	eb 02                	jmp    800c95 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c93:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c99:	74 05                	je     800ca0 <strtol+0xbe>
		*endptr = (char *) s;
  800c9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c9e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	74 04                	je     800ca8 <strtol+0xc6>
  800ca4:	89 c8                	mov    %ecx,%eax
  800ca6:	f7 d8                	neg    %eax
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    
  800cad:	00 00                	add    %al,(%eax)
	...

00800cb0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	83 ec 10             	sub    $0x10,%esp
  800cb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cbe:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cc7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	75 2e                	jne    800cfc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cce:	39 f1                	cmp    %esi,%ecx
  800cd0:	77 5a                	ja     800d2c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cd2:	85 c9                	test   %ecx,%ecx
  800cd4:	75 0b                	jne    800ce1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  800cdd:	f7 f1                	div    %ecx
  800cdf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ce1:	31 d2                	xor    %edx,%edx
  800ce3:	89 f0                	mov    %esi,%eax
  800ce5:	f7 f1                	div    %ecx
  800ce7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ce9:	89 f8                	mov    %edi,%eax
  800ceb:	f7 f1                	div    %ecx
  800ced:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    
  800cfa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cfc:	39 f0                	cmp    %esi,%eax
  800cfe:	77 1c                	ja     800d1c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d00:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d03:	83 f7 1f             	xor    $0x1f,%edi
  800d06:	75 3c                	jne    800d44 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d08:	39 f0                	cmp    %esi,%eax
  800d0a:	0f 82 90 00 00 00    	jb     800da0 <__udivdi3+0xf0>
  800d10:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d13:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d16:	0f 86 84 00 00 00    	jbe    800da0 <__udivdi3+0xf0>
  800d1c:	31 f6                	xor    %esi,%esi
  800d1e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d20:	89 f8                	mov    %edi,%eax
  800d22:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d24:	83 c4 10             	add    $0x10,%esp
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    
  800d2b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2c:	89 f2                	mov    %esi,%edx
  800d2e:	89 f8                	mov    %edi,%eax
  800d30:	f7 f1                	div    %ecx
  800d32:	89 c7                	mov    %eax,%edi
  800d34:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d36:	89 f8                	mov    %edi,%eax
  800d38:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    
  800d41:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d44:	89 f9                	mov    %edi,%ecx
  800d46:	d3 e0                	shl    %cl,%eax
  800d48:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d4b:	b8 20 00 00 00       	mov    $0x20,%eax
  800d50:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d55:	88 c1                	mov    %al,%cl
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d5c:	09 ca                	or     %ecx,%edx
  800d5e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d64:	89 f9                	mov    %edi,%ecx
  800d66:	d3 e2                	shl    %cl,%edx
  800d68:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	88 c1                	mov    %al,%cl
  800d6f:	d3 ea                	shr    %cl,%edx
  800d71:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d74:	89 f2                	mov    %esi,%edx
  800d76:	89 f9                	mov    %edi,%ecx
  800d78:	d3 e2                	shl    %cl,%edx
  800d7a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d7d:	88 c1                	mov    %al,%cl
  800d7f:	d3 ee                	shr    %cl,%esi
  800d81:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d83:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	89 ca                	mov    %ecx,%edx
  800d8a:	f7 75 ec             	divl   -0x14(%ebp)
  800d8d:	89 d1                	mov    %edx,%ecx
  800d8f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d91:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d94:	39 d1                	cmp    %edx,%ecx
  800d96:	72 28                	jb     800dc0 <__udivdi3+0x110>
  800d98:	74 1a                	je     800db4 <__udivdi3+0x104>
  800d9a:	89 f7                	mov    %esi,%edi
  800d9c:	31 f6                	xor    %esi,%esi
  800d9e:	eb 80                	jmp    800d20 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da0:	31 f6                	xor    %esi,%esi
  800da2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da7:	89 f8                	mov    %edi,%eax
  800da9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    
  800db2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800db4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800db7:	89 f9                	mov    %edi,%ecx
  800db9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dbb:	39 c2                	cmp    %eax,%edx
  800dbd:	73 db                	jae    800d9a <__udivdi3+0xea>
  800dbf:	90                   	nop
		{
		  q0--;
  800dc0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc3:	31 f6                	xor    %esi,%esi
  800dc5:	e9 56 ff ff ff       	jmp    800d20 <__udivdi3+0x70>
	...

00800dcc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	83 ec 20             	sub    $0x20,%esp
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dda:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ddd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800de0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800de3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800de6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800de9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800deb:	85 ff                	test   %edi,%edi
  800ded:	75 15                	jne    800e04 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800def:	39 f1                	cmp    %esi,%ecx
  800df1:	0f 86 99 00 00 00    	jbe    800e90 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e04:	39 f7                	cmp    %esi,%edi
  800e06:	0f 87 a4 00 00 00    	ja     800eb0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e0c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e0f:	83 f0 1f             	xor    $0x1f,%eax
  800e12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e15:	0f 84 a1 00 00 00    	je     800ebc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e1b:	89 f8                	mov    %edi,%eax
  800e1d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e20:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e22:	bf 20 00 00 00       	mov    $0x20,%edi
  800e27:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2d:	89 f9                	mov    %edi,%ecx
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	09 c2                	or     %eax,%edx
  800e33:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e39:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e3c:	d3 e0                	shl    %cl,%eax
  800e3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e41:	89 f2                	mov    %esi,%edx
  800e43:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e48:	d3 e0                	shl    %cl,%eax
  800e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	d3 e8                	shr    %cl,%eax
  800e54:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e56:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e58:	89 f2                	mov    %esi,%edx
  800e5a:	f7 75 f0             	divl   -0x10(%ebp)
  800e5d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e5f:	f7 65 f4             	mull   -0xc(%ebp)
  800e62:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e65:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e67:	39 d6                	cmp    %edx,%esi
  800e69:	72 71                	jb     800edc <__umoddi3+0x110>
  800e6b:	74 7f                	je     800eec <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e70:	29 c8                	sub    %ecx,%eax
  800e72:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e74:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e77:	d3 e8                	shr    %cl,%eax
  800e79:	89 f2                	mov    %esi,%edx
  800e7b:	89 f9                	mov    %edi,%ecx
  800e7d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e7f:	09 d0                	or     %edx,%eax
  800e81:	89 f2                	mov    %esi,%edx
  800e83:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e86:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e88:	83 c4 20             	add    $0x20,%esp
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    
  800e8f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e90:	85 c9                	test   %ecx,%ecx
  800e92:	75 0b                	jne    800e9f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e94:	b8 01 00 00 00       	mov    $0x1,%eax
  800e99:	31 d2                	xor    %edx,%edx
  800e9b:	f7 f1                	div    %ecx
  800e9d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e9f:	89 f0                	mov    %esi,%eax
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea8:	f7 f1                	div    %ecx
  800eaa:	e9 4a ff ff ff       	jmp    800df9 <__umoddi3+0x2d>
  800eaf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800eb0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb2:	83 c4 20             	add    $0x20,%esp
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    
  800eb9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ebc:	39 f7                	cmp    %esi,%edi
  800ebe:	72 05                	jb     800ec5 <__umoddi3+0xf9>
  800ec0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ec3:	77 0c                	ja     800ed1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec5:	89 f2                	mov    %esi,%edx
  800ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eca:	29 c8                	sub    %ecx,%eax
  800ecc:	19 fa                	sbb    %edi,%edx
  800ece:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    
  800edb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800edc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ee4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ee7:	eb 84                	jmp    800e6d <__umoddi3+0xa1>
  800ee9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800eef:	72 eb                	jb     800edc <__umoddi3+0x110>
  800ef1:	89 f2                	mov    %esi,%edx
  800ef3:	e9 75 ff ff ff       	jmp    800e6d <__umoddi3+0xa1>
