
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
  80004f:	e8 0d 01 00 00       	call   800161 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800060:	c1 e0 07             	shl    $0x7,%eax
  800063:	29 d0                	sub    %edx,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 f6                	test   %esi,%esi
  800071:	7e 07                	jle    80007a <libmain+0x36>
		binaryname = argv[0];
  800073:	8b 03                	mov    (%ebx),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	53                   	push   %ebx
  80007e:	56                   	push   %esi
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	c9                   	leave  
  800092:	c3                   	ret    
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
  8000da:	68 0a 0f 80 00       	push   $0x800f0a
  8000df:	6a 42                	push   $0x42
  8000e1:	68 27 0f 80 00       	push   $0x800f27
  8000e6:	e8 bd 01 00 00       	call   8002a8 <_panic>

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
	...

008002a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002b6:	e8 a6 fe ff ff       	call   800161 <sys_getenvid>
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	68 38 0f 80 00       	push   $0x800f38
  8002cb:	e8 b0 00 00 00       	call   800380 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d0:	83 c4 18             	add    $0x18,%esp
  8002d3:	56                   	push   %esi
  8002d4:	ff 75 10             	pushl  0x10(%ebp)
  8002d7:	e8 53 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002dc:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  8002e3:	e8 98 00 00 00       	call   800380 <cprintf>
  8002e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002eb:	cc                   	int3   
  8002ec:	eb fd                	jmp    8002eb <_panic+0x43>
	...

008002f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 04             	sub    $0x4,%esp
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800303:	40                   	inc    %eax
  800304:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800306:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030b:	75 1a                	jne    800327 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	68 ff 00 00 00       	push   $0xff
  800315:	8d 43 08             	lea    0x8(%ebx),%eax
  800318:	50                   	push   %eax
  800319:	e8 d7 fd ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  80031e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800324:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800327:	ff 43 04             	incl   0x4(%ebx)
}
  80032a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800358:	50                   	push   %eax
  800359:	68 f0 02 80 00       	push   $0x8002f0
  80035e:	e8 82 01 00 00       	call   8004e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800363:	83 c4 08             	add    $0x8,%esp
  800366:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80036c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800372:	50                   	push   %eax
  800373:	e8 7d fd ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  800378:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800386:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 08             	pushl  0x8(%ebp)
  80038d:	e8 9d ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	89 d6                	mov    %edx,%esi
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003c4:	72 0c                	jb     8003d2 <printnum+0x3e>
  8003c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003c9:	76 07                	jbe    8003d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cb:	4b                   	dec    %ebx
  8003cc:	85 db                	test   %ebx,%ebx
  8003ce:	7f 31                	jg     800401 <printnum+0x6d>
  8003d0:	eb 3f                	jmp    800411 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d2:	83 ec 0c             	sub    $0xc,%esp
  8003d5:	57                   	push   %edi
  8003d6:	4b                   	dec    %ebx
  8003d7:	53                   	push   %ebx
  8003d8:	50                   	push   %eax
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003df:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e8:	e8 c7 08 00 00       	call   800cb4 <__udivdi3>
  8003ed:	83 c4 18             	add    $0x18,%esp
  8003f0:	52                   	push   %edx
  8003f1:	50                   	push   %eax
  8003f2:	89 f2                	mov    %esi,%edx
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	e8 98 ff ff ff       	call   800394 <printnum>
  8003fc:	83 c4 20             	add    $0x20,%esp
  8003ff:	eb 10                	jmp    800411 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	56                   	push   %esi
  800405:	57                   	push   %edi
  800406:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800409:	4b                   	dec    %ebx
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	85 db                	test   %ebx,%ebx
  80040f:	7f f0                	jg     800401 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	56                   	push   %esi
  800415:	83 ec 04             	sub    $0x4,%esp
  800418:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041b:	ff 75 d0             	pushl  -0x30(%ebp)
  80041e:	ff 75 dc             	pushl  -0x24(%ebp)
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	e8 a7 09 00 00       	call   800dd0 <__umoddi3>
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  800433:	50                   	push   %eax
  800434:	ff 55 e4             	call   *-0x1c(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
}
  80043a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043d:	5b                   	pop    %ebx
  80043e:	5e                   	pop    %esi
  80043f:	5f                   	pop    %edi
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800445:	83 fa 01             	cmp    $0x1,%edx
  800448:	7e 0e                	jle    800458 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044a:	8b 10                	mov    (%eax),%edx
  80044c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044f:	89 08                	mov    %ecx,(%eax)
  800451:	8b 02                	mov    (%edx),%eax
  800453:	8b 52 04             	mov    0x4(%edx),%edx
  800456:	eb 22                	jmp    80047a <getuint+0x38>
	else if (lflag)
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 10                	je     80046c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	eb 0e                	jmp    80047a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800471:	89 08                	mov    %ecx,(%eax)
  800473:	8b 02                	mov    (%edx),%eax
  800475:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047a:	c9                   	leave  
  80047b:	c3                   	ret    

