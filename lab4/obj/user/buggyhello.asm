
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
  80003e:	e8 b6 00 00 00       	call   8000f9 <sys_cputs>
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
  800053:	e8 0d 01 00 00       	call   800165 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800064:	c1 e0 07             	shl    $0x7,%eax
  800067:	29 d0                	sub    %edx,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 07                	jle    80007e <libmain+0x36>
		binaryname = argv[0];
  800077:	8b 03                	mov    (%ebx),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	53                   	push   %ebx
  800082:	56                   	push   %esi
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	c9                   	leave  
  800096:	c3                   	ret    
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
  8000de:	68 0a 0f 80 00       	push   $0x800f0a
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 27 0f 80 00       	push   $0x800f27
  8000ea:	e8 bd 01 00 00       	call   8002ac <_panic>

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
	...

008002ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002b1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002ba:	e8 a6 fe ff ff       	call   800165 <sys_getenvid>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	53                   	push   %ebx
  8002c9:	50                   	push   %eax
  8002ca:	68 38 0f 80 00       	push   $0x800f38
  8002cf:	e8 b0 00 00 00       	call   800384 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	56                   	push   %esi
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	e8 53 00 00 00       	call   800333 <vcprintf>
	cprintf("\n");
  8002e0:	c7 04 24 5c 0f 80 00 	movl   $0x800f5c,(%esp)
  8002e7:	e8 98 00 00 00       	call   800384 <cprintf>
  8002ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ef:	cc                   	int3   
  8002f0:	eb fd                	jmp    8002ef <_panic+0x43>
	...

008002f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 04             	sub    $0x4,%esp
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fe:	8b 03                	mov    (%ebx),%eax
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800307:	40                   	inc    %eax
  800308:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030f:	75 1a                	jne    80032b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	68 ff 00 00 00       	push   $0xff
  800319:	8d 43 08             	lea    0x8(%ebx),%eax
  80031c:	50                   	push   %eax
  80031d:	e8 d7 fd ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  800322:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800328:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80032b:	ff 43 04             	incl   0x4(%ebx)
}
  80032e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80033c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800343:	00 00 00 
	b.cnt = 0;
  800346:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80034d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80035c:	50                   	push   %eax
  80035d:	68 f4 02 80 00       	push   $0x8002f4
  800362:	e8 82 01 00 00       	call   8004e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800367:	83 c4 08             	add    $0x8,%esp
  80036a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800370:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800376:	50                   	push   %eax
  800377:	e8 7d fd ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  80037c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038d:	50                   	push   %eax
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 9d ff ff ff       	call   800333 <vcprintf>
	va_end(ap);

	return cnt;
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 2c             	sub    $0x2c,%esp
  8003a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a4:	89 d6                	mov    %edx,%esi
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003c8:	72 0c                	jb     8003d6 <printnum+0x3e>
  8003ca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003cd:	76 07                	jbe    8003d6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cf:	4b                   	dec    %ebx
  8003d0:	85 db                	test   %ebx,%ebx
  8003d2:	7f 31                	jg     800405 <printnum+0x6d>
  8003d4:	eb 3f                	jmp    800415 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d6:	83 ec 0c             	sub    $0xc,%esp
  8003d9:	57                   	push   %edi
  8003da:	4b                   	dec    %ebx
  8003db:	53                   	push   %ebx
  8003dc:	50                   	push   %eax
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ec:	e8 c7 08 00 00       	call   800cb8 <__udivdi3>
  8003f1:	83 c4 18             	add    $0x18,%esp
  8003f4:	52                   	push   %edx
  8003f5:	50                   	push   %eax
  8003f6:	89 f2                	mov    %esi,%edx
  8003f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fb:	e8 98 ff ff ff       	call   800398 <printnum>
  800400:	83 c4 20             	add    $0x20,%esp
  800403:	eb 10                	jmp    800415 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	56                   	push   %esi
  800409:	57                   	push   %edi
  80040a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040d:	4b                   	dec    %ebx
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	85 db                	test   %ebx,%ebx
  800413:	7f f0                	jg     800405 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	56                   	push   %esi
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	e8 a7 09 00 00       	call   800dd4 <__umoddi3>
  80042d:	83 c4 14             	add    $0x14,%esp
  800430:	0f be 80 5e 0f 80 00 	movsbl 0x800f5e(%eax),%eax
  800437:	50                   	push   %eax
  800438:	ff 55 e4             	call   *-0x1c(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
}
  80043e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800449:	83 fa 01             	cmp    $0x1,%edx
  80044c:	7e 0e                	jle    80045c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	eb 22                	jmp    80047e <getuint+0x38>
	else if (lflag)
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 10                	je     800470 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	eb 0e                	jmp    80047e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800483:	83 fa 01             	cmp    $0x1,%edx
  800486:	7e 0e                	jle    800496 <getint+0x16>
		return va_arg(*ap, long long);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	8b 52 04             	mov    0x4(%edx),%edx
  800494:	eb 1a                	jmp    8004b0 <getint+0x30>
	else if (lflag)
  800496:	85 d2                	test   %edx,%edx
  800498:	74 0c                	je     8004a6 <getint+0x26>
		return va_arg(*ap, long);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	99                   	cltd   
  8004a4:	eb 0a                	jmp    8004b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ab:	89 08                	mov    %ecx,(%eax)
  8004ad:	8b 02                	mov    (%edx),%eax
  8004af:	99                   	cltd   
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c0:	73 08                	jae    8004ca <sprintputch+0x18>
		*b->buf++ = ch;
  8004c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c5:	88 0a                	mov    %cl,(%edx)
  8004c7:	42                   	inc    %edx
  8004c8:	89 10                	mov    %edx,(%eax)
}
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d5:	50                   	push   %eax
  8004d6:	ff 75 10             	pushl  0x10(%ebp)
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 05 00 00 00       	call   8004e9 <vprintfmt>
	va_end(ap);
  8004e4:	83 c4 10             	add    $0x10,%esp
}
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    

008004e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	53                   	push   %ebx
  8004ef:	83 ec 2c             	sub    $0x2c,%esp
  8004f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f8:	eb 13                	jmp    80050d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	0f 84 6d 03 00 00    	je     80086f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	57                   	push   %edi
  800506:	50                   	push   %eax
  800507:	ff 55 08             	call   *0x8(%ebp)
  80050a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050d:	0f b6 06             	movzbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	83 f8 25             	cmp    $0x25,%eax
  800514:	75 e4                	jne    8004fa <vprintfmt+0x11>
  800516:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80051a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800521:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800528:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800534:	eb 28                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800538:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80053c:	eb 20                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800540:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800544:	eb 18                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800548:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054f:	eb 0d                	jmp    80055e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800551:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800557:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8a 06                	mov    (%esi),%al
  800560:	0f b6 d0             	movzbl %al,%edx
  800563:	8d 5e 01             	lea    0x1(%esi),%ebx
  800566:	83 e8 23             	sub    $0x23,%eax
  800569:	3c 55                	cmp    $0x55,%al
  80056b:	0f 87 e0 02 00 00    	ja     800851 <vprintfmt+0x368>
  800571:	0f b6 c0             	movzbl %al,%eax
  800574:	ff 24 85 20 10 80 00 	jmp    *0x801020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057b:	83 ea 30             	sub    $0x30,%edx
  80057e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800581:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800584:	8d 50 d0             	lea    -0x30(%eax),%edx
  800587:	83 fa 09             	cmp    $0x9,%edx
  80058a:	77 44                	ja     8005d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	89 de                	mov    %ebx,%esi
  80058e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800591:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800592:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800595:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800599:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059f:	83 fb 09             	cmp    $0x9,%ebx
  8005a2:	76 ed                	jbe    800591 <vprintfmt+0xa8>
  8005a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a7:	eb 29                	jmp    8005d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b9:	eb 17                	jmp    8005d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bf:	78 85                	js     800546 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	89 de                	mov    %ebx,%esi
  8005c3:	eb 99                	jmp    80055e <vprintfmt+0x75>
  8005c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ce:	eb 8e                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	79 86                	jns    80055e <vprintfmt+0x75>
  8005d8:	e9 74 ff ff ff       	jmp    800551 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	89 de                	mov    %ebx,%esi
  8005e0:	e9 79 ff ff ff       	jmp    80055e <vprintfmt+0x75>
  8005e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	ff 30                	pushl  (%eax)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800600:	e9 08 ff ff ff       	jmp    80050d <vprintfmt+0x24>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	79 02                	jns    800619 <vprintfmt+0x130>
  800617:	f7 d8                	neg    %eax
  800619:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061b:	83 f8 08             	cmp    $0x8,%eax
  80061e:	7f 0b                	jg     80062b <vprintfmt+0x142>
  800620:	8b 04 85 80 11 80 00 	mov    0x801180(,%eax,4),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	75 1a                	jne    800645 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80062b:	52                   	push   %edx
  80062c:	68 76 0f 80 00       	push   $0x800f76
  800631:	57                   	push   %edi
  800632:	ff 75 08             	pushl  0x8(%ebp)
  800635:	e8 92 fe ff ff       	call   8004cc <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800640:	e9 c8 fe ff ff       	jmp    80050d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800645:	50                   	push   %eax
  800646:	68 7f 0f 80 00       	push   $0x800f7f
  80064b:	57                   	push   %edi
  80064c:	ff 75 08             	pushl  0x8(%ebp)
  80064f:	e8 78 fe ff ff       	call   8004cc <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065a:	e9 ae fe ff ff       	jmp    80050d <vprintfmt+0x24>
  80065f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800662:	89 de                	mov    %ebx,%esi
  800664:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800678:	85 c0                	test   %eax,%eax
  80067a:	75 07                	jne    800683 <vprintfmt+0x19a>
				p = "(null)";
  80067c:	c7 45 d0 6f 0f 80 00 	movl   $0x800f6f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800683:	85 db                	test   %ebx,%ebx
  800685:	7e 42                	jle    8006c9 <vprintfmt+0x1e0>
  800687:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80068b:	74 3c                	je     8006c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	51                   	push   %ecx
  800691:	ff 75 d0             	pushl  -0x30(%ebp)
  800694:	e8 6f 02 00 00       	call   800908 <strnlen>
  800699:	29 c3                	sub    %eax,%ebx
  80069b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 db                	test   %ebx,%ebx
  8006a3:	7e 24                	jle    8006c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	57                   	push   %edi
  8006b3:	53                   	push   %ebx
  8006b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	4e                   	dec    %esi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 f6                	test   %esi,%esi
  8006bd:	7f f0                	jg     8006af <vprintfmt+0x1c6>
  8006bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cc:	0f be 02             	movsbl (%edx),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	75 47                	jne    80071a <vprintfmt+0x231>
  8006d3:	eb 37                	jmp    80070c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	74 16                	je     8006f1 <vprintfmt+0x208>
  8006db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006de:	83 fa 5e             	cmp    $0x5e,%edx
  8006e1:	76 0e                	jbe    8006f1 <vprintfmt+0x208>
					putch('?', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	57                   	push   %edi
  8006e7:	6a 3f                	push   $0x3f
  8006e9:	ff 55 08             	call   *0x8(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 0b                	jmp    8006fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	57                   	push   %edi
  8006f5:	50                   	push   %eax
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8006ff:	0f be 03             	movsbl (%ebx),%eax
  800702:	85 c0                	test   %eax,%eax
  800704:	74 03                	je     800709 <vprintfmt+0x220>
  800706:	43                   	inc    %ebx
  800707:	eb 1b                	jmp    800724 <vprintfmt+0x23b>
  800709:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800710:	7f 1e                	jg     800730 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800715:	e9 f3 fd ff ff       	jmp    80050d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071d:	43                   	inc    %ebx
  80071e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800721:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800724:	85 f6                	test   %esi,%esi
  800726:	78 ad                	js     8006d5 <vprintfmt+0x1ec>
  800728:	4e                   	dec    %esi
  800729:	79 aa                	jns    8006d5 <vprintfmt+0x1ec>
  80072b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80072e:	eb dc                	jmp    80070c <vprintfmt+0x223>
  800730:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	57                   	push   %edi
  800737:	6a 20                	push   $0x20
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073c:	4b                   	dec    %ebx
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	85 db                	test   %ebx,%ebx
  800742:	7f ef                	jg     800733 <vprintfmt+0x24a>
  800744:	e9 c4 fd ff ff       	jmp    80050d <vprintfmt+0x24>
  800749:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074c:	89 ca                	mov    %ecx,%edx
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 2a fd ff ff       	call   800480 <getint>
  800756:	89 c3                	mov    %eax,%ebx
  800758:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80075a:	85 d2                	test   %edx,%edx
  80075c:	78 0a                	js     800768 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800763:	e9 b0 00 00 00       	jmp    800818 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	57                   	push   %edi
  80076c:	6a 2d                	push   $0x2d
  80076e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800771:	f7 db                	neg    %ebx
  800773:	83 d6 00             	adc    $0x0,%esi
  800776:	f7 de                	neg    %esi
  800778:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800780:	e9 93 00 00 00       	jmp    800818 <vprintfmt+0x32f>
  800785:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 b4 fc ff ff       	call   800446 <getuint>
  800792:	89 c3                	mov    %eax,%ebx
  800794:	89 d6                	mov    %edx,%esi
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80079b:	eb 7b                	jmp    800818 <vprintfmt+0x32f>
  80079d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 d6 fc ff ff       	call   800480 <getint>
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	78 07                	js     8007b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b7:	eb 5f                	jmp    800818 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	57                   	push   %edi
  8007bd:	6a 2d                	push   $0x2d
  8007bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007c2:	f7 db                	neg    %ebx
  8007c4:	83 d6 00             	adc    $0x0,%esi
  8007c7:	f7 de                	neg    %esi
  8007c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d1:	eb 45                	jmp    800818 <vprintfmt+0x32f>
  8007d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	57                   	push   %edi
  8007da:	6a 30                	push   $0x30
  8007dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007df:	83 c4 08             	add    $0x8,%esp
  8007e2:	57                   	push   %edi
  8007e3:	6a 78                	push   $0x78
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f1:	8b 18                	mov    (%eax),%ebx
  8007f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800800:	eb 16                	jmp    800818 <vprintfmt+0x32f>
  800802:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800805:	89 ca                	mov    %ecx,%edx
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
  80080a:	e8 37 fc ff ff       	call   800446 <getuint>
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	89 d6                	mov    %edx,%esi
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800818:	83 ec 0c             	sub    $0xc,%esp
  80081b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80081f:	52                   	push   %edx
  800820:	ff 75 e4             	pushl  -0x1c(%ebp)
  800823:	50                   	push   %eax
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	89 fa                	mov    %edi,%edx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	e8 68 fb ff ff       	call   800398 <printnum>
			break;
  800830:	83 c4 20             	add    $0x20,%esp
  800833:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800836:	e9 d2 fc ff ff       	jmp    80050d <vprintfmt+0x24>
  80083b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	57                   	push   %edi
  800842:	52                   	push   %edx
  800843:	ff 55 08             	call   *0x8(%ebp)
			break;
  800846:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084c:	e9 bc fc ff ff       	jmp    80050d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	57                   	push   %edi
  800855:	6a 25                	push   $0x25
  800857:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	eb 02                	jmp    800861 <vprintfmt+0x378>
  80085f:	89 c6                	mov    %eax,%esi
  800861:	8d 46 ff             	lea    -0x1(%esi),%eax
  800864:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800868:	75 f5                	jne    80085f <vprintfmt+0x376>
  80086a:	e9 9e fc ff ff       	jmp    80050d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800886:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800894:	85 c0                	test   %eax,%eax
  800896:	74 26                	je     8008be <vsnprintf+0x47>
  800898:	85 d2                	test   %edx,%edx
  80089a:	7e 29                	jle    8008c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	ff 75 14             	pushl  0x14(%ebp)
  80089f:	ff 75 10             	pushl  0x10(%ebp)
  8008a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	68 b2 04 80 00       	push   $0x8004b2
  8008ab:	e8 39 fc ff ff       	call   8004e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 0c                	jmp    8008ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c3:	eb 05                	jmp    8008ca <vsnprintf+0x53>
  8008c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d5:	50                   	push   %eax
  8008d6:	ff 75 10             	pushl  0x10(%ebp)
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 93 ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
	...

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	80 3a 00             	cmpb   $0x0,(%edx)
  8008f1:	74 0e                	je     800901 <strlen+0x19>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fd:	75 f9                	jne    8008f8 <strlen+0x10>
  8008ff:	eb 05                	jmp    800906 <strlen+0x1e>
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	85 d2                	test   %edx,%edx
  800913:	74 17                	je     80092c <strnlen+0x24>
  800915:	80 39 00             	cmpb   $0x0,(%ecx)
  800918:	74 19                	je     800933 <strnlen+0x2b>
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800920:	39 d0                	cmp    %edx,%eax
  800922:	74 14                	je     800938 <strnlen+0x30>
  800924:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800928:	75 f5                	jne    80091f <strnlen+0x17>
  80092a:	eb 0c                	jmp    800938 <strnlen+0x30>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strnlen+0x30>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
  800949:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80094c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80094f:	42                   	inc    %edx
  800950:	84 c9                	test   %cl,%cl
  800952:	75 f5                	jne    800949 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095e:	53                   	push   %ebx
  80095f:	e8 84 ff ff ff       	call   8008e8 <strlen>
  800964:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80096d:	50                   	push   %eax
  80096e:	e8 c7 ff ff ff       	call   80093a <strcpy>
	return dst;
}
  800973:	89 d8                	mov    %ebx,%eax
  800975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800988:	85 f6                	test   %esi,%esi
  80098a:	74 15                	je     8009a1 <strncpy+0x27>
  80098c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800991:	8a 1a                	mov    (%edx),%bl
  800993:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800996:	80 3a 01             	cmpb   $0x1,(%edx)
  800999:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	41                   	inc    %ecx
  80099d:	39 ce                	cmp    %ecx,%esi
  80099f:	77 f0                	ja     800991 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 32                	je     8009ea <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009b8:	83 fe 01             	cmp    $0x1,%esi
  8009bb:	74 22                	je     8009df <strlcpy+0x3a>
  8009bd:	8a 0b                	mov    (%ebx),%cl
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	74 20                	je     8009e3 <strlcpy+0x3e>
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009ca:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cd:	88 08                	mov    %cl,(%eax)
  8009cf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d0:	39 f2                	cmp    %esi,%edx
  8009d2:	74 11                	je     8009e5 <strlcpy+0x40>
  8009d4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009d8:	42                   	inc    %edx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	75 f0                	jne    8009cd <strlcpy+0x28>
  8009dd:	eb 06                	jmp    8009e5 <strlcpy+0x40>
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	eb 02                	jmp    8009e5 <strlcpy+0x40>
  8009e3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e5:	c6 00 00             	movb   $0x0,(%eax)
  8009e8:	eb 02                	jmp    8009ec <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ea:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009ec:	29 f8                	sub    %edi,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fc:	8a 01                	mov    (%ecx),%al
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 10                	je     800a12 <strcmp+0x1f>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	75 0c                	jne    800a12 <strcmp+0x1f>
		p++, q++;
  800a06:	41                   	inc    %ecx
  800a07:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a08:	8a 01                	mov    (%ecx),%al
  800a0a:	84 c0                	test   %al,%al
  800a0c:	74 04                	je     800a12 <strcmp+0x1f>
  800a0e:	3a 02                	cmp    (%edx),%al
  800a10:	74 f4                	je     800a06 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a12:	0f b6 c0             	movzbl %al,%eax
  800a15:	0f b6 12             	movzbl (%edx),%edx
  800a18:	29 d0                	sub    %edx,%eax
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	53                   	push   %ebx
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a26:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	74 1b                	je     800a48 <strncmp+0x2c>
  800a2d:	8a 1a                	mov    (%edx),%bl
  800a2f:	84 db                	test   %bl,%bl
  800a31:	74 24                	je     800a57 <strncmp+0x3b>
  800a33:	3a 19                	cmp    (%ecx),%bl
  800a35:	75 20                	jne    800a57 <strncmp+0x3b>
  800a37:	48                   	dec    %eax
  800a38:	74 15                	je     800a4f <strncmp+0x33>
		n--, p++, q++;
  800a3a:	42                   	inc    %edx
  800a3b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3c:	8a 1a                	mov    (%edx),%bl
  800a3e:	84 db                	test   %bl,%bl
  800a40:	74 15                	je     800a57 <strncmp+0x3b>
  800a42:	3a 19                	cmp    (%ecx),%bl
  800a44:	74 f1                	je     800a37 <strncmp+0x1b>
  800a46:	eb 0f                	jmp    800a57 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	eb 05                	jmp    800a54 <strncmp+0x38>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a54:	5b                   	pop    %ebx
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a57:	0f b6 02             	movzbl (%edx),%eax
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	29 d0                	sub    %edx,%eax
  800a5f:	eb f3                	jmp    800a54 <strncmp+0x38>

00800a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6a:	8a 10                	mov    (%eax),%dl
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	74 18                	je     800a88 <strchr+0x27>
		if (*s == c)
  800a70:	38 ca                	cmp    %cl,%dl
  800a72:	75 06                	jne    800a7a <strchr+0x19>
  800a74:	eb 17                	jmp    800a8d <strchr+0x2c>
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 13                	je     800a8d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	40                   	inc    %eax
  800a7b:	8a 10                	mov    (%eax),%dl
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f5                	jne    800a76 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	eb 05                	jmp    800a8d <strchr+0x2c>
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a98:	8a 10                	mov    (%eax),%dl
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	74 11                	je     800aaf <strfind+0x20>
		if (*s == c)
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	75 06                	jne    800aa8 <strfind+0x19>
  800aa2:	eb 0b                	jmp    800aaf <strfind+0x20>
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 07                	je     800aaf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	40                   	inc    %eax
  800aa9:	8a 10                	mov    (%eax),%dl
  800aab:	84 d2                	test   %dl,%dl
  800aad:	75 f5                	jne    800aa4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 30                	je     800af4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 25                	jne    800af1 <memset+0x40>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 20                	jne    800af1 <memset+0x40>
		c &= 0xFF;
  800ad1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	c1 e3 08             	shl    $0x8,%ebx
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	c1 e6 18             	shl    $0x18,%esi
  800ade:	89 d0                	mov    %edx,%eax
  800ae0:	c1 e0 10             	shl    $0x10,%eax
  800ae3:	09 f0                	or     %esi,%eax
  800ae5:	09 d0                	or     %edx,%eax
  800ae7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aec:	fc                   	cld    
  800aed:	f3 ab                	rep stos %eax,%es:(%edi)
  800aef:	eb 03                	jmp    800af4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af1:	fc                   	cld    
  800af2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af4:	89 f8                	mov    %edi,%eax
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b09:	39 c6                	cmp    %eax,%esi
  800b0b:	73 34                	jae    800b41 <memmove+0x46>
  800b0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b10:	39 d0                	cmp    %edx,%eax
  800b12:	73 2d                	jae    800b41 <memmove+0x46>
		s += n;
		d += n;
  800b14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	f6 c2 03             	test   $0x3,%dl
  800b1a:	75 1b                	jne    800b37 <memmove+0x3c>
  800b1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b22:	75 13                	jne    800b37 <memmove+0x3c>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0e                	jne    800b37 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b29:	83 ef 04             	sub    $0x4,%edi
  800b2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b32:	fd                   	std    
  800b33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b35:	eb 07                	jmp    800b3e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b37:	4f                   	dec    %edi
  800b38:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3b:	fd                   	std    
  800b3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3e:	fc                   	cld    
  800b3f:	eb 20                	jmp    800b61 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b47:	75 13                	jne    800b5c <memmove+0x61>
  800b49:	a8 03                	test   $0x3,%al
  800b4b:	75 0f                	jne    800b5c <memmove+0x61>
  800b4d:	f6 c1 03             	test   $0x3,%cl
  800b50:	75 0a                	jne    800b5c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b52:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	fc                   	cld    
  800b58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5a:	eb 05                	jmp    800b61 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b68:	ff 75 10             	pushl  0x10(%ebp)
  800b6b:	ff 75 0c             	pushl  0xc(%ebp)
  800b6e:	ff 75 08             	pushl  0x8(%ebp)
  800b71:	e8 85 ff ff ff       	call   800afb <memmove>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b84:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b87:	85 ff                	test   %edi,%edi
  800b89:	74 32                	je     800bbd <memcmp+0x45>
		if (*s1 != *s2)
  800b8b:	8a 03                	mov    (%ebx),%al
  800b8d:	8a 0e                	mov    (%esi),%cl
  800b8f:	38 c8                	cmp    %cl,%al
  800b91:	74 19                	je     800bac <memcmp+0x34>
  800b93:	eb 0d                	jmp    800ba2 <memcmp+0x2a>
  800b95:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b99:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b9d:	42                   	inc    %edx
  800b9e:	38 c8                	cmp    %cl,%al
  800ba0:	74 10                	je     800bb2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800ba2:	0f b6 c0             	movzbl %al,%eax
  800ba5:	0f b6 c9             	movzbl %cl,%ecx
  800ba8:	29 c8                	sub    %ecx,%eax
  800baa:	eb 16                	jmp    800bc2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bac:	4f                   	dec    %edi
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	39 fa                	cmp    %edi,%edx
  800bb4:	75 df                	jne    800b95 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 05                	jmp    800bc2 <memcmp+0x4a>
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd2:	39 d0                	cmp    %edx,%eax
  800bd4:	73 12                	jae    800be8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bd9:	38 08                	cmp    %cl,(%eax)
  800bdb:	75 06                	jne    800be3 <memfind+0x1c>
  800bdd:	eb 09                	jmp    800be8 <memfind+0x21>
  800bdf:	38 08                	cmp    %cl,(%eax)
  800be1:	74 05                	je     800be8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be3:	40                   	inc    %eax
  800be4:	39 c2                	cmp    %eax,%edx
  800be6:	77 f7                	ja     800bdf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf6:	eb 01                	jmp    800bf9 <strtol+0xf>
		s++;
  800bf8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf9:	8a 02                	mov    (%edx),%al
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f9                	je     800bf8 <strtol+0xe>
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f5                	je     800bf8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 08                	jne    800c0f <strtol+0x25>
		s++;
  800c07:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0d:	eb 13                	jmp    800c22 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0f:	3c 2d                	cmp    $0x2d,%al
  800c11:	75 0a                	jne    800c1d <strtol+0x33>
		s++, neg = 1;
  800c13:	8d 52 01             	lea    0x1(%edx),%edx
  800c16:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1b:	eb 05                	jmp    800c22 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c22:	85 db                	test   %ebx,%ebx
  800c24:	74 05                	je     800c2b <strtol+0x41>
  800c26:	83 fb 10             	cmp    $0x10,%ebx
  800c29:	75 28                	jne    800c53 <strtol+0x69>
  800c2b:	8a 02                	mov    (%edx),%al
  800c2d:	3c 30                	cmp    $0x30,%al
  800c2f:	75 10                	jne    800c41 <strtol+0x57>
  800c31:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c35:	75 0a                	jne    800c41 <strtol+0x57>
		s += 2, base = 16;
  800c37:	83 c2 02             	add    $0x2,%edx
  800c3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3f:	eb 12                	jmp    800c53 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c41:	85 db                	test   %ebx,%ebx
  800c43:	75 0e                	jne    800c53 <strtol+0x69>
  800c45:	3c 30                	cmp    $0x30,%al
  800c47:	75 05                	jne    800c4e <strtol+0x64>
		s++, base = 8;
  800c49:	42                   	inc    %edx
  800c4a:	b3 08                	mov    $0x8,%bl
  800c4c:	eb 05                	jmp    800c53 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
  800c58:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5a:	8a 0a                	mov    (%edx),%cl
  800c5c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c5f:	80 fb 09             	cmp    $0x9,%bl
  800c62:	77 08                	ja     800c6c <strtol+0x82>
			dig = *s - '0';
  800c64:	0f be c9             	movsbl %cl,%ecx
  800c67:	83 e9 30             	sub    $0x30,%ecx
  800c6a:	eb 1e                	jmp    800c8a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c6c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c6f:	80 fb 19             	cmp    $0x19,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x92>
			dig = *s - 'a' + 10;
  800c74:	0f be c9             	movsbl %cl,%ecx
  800c77:	83 e9 57             	sub    $0x57,%ecx
  800c7a:	eb 0e                	jmp    800c8a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c7c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 13                	ja     800c97 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8a:	39 f1                	cmp    %esi,%ecx
  800c8c:	7d 0d                	jge    800c9b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c8e:	42                   	inc    %edx
  800c8f:	0f af c6             	imul   %esi,%eax
  800c92:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c95:	eb c3                	jmp    800c5a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c97:	89 c1                	mov    %eax,%ecx
  800c99:	eb 02                	jmp    800c9d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca1:	74 05                	je     800ca8 <strtol+0xbe>
		*endptr = (char *) s;
  800ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	74 04                	je     800cb0 <strtol+0xc6>
  800cac:	89 c8                	mov    %ecx,%eax
  800cae:	f7 d8                	neg    %eax
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    
  800cb5:	00 00                	add    %al,(%eax)
	...

00800cb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	83 ec 10             	sub    $0x10,%esp
  800cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cc6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800cc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ccc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ccf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	75 2e                	jne    800d04 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cd6:	39 f1                	cmp    %esi,%ecx
  800cd8:	77 5a                	ja     800d34 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cda:	85 c9                	test   %ecx,%ecx
  800cdc:	75 0b                	jne    800ce9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cde:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce3:	31 d2                	xor    %edx,%edx
  800ce5:	f7 f1                	div    %ecx
  800ce7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ce9:	31 d2                	xor    %edx,%edx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	f7 f1                	div    %ecx
  800cef:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf1:	89 f8                	mov    %edi,%eax
  800cf3:	f7 f1                	div    %ecx
  800cf5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf7:	89 f8                	mov    %edi,%eax
  800cf9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    
  800d02:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d04:	39 f0                	cmp    %esi,%eax
  800d06:	77 1c                	ja     800d24 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d08:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d0b:	83 f7 1f             	xor    $0x1f,%edi
  800d0e:	75 3c                	jne    800d4c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d10:	39 f0                	cmp    %esi,%eax
  800d12:	0f 82 90 00 00 00    	jb     800da8 <__udivdi3+0xf0>
  800d18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d1b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d1e:	0f 86 84 00 00 00    	jbe    800da8 <__udivdi3+0xf0>
  800d24:	31 f6                	xor    %esi,%esi
  800d26:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d28:	89 f8                	mov    %edi,%eax
  800d2a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    
  800d33:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	89 f8                	mov    %edi,%eax
  800d38:	f7 f1                	div    %ecx
  800d3a:	89 c7                	mov    %eax,%edi
  800d3c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3e:	89 f8                	mov    %edi,%eax
  800d40:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d42:	83 c4 10             	add    $0x10,%esp
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    
  800d49:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d4c:	89 f9                	mov    %edi,%ecx
  800d4e:	d3 e0                	shl    %cl,%eax
  800d50:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d53:	b8 20 00 00 00       	mov    $0x20,%eax
  800d58:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d5d:	88 c1                	mov    %al,%cl
  800d5f:	d3 ea                	shr    %cl,%edx
  800d61:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d64:	09 ca                	or     %ecx,%edx
  800d66:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6c:	89 f9                	mov    %edi,%ecx
  800d6e:	d3 e2                	shl    %cl,%edx
  800d70:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d73:	89 f2                	mov    %esi,%edx
  800d75:	88 c1                	mov    %al,%cl
  800d77:	d3 ea                	shr    %cl,%edx
  800d79:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d7c:	89 f2                	mov    %esi,%edx
  800d7e:	89 f9                	mov    %edi,%ecx
  800d80:	d3 e2                	shl    %cl,%edx
  800d82:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d85:	88 c1                	mov    %al,%cl
  800d87:	d3 ee                	shr    %cl,%esi
  800d89:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d8b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d8e:	89 f0                	mov    %esi,%eax
  800d90:	89 ca                	mov    %ecx,%edx
  800d92:	f7 75 ec             	divl   -0x14(%ebp)
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d99:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d9c:	39 d1                	cmp    %edx,%ecx
  800d9e:	72 28                	jb     800dc8 <__udivdi3+0x110>
  800da0:	74 1a                	je     800dbc <__udivdi3+0x104>
  800da2:	89 f7                	mov    %esi,%edi
  800da4:	31 f6                	xor    %esi,%esi
  800da6:	eb 80                	jmp    800d28 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da8:	31 f6                	xor    %esi,%esi
  800daa:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    
  800dba:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dbf:	89 f9                	mov    %edi,%ecx
  800dc1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc3:	39 c2                	cmp    %eax,%edx
  800dc5:	73 db                	jae    800da2 <__udivdi3+0xea>
  800dc7:	90                   	nop
		{
		  q0--;
  800dc8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dcb:	31 f6                	xor    %esi,%esi
  800dcd:	e9 56 ff ff ff       	jmp    800d28 <__udivdi3+0x70>
	...

00800dd4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	83 ec 20             	sub    $0x20,%esp
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800de8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800deb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800df1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df3:	85 ff                	test   %edi,%edi
  800df5:	75 15                	jne    800e0c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800df7:	39 f1                	cmp    %esi,%ecx
  800df9:	0f 86 99 00 00 00    	jbe    800e98 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dff:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e01:	89 d0                	mov    %edx,%eax
  800e03:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e05:	83 c4 20             	add    $0x20,%esp
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e0c:	39 f7                	cmp    %esi,%edi
  800e0e:	0f 87 a4 00 00 00    	ja     800eb8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e14:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e17:	83 f0 1f             	xor    $0x1f,%eax
  800e1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e1d:	0f 84 a1 00 00 00    	je     800ec4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e23:	89 f8                	mov    %edi,%eax
  800e25:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e28:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e2a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e2f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 ea                	shr    %cl,%edx
  800e39:	09 c2                	or     %eax,%edx
  800e3b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e44:	d3 e0                	shl    %cl,%eax
  800e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e49:	89 f2                	mov    %esi,%edx
  800e4b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e50:	d3 e0                	shl    %cl,%eax
  800e52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e58:	89 f9                	mov    %edi,%ecx
  800e5a:	d3 e8                	shr    %cl,%eax
  800e5c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e5e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e60:	89 f2                	mov    %esi,%edx
  800e62:	f7 75 f0             	divl   -0x10(%ebp)
  800e65:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e67:	f7 65 f4             	mull   -0xc(%ebp)
  800e6a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e6d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6f:	39 d6                	cmp    %edx,%esi
  800e71:	72 71                	jb     800ee4 <__umoddi3+0x110>
  800e73:	74 7f                	je     800ef4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e78:	29 c8                	sub    %ecx,%eax
  800e7a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e7c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e7f:	d3 e8                	shr    %cl,%eax
  800e81:	89 f2                	mov    %esi,%edx
  800e83:	89 f9                	mov    %edi,%ecx
  800e85:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e87:	09 d0                	or     %edx,%eax
  800e89:	89 f2                	mov    %esi,%edx
  800e8b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e8e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e90:	83 c4 20             	add    $0x20,%esp
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    
  800e97:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e98:	85 c9                	test   %ecx,%ecx
  800e9a:	75 0b                	jne    800ea7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	f7 f1                	div    %ecx
  800ea5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	31 d2                	xor    %edx,%edx
  800eab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb0:	f7 f1                	div    %ecx
  800eb2:	e9 4a ff ff ff       	jmp    800e01 <__umoddi3+0x2d>
  800eb7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800eb8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eba:	83 c4 20             	add    $0x20,%esp
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    
  800ec1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec4:	39 f7                	cmp    %esi,%edi
  800ec6:	72 05                	jb     800ecd <__umoddi3+0xf9>
  800ec8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ecb:	77 0c                	ja     800ed9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ecd:	89 f2                	mov    %esi,%edx
  800ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed2:	29 c8                	sub    %ecx,%eax
  800ed4:	19 fa                	sbb    %edi,%edx
  800ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ee4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800eec:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800eef:	eb 84                	jmp    800e75 <__umoddi3+0xa1>
  800ef1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ef4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ef7:	72 eb                	jb     800ee4 <__umoddi3+0x110>
  800ef9:	89 f2                	mov    %esi,%edx
  800efb:	e9 75 ff ff ff       	jmp    800e75 <__umoddi3+0xa1>