0080047c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047f:	83 fa 01             	cmp    $0x1,%edx
  800482:	7e 0e                	jle    800492 <getint+0x16>
		return va_arg(*ap, long long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 08             	lea    0x8(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	8b 52 04             	mov    0x4(%edx),%edx
  800490:	eb 1a                	jmp    8004ac <getint+0x30>
	else if (lflag)
  800492:	85 d2                	test   %edx,%edx
  800494:	74 0c                	je     8004a2 <getint+0x26>
		return va_arg(*ap, long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	99                   	cltd   
  8004a0:	eb 0a                	jmp    8004ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	99                   	cltd   
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bc:	73 08                	jae    8004c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8004be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c1:	88 0a                	mov    %cl,(%edx)
  8004c3:	42                   	inc    %edx
  8004c4:	89 10                	mov    %edx,(%eax)
}
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 10             	pushl  0x10(%ebp)
  8004d5:	ff 75 0c             	pushl  0xc(%ebp)
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 05 00 00 00       	call   8004e5 <vprintfmt>
	va_end(ap);
  8004e0:	83 c4 10             	add    $0x10,%esp
}
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	53                   	push   %ebx
  8004eb:	83 ec 2c             	sub    $0x2c,%esp
  8004ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f4:	eb 13                	jmp    800509 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	0f 84 6d 03 00 00    	je     80086b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	57                   	push   %edi
  800502:	50                   	push   %eax
  800503:	ff 55 08             	call   *0x8(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	0f b6 06             	movzbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	83 f8 25             	cmp    $0x25,%eax
  800510:	75 e4                	jne    8004f6 <vprintfmt+0x11>
  800512:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800516:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80051d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800524:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800530:	eb 28                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800534:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800538:	eb 20                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800540:	eb 18                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800544:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800553:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8a 06                	mov    (%esi),%al
  80055c:	0f b6 d0             	movzbl %al,%edx
  80055f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800562:	83 e8 23             	sub    $0x23,%eax
  800565:	3c 55                	cmp    $0x55,%al
  800567:	0f 87 e0 02 00 00    	ja     80084d <vprintfmt+0x368>
  80056d:	0f b6 c0             	movzbl %al,%eax
  800570:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800577:	83 ea 30             	sub    $0x30,%edx
  80057a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80057d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800580:	8d 50 d0             	lea    -0x30(%eax),%edx
  800583:	83 fa 09             	cmp    $0x9,%edx
  800586:	77 44                	ja     8005cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	89 de                	mov    %ebx,%esi
  80058a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80058e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800591:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800595:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800598:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059b:	83 fb 09             	cmp    $0x9,%ebx
  80059e:	76 ed                	jbe    80058d <vprintfmt+0xa8>
  8005a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a3:	eb 29                	jmp    8005ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b5:	eb 17                	jmp    8005ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bb:	78 85                	js     800542 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	89 de                	mov    %ebx,%esi
  8005bf:	eb 99                	jmp    80055a <vprintfmt+0x75>
  8005c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ca:	eb 8e                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d2:	79 86                	jns    80055a <vprintfmt+0x75>
  8005d4:	e9 74 ff ff ff       	jmp    80054d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	89 de                	mov    %ebx,%esi
  8005dc:	e9 79 ff ff ff       	jmp    80055a <vprintfmt+0x75>
  8005e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	ff 30                	pushl  (%eax)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005fc:	e9 08 ff ff ff       	jmp    800509 <vprintfmt+0x24>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 02                	jns    800615 <vprintfmt+0x130>
  800613:	f7 d8                	neg    %eax
  800615:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800617:	83 f8 08             	cmp    $0x8,%eax
  80061a:	7f 0b                	jg     800627 <vprintfmt+0x142>
  80061c:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  800623:	85 c0                	test   %eax,%eax
  800625:	75 1a                	jne    800641 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800627:	52                   	push   %edx
  800628:	68 76 0f 80 00       	push   $0x800f76
  80062d:	57                   	push   %edi
  80062e:	ff 75 08             	pushl  0x8(%ebp)
  800631:	e8 92 fe ff ff       	call   8004c8 <printfmt>
  800636:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063c:	e9 c8 fe ff ff       	jmp    800509 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800641:	50                   	push   %eax
  800642:	68 7f 0f 80 00       	push   $0x800f7f
  800647:	57                   	push   %edi
  800648:	ff 75 08             	pushl  0x8(%ebp)
  80064b:	e8 78 fe ff ff       	call   8004c8 <printfmt>
  800650:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800656:	e9 ae fe ff ff       	jmp    800509 <vprintfmt+0x24>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80065e:	89 de                	mov    %ebx,%esi
  800660:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800663:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800674:	85 c0                	test   %eax,%eax
  800676:	75 07                	jne    80067f <vprintfmt+0x19a>
				p = "(null)";
  800678:	c7 45 d0 6f 0f 80 00 	movl   $0x800f6f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80067f:	85 db                	test   %ebx,%ebx
  800681:	7e 42                	jle    8006c5 <vprintfmt+0x1e0>
  800683:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800687:	74 3c                	je     8006c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	51                   	push   %ecx
  80068d:	ff 75 d0             	pushl  -0x30(%ebp)
  800690:	e8 6f 02 00 00       	call   800904 <strnlen>
  800695:	29 c3                	sub    %eax,%ebx
  800697:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 db                	test   %ebx,%ebx
  80069f:	7e 24                	jle    8006c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	53                   	push   %ebx
  8006b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	4e                   	dec    %esi
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	7f f0                	jg     8006ab <vprintfmt+0x1c6>
  8006bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c8:	0f be 02             	movsbl (%edx),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	75 47                	jne    800716 <vprintfmt+0x231>
  8006cf:	eb 37                	jmp    800708 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d5:	74 16                	je     8006ed <vprintfmt+0x208>
  8006d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006da:	83 fa 5e             	cmp    $0x5e,%edx
  8006dd:	76 0e                	jbe    8006ed <vprintfmt+0x208>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 3f                	push   $0x3f
  8006e5:	ff 55 08             	call   *0x8(%ebp)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 0b                	jmp    8006f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	57                   	push   %edi
  8006f1:	50                   	push   %eax
  8006f2:	ff 55 08             	call   *0x8(%ebp)
  8006f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8006fb:	0f be 03             	movsbl (%ebx),%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 03                	je     800705 <vprintfmt+0x220>
  800702:	43                   	inc    %ebx
  800703:	eb 1b                	jmp    800720 <vprintfmt+0x23b>
  800705:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800708:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070c:	7f 1e                	jg     80072c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800711:	e9 f3 fd ff ff       	jmp    800509 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800716:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800719:	43                   	inc    %ebx
  80071a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80071d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800720:	85 f6                	test   %esi,%esi
  800722:	78 ad                	js     8006d1 <vprintfmt+0x1ec>
  800724:	4e                   	dec    %esi
  800725:	79 aa                	jns    8006d1 <vprintfmt+0x1ec>
  800727:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80072a:	eb dc                	jmp    800708 <vprintfmt+0x223>
  80072c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	57                   	push   %edi
  800733:	6a 20                	push   $0x20
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800738:	4b                   	dec    %ebx
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f ef                	jg     80072f <vprintfmt+0x24a>
  800740:	e9 c4 fd ff ff       	jmp    800509 <vprintfmt+0x24>
  800745:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800748:	89 ca                	mov    %ecx,%edx
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
  80074d:	e8 2a fd ff ff       	call   80047c <getint>
  800752:	89 c3                	mov    %eax,%ebx
  800754:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800756:	85 d2                	test   %edx,%edx
  800758:	78 0a                	js     800764 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075f:	e9 b0 00 00 00       	jmp    800814 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	57                   	push   %edi
  800768:	6a 2d                	push   $0x2d
  80076a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076d:	f7 db                	neg    %ebx
  80076f:	83 d6 00             	adc    $0x0,%esi
  800772:	f7 de                	neg    %esi
  800774:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077c:	e9 93 00 00 00       	jmp    800814 <vprintfmt+0x32f>
  800781:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800784:	89 ca                	mov    %ecx,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 b4 fc ff ff       	call   800442 <getuint>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	89 d6                	mov    %edx,%esi
			base = 10;
  800792:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800797:	eb 7b                	jmp    800814 <vprintfmt+0x32f>
  800799:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80079c:	89 ca                	mov    %ecx,%edx
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 d6 fc ff ff       	call   80047c <getint>
  8007a6:	89 c3                	mov    %eax,%ebx
  8007a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	78 07                	js     8007b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b3:	eb 5f                	jmp    800814 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	57                   	push   %edi
  8007b9:	6a 2d                	push   $0x2d
  8007bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007be:	f7 db                	neg    %ebx
  8007c0:	83 d6 00             	adc    $0x0,%esi
  8007c3:	f7 de                	neg    %esi
  8007c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cd:	eb 45                	jmp    800814 <vprintfmt+0x32f>
  8007cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	57                   	push   %edi
  8007d6:	6a 30                	push   $0x30
  8007d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	57                   	push   %edi
  8007df:	6a 78                	push   $0x78
  8007e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ed:	8b 18                	mov    (%eax),%ebx
  8007ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fc:	eb 16                	jmp    800814 <vprintfmt+0x32f>
  8007fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800801:	89 ca                	mov    %ecx,%edx
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	e8 37 fc ff ff       	call   800442 <getuint>
  80080b:	89 c3                	mov    %eax,%ebx
  80080d:	89 d6                	mov    %edx,%esi
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800814:	83 ec 0c             	sub    $0xc,%esp
  800817:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80081b:	52                   	push   %edx
  80081c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081f:	50                   	push   %eax
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	89 fa                	mov    %edi,%edx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	e8 68 fb ff ff       	call   800394 <printnum>
			break;
  80082c:	83 c4 20             	add    $0x20,%esp
  80082f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800832:	e9 d2 fc ff ff       	jmp    800509 <vprintfmt+0x24>
  800837:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	57                   	push   %edi
  80083e:	52                   	push   %edx
  80083f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800842:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800845:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800848:	e9 bc fc ff ff       	jmp    800509 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	57                   	push   %edi
  800851:	6a 25                	push   $0x25
  800853:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	eb 02                	jmp    80085d <vprintfmt+0x378>
  80085b:	89 c6                	mov    %eax,%esi
  80085d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800860:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800864:	75 f5                	jne    80085b <vprintfmt+0x376>
  800866:	e9 9e fc ff ff       	jmp    800509 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80086b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 18             	sub    $0x18,%esp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800882:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800886:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800890:	85 c0                	test   %eax,%eax
  800892:	74 26                	je     8008ba <vsnprintf+0x47>
  800894:	85 d2                	test   %edx,%edx
  800896:	7e 29                	jle    8008c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800898:	ff 75 14             	pushl  0x14(%ebp)
  80089b:	ff 75 10             	pushl  0x10(%ebp)
  80089e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	68 ae 04 80 00       	push   $0x8004ae
  8008a7:	e8 39 fc ff ff       	call   8004e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	eb 0c                	jmp    8008c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bf:	eb 05                	jmp    8008c6 <vsnprintf+0x53>
  8008c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d1:	50                   	push   %eax
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 93 ff ff ff       	call   800873 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    
	...

008008e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ed:	74 0e                	je     8008fd <strlen+0x19>
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f9:	75 f9                	jne    8008f4 <strlen+0x10>
  8008fb:	eb 05                	jmp    800902 <strlen+0x1e>
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090d:	85 d2                	test   %edx,%edx
  80090f:	74 17                	je     800928 <strnlen+0x24>
  800911:	80 39 00             	cmpb   $0x0,(%ecx)
  800914:	74 19                	je     80092f <strnlen+0x2b>
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	74 14                	je     800934 <strnlen+0x30>
  800920:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800924:	75 f5                	jne    80091b <strnlen+0x17>
  800926:	eb 0c                	jmp    800934 <strnlen+0x30>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 05                	jmp    800934 <strnlen+0x30>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800940:	ba 00 00 00 00       	mov    $0x0,%edx
  800945:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800948:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80094b:	42                   	inc    %edx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 f5                	jne    800945 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800950:	5b                   	pop    %ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095a:	53                   	push   %ebx
  80095b:	e8 84 ff ff ff       	call   8008e4 <strlen>
  800960:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800969:	50                   	push   %eax
  80096a:	e8 c7 ff ff ff       	call   800936 <strcpy>
	return dst;
}
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800984:	85 f6                	test   %esi,%esi
  800986:	74 15                	je     80099d <strncpy+0x27>
  800988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80098d:	8a 1a                	mov    (%edx),%bl
  80098f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800992:	80 3a 01             	cmpb   $0x1,(%edx)
  800995:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	41                   	inc    %ecx
  800999:	39 ce                	cmp    %ecx,%esi
  80099b:	77 f0                	ja     80098d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b0:	85 f6                	test   %esi,%esi
  8009b2:	74 32                	je     8009e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009b4:	83 fe 01             	cmp    $0x1,%esi
  8009b7:	74 22                	je     8009db <strlcpy+0x3a>
  8009b9:	8a 0b                	mov    (%ebx),%cl
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	74 20                	je     8009df <strlcpy+0x3e>
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	88 08                	mov    %cl,(%eax)
  8009cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009cc:	39 f2                	cmp    %esi,%edx
  8009ce:	74 11                	je     8009e1 <strlcpy+0x40>
  8009d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009d4:	42                   	inc    %edx
  8009d5:	84 c9                	test   %cl,%cl
  8009d7:	75 f0                	jne    8009c9 <strlcpy+0x28>
  8009d9:	eb 06                	jmp    8009e1 <strlcpy+0x40>
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	eb 02                	jmp    8009e1 <strlcpy+0x40>
  8009df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 00 00             	movb   $0x0,(%eax)
  8009e4:	eb 02                	jmp    8009e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009e8:	29 f8                	sub    %edi,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f8:	8a 01                	mov    (%ecx),%al
  8009fa:	84 c0                	test   %al,%al
  8009fc:	74 10                	je     800a0e <strcmp+0x1f>
  8009fe:	3a 02                	cmp    (%edx),%al
  800a00:	75 0c                	jne    800a0e <strcmp+0x1f>
		p++, q++;
  800a02:	41                   	inc    %ecx
  800a03:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a04:	8a 01                	mov    (%ecx),%al
  800a06:	84 c0                	test   %al,%al
  800a08:	74 04                	je     800a0e <strcmp+0x1f>
  800a0a:	3a 02                	cmp    (%edx),%al
  800a0c:	74 f4                	je     800a02 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	29 d0                	sub    %edx,%eax
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	53                   	push   %ebx
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a25:	85 c0                	test   %eax,%eax
  800a27:	74 1b                	je     800a44 <strncmp+0x2c>
  800a29:	8a 1a                	mov    (%edx),%bl
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	74 24                	je     800a53 <strncmp+0x3b>
  800a2f:	3a 19                	cmp    (%ecx),%bl
  800a31:	75 20                	jne    800a53 <strncmp+0x3b>
  800a33:	48                   	dec    %eax
  800a34:	74 15                	je     800a4b <strncmp+0x33>
		n--, p++, q++;
  800a36:	42                   	inc    %edx
  800a37:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a38:	8a 1a                	mov    (%edx),%bl
  800a3a:	84 db                	test   %bl,%bl
  800a3c:	74 15                	je     800a53 <strncmp+0x3b>
  800a3e:	3a 19                	cmp    (%ecx),%bl
  800a40:	74 f1                	je     800a33 <strncmp+0x1b>
  800a42:	eb 0f                	jmp    800a53 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	eb 05                	jmp    800a50 <strncmp+0x38>
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a50:	5b                   	pop    %ebx
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a53:	0f b6 02             	movzbl (%edx),%eax
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	29 d0                	sub    %edx,%eax
  800a5b:	eb f3                	jmp    800a50 <strncmp+0x38>

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a66:	8a 10                	mov    (%eax),%dl
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strchr+0x27>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 06                	jne    800a76 <strchr+0x19>
  800a70:	eb 17                	jmp    800a89 <strchr+0x2c>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	74 13                	je     800a89 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a76:	40                   	inc    %eax
  800a77:	8a 10                	mov    (%eax),%dl
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	75 f5                	jne    800a72 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	eb 05                	jmp    800a89 <strchr+0x2c>
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a94:	8a 10                	mov    (%eax),%dl
  800a96:	84 d2                	test   %dl,%dl
  800a98:	74 11                	je     800aab <strfind+0x20>
		if (*s == c)
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	75 06                	jne    800aa4 <strfind+0x19>
  800a9e:	eb 0b                	jmp    800aab <strfind+0x20>
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 07                	je     800aab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	40                   	inc    %eax
  800aa5:	8a 10                	mov    (%eax),%dl
  800aa7:	84 d2                	test   %dl,%dl
  800aa9:	75 f5                	jne    800aa0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	74 30                	je     800af0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac6:	75 25                	jne    800aed <memset+0x40>
  800ac8:	f6 c1 03             	test   $0x3,%cl
  800acb:	75 20                	jne    800aed <memset+0x40>
		c &= 0xFF;
  800acd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	c1 e3 08             	shl    $0x8,%ebx
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	c1 e6 18             	shl    $0x18,%esi
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	c1 e0 10             	shl    $0x10,%eax
  800adf:	09 f0                	or     %esi,%eax
  800ae1:	09 d0                	or     %edx,%eax
  800ae3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae8:	fc                   	cld    
  800ae9:	f3 ab                	rep stos %eax,%es:(%edi)
  800aeb:	eb 03                	jmp    800af0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	fc                   	cld    
  800aee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af0:	89 f8                	mov    %edi,%eax
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b05:	39 c6                	cmp    %eax,%esi
  800b07:	73 34                	jae    800b3d <memmove+0x46>
  800b09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0c:	39 d0                	cmp    %edx,%eax
  800b0e:	73 2d                	jae    800b3d <memmove+0x46>
		s += n;
		d += n;
  800b10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	f6 c2 03             	test   $0x3,%dl
  800b16:	75 1b                	jne    800b33 <memmove+0x3c>
  800b18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1e:	75 13                	jne    800b33 <memmove+0x3c>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 0e                	jne    800b33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b25:	83 ef 04             	sub    $0x4,%edi
  800b28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2e:	fd                   	std    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb 07                	jmp    800b3a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b33:	4f                   	dec    %edi
  800b34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b37:	fd                   	std    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3a:	fc                   	cld    
  800b3b:	eb 20                	jmp    800b5d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	75 13                	jne    800b58 <memmove+0x61>
  800b45:	a8 03                	test   $0x3,%al
  800b47:	75 0f                	jne    800b58 <memmove+0x61>
  800b49:	f6 c1 03             	test   $0x3,%cl
  800b4c:	75 0a                	jne    800b58 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	fc                   	cld    
  800b54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b56:	eb 05                	jmp    800b5d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	fc                   	cld    
  800b5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b64:	ff 75 10             	pushl  0x10(%ebp)
  800b67:	ff 75 0c             	pushl  0xc(%ebp)
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 85 ff ff ff       	call   800af7 <memmove>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b83:	85 ff                	test   %edi,%edi
  800b85:	74 32                	je     800bb9 <memcmp+0x45>
		if (*s1 != *s2)
  800b87:	8a 03                	mov    (%ebx),%al
  800b89:	8a 0e                	mov    (%esi),%cl
  800b8b:	38 c8                	cmp    %cl,%al
  800b8d:	74 19                	je     800ba8 <memcmp+0x34>
  800b8f:	eb 0d                	jmp    800b9e <memcmp+0x2a>
  800b91:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b95:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b99:	42                   	inc    %edx
  800b9a:	38 c8                	cmp    %cl,%al
  800b9c:	74 10                	je     800bae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c0             	movzbl %al,%eax
  800ba1:	0f b6 c9             	movzbl %cl,%ecx
  800ba4:	29 c8                	sub    %ecx,%eax
  800ba6:	eb 16                	jmp    800bbe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	4f                   	dec    %edi
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	39 fa                	cmp    %edi,%edx
  800bb0:	75 df                	jne    800b91 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	eb 05                	jmp    800bbe <memcmp+0x4a>
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	73 12                	jae    800be4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bd5:	38 08                	cmp    %cl,(%eax)
  800bd7:	75 06                	jne    800bdf <memfind+0x1c>
  800bd9:	eb 09                	jmp    800be4 <memfind+0x21>
  800bdb:	38 08                	cmp    %cl,(%eax)
  800bdd:	74 05                	je     800be4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bdf:	40                   	inc    %eax
  800be0:	39 c2                	cmp    %eax,%edx
  800be2:	77 f7                	ja     800bdb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf2:	eb 01                	jmp    800bf5 <strtol+0xf>
		s++;
  800bf4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf5:	8a 02                	mov    (%edx),%al
  800bf7:	3c 20                	cmp    $0x20,%al
  800bf9:	74 f9                	je     800bf4 <strtol+0xe>
  800bfb:	3c 09                	cmp    $0x9,%al
  800bfd:	74 f5                	je     800bf4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bff:	3c 2b                	cmp    $0x2b,%al
  800c01:	75 08                	jne    800c0b <strtol+0x25>
		s++;
  800c03:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c04:	bf 00 00 00 00       	mov    $0x0,%edi
  800c09:	eb 13                	jmp    800c1e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0b:	3c 2d                	cmp    $0x2d,%al
  800c0d:	75 0a                	jne    800c19 <strtol+0x33>
		s++, neg = 1;
  800c0f:	8d 52 01             	lea    0x1(%edx),%edx
  800c12:	bf 01 00 00 00       	mov    $0x1,%edi
  800c17:	eb 05                	jmp    800c1e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	85 db                	test   %ebx,%ebx
  800c20:	74 05                	je     800c27 <strtol+0x41>
  800c22:	83 fb 10             	cmp    $0x10,%ebx
  800c25:	75 28                	jne    800c4f <strtol+0x69>
  800c27:	8a 02                	mov    (%edx),%al
  800c29:	3c 30                	cmp    $0x30,%al
  800c2b:	75 10                	jne    800c3d <strtol+0x57>
  800c2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c31:	75 0a                	jne    800c3d <strtol+0x57>
		s += 2, base = 16;
  800c33:	83 c2 02             	add    $0x2,%edx
  800c36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3b:	eb 12                	jmp    800c4f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 db                	test   %ebx,%ebx
  800c3f:	75 0e                	jne    800c4f <strtol+0x69>
  800c41:	3c 30                	cmp    $0x30,%al
  800c43:	75 05                	jne    800c4a <strtol+0x64>
		s++, base = 8;
  800c45:	42                   	inc    %edx
  800c46:	b3 08                	mov    $0x8,%bl
  800c48:	eb 05                	jmp    800c4f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c54:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c56:	8a 0a                	mov    (%edx),%cl
  800c58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c5b:	80 fb 09             	cmp    $0x9,%bl
  800c5e:	77 08                	ja     800c68 <strtol+0x82>
			dig = *s - '0';
  800c60:	0f be c9             	movsbl %cl,%ecx
  800c63:	83 e9 30             	sub    $0x30,%ecx
  800c66:	eb 1e                	jmp    800c86 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c6b:	80 fb 19             	cmp    $0x19,%bl
  800c6e:	77 08                	ja     800c78 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c70:	0f be c9             	movsbl %cl,%ecx
  800c73:	83 e9 57             	sub    $0x57,%ecx
  800c76:	eb 0e                	jmp    800c86 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 13                	ja     800c93 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c80:	0f be c9             	movsbl %cl,%ecx
  800c83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c86:	39 f1                	cmp    %esi,%ecx
  800c88:	7d 0d                	jge    800c97 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c8a:	42                   	inc    %edx
  800c8b:	0f af c6             	imul   %esi,%eax
  800c8e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c91:	eb c3                	jmp    800c56 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c93:	89 c1                	mov    %eax,%ecx
  800c95:	eb 02                	jmp    800c99 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c97:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9d:	74 05                	je     800ca4 <strtol+0xbe>
		*endptr = (char *) s;
  800c9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca4:	85 ff                	test   %edi,%edi
  800ca6:	74 04                	je     800cac <strtol+0xc6>
  800ca8:	89 c8                	mov    %ecx,%eax
  800caa:	f7 d8                	neg    %eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    
  800cb1:	00 00                	add    %al,(%eax)
	...

00800cb4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	83 ec 10             	sub    $0x10,%esp
  800cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cc2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	75 2e                	jne    800d00 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cd2:	39 f1                	cmp    %esi,%ecx
  800cd4:	77 5a                	ja     800d30 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cd6:	85 c9                	test   %ecx,%ecx
  800cd8:	75 0b                	jne    800ce5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cda:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdf:	31 d2                	xor    %edx,%edx
  800ce1:	f7 f1                	div    %ecx
  800ce3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ce5:	31 d2                	xor    %edx,%edx
  800ce7:	89 f0                	mov    %esi,%eax
  800ce9:	f7 f1                	div    %ecx
  800ceb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ced:	89 f8                	mov    %edi,%eax
  800cef:	f7 f1                	div    %ecx
  800cf1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf3:	89 f8                	mov    %edi,%eax
  800cf5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d00:	39 f0                	cmp    %esi,%eax
  800d02:	77 1c                	ja     800d20 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d04:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d07:	83 f7 1f             	xor    $0x1f,%edi
  800d0a:	75 3c                	jne    800d48 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d0c:	39 f0                	cmp    %esi,%eax
  800d0e:	0f 82 90 00 00 00    	jb     800da4 <__udivdi3+0xf0>
  800d14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d17:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d1a:	0f 86 84 00 00 00    	jbe    800da4 <__udivdi3+0xf0>
  800d20:	31 f6                	xor    %esi,%esi
  800d22:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	89 f8                	mov    %edi,%eax
  800d34:	f7 f1                	div    %ecx
  800d36:	89 c7                	mov    %eax,%edi
  800d38:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3a:	89 f8                	mov    %edi,%eax
  800d3c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d48:	89 f9                	mov    %edi,%ecx
  800d4a:	d3 e0                	shl    %cl,%eax
  800d4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d4f:	b8 20 00 00 00       	mov    $0x20,%eax
  800d54:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d59:	88 c1                	mov    %al,%cl
  800d5b:	d3 ea                	shr    %cl,%edx
  800d5d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d60:	09 ca                	or     %ecx,%edx
  800d62:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d68:	89 f9                	mov    %edi,%ecx
  800d6a:	d3 e2                	shl    %cl,%edx
  800d6c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d6f:	89 f2                	mov    %esi,%edx
  800d71:	88 c1                	mov    %al,%cl
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d78:	89 f2                	mov    %esi,%edx
  800d7a:	89 f9                	mov    %edi,%ecx
  800d7c:	d3 e2                	shl    %cl,%edx
  800d7e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d81:	88 c1                	mov    %al,%cl
  800d83:	d3 ee                	shr    %cl,%esi
  800d85:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d87:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d8a:	89 f0                	mov    %esi,%eax
  800d8c:	89 ca                	mov    %ecx,%edx
  800d8e:	f7 75 ec             	divl   -0x14(%ebp)
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d95:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d98:	39 d1                	cmp    %edx,%ecx
  800d9a:	72 28                	jb     800dc4 <__udivdi3+0x110>
  800d9c:	74 1a                	je     800db8 <__udivdi3+0x104>
  800d9e:	89 f7                	mov    %esi,%edi
  800da0:	31 f6                	xor    %esi,%esi
  800da2:	eb 80                	jmp    800d24 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da4:	31 f6                	xor    %esi,%esi
  800da6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	c9                   	leave  
  800db5:	c3                   	ret    
  800db6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800db8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dbb:	89 f9                	mov    %edi,%ecx
  800dbd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dbf:	39 c2                	cmp    %eax,%edx
  800dc1:	73 db                	jae    800d9e <__udivdi3+0xea>
  800dc3:	90                   	nop
		{
		  q0--;
  800dc4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc7:	31 f6                	xor    %esi,%esi
  800dc9:	e9 56 ff ff ff       	jmp    800d24 <__udivdi3+0x70>
	...

00800dd0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	83 ec 20             	sub    $0x20,%esp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dde:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800de1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800de4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800de7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ded:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800def:	85 ff                	test   %edi,%edi
  800df1:	75 15                	jne    800e08 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800df3:	39 f1                	cmp    %esi,%ecx
  800df5:	0f 86 99 00 00 00    	jbe    800e94 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dfb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800dfd:	89 d0                	mov    %edx,%eax
  800dff:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e01:	83 c4 20             	add    $0x20,%esp
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e08:	39 f7                	cmp    %esi,%edi
  800e0a:	0f 87 a4 00 00 00    	ja     800eb4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e10:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e13:	83 f0 1f             	xor    $0x1f,%eax
  800e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e19:	0f 84 a1 00 00 00    	je     800ec0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e1f:	89 f8                	mov    %edi,%eax
  800e21:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e24:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e26:	bf 20 00 00 00       	mov    $0x20,%edi
  800e2b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	d3 ea                	shr    %cl,%edx
  800e35:	09 c2                	or     %eax,%edx
  800e37:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e40:	d3 e0                	shl    %cl,%eax
  800e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e45:	89 f2                	mov    %esi,%edx
  800e47:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e4c:	d3 e0                	shl    %cl,%eax
  800e4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e51:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e54:	89 f9                	mov    %edi,%ecx
  800e56:	d3 e8                	shr    %cl,%eax
  800e58:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e5a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e5c:	89 f2                	mov    %esi,%edx
  800e5e:	f7 75 f0             	divl   -0x10(%ebp)
  800e61:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e63:	f7 65 f4             	mull   -0xc(%ebp)
  800e66:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e69:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6b:	39 d6                	cmp    %edx,%esi
  800e6d:	72 71                	jb     800ee0 <__umoddi3+0x110>
  800e6f:	74 7f                	je     800ef0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e74:	29 c8                	sub    %ecx,%eax
  800e76:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e78:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e7b:	d3 e8                	shr    %cl,%eax
  800e7d:	89 f2                	mov    %esi,%edx
  800e7f:	89 f9                	mov    %edi,%ecx
  800e81:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e83:	09 d0                	or     %edx,%eax
  800e85:	89 f2                	mov    %esi,%edx
  800e87:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e8a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    
  800e93:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e94:	85 c9                	test   %ecx,%ecx
  800e96:	75 0b                	jne    800ea3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e98:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9d:	31 d2                	xor    %edx,%edx
  800e9f:	f7 f1                	div    %ecx
  800ea1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	31 d2                	xor    %edx,%edx
  800ea7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eac:	f7 f1                	div    %ecx
  800eae:	e9 4a ff ff ff       	jmp    800dfd <__umoddi3+0x2d>
  800eb3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800eb4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb6:	83 c4 20             	add    $0x20,%esp
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec0:	39 f7                	cmp    %esi,%edi
  800ec2:	72 05                	jb     800ec9 <__umoddi3+0xf9>
  800ec4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ec7:	77 0c                	ja     800ed5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec9:	89 f2                	mov    %esi,%edx
  800ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ece:	29 c8                	sub    %ecx,%eax
  800ed0:	19 fa                	sbb    %edi,%edx
  800ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed8:	83 c4 20             	add    $0x20,%esp
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    
  800edf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ee0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ee8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800eeb:	eb 84                	jmp    800e71 <__umoddi3+0xa1>
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ef0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ef3:	72 eb                	jb     800ee0 <__umoddi3+0x110>
  800ef5:	89 f2                	mov    %esi,%edx
  800ef7:	e9 75 ff ff ff       	jmp    800e71 <__umoddi3+0xa1>
