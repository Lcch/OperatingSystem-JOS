
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 db 00 00 00       	call   80010c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	68 e0 20 80 00       	push   $0x8020e0
  80003f:	e8 c4 01 00 00       	call   800208 <cprintf>
	exit();
  800044:	e8 13 01 00 00       	call   80015c <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void
umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80005a:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800060:	50                   	push   %eax
  800061:	ff 75 0c             	pushl  0xc(%ebp)
  800064:	8d 45 08             	lea    0x8(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	e8 3b 0d 00 00       	call   800da8 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006d:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800070:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800075:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007b:	eb 11                	jmp    80008e <umain+0x40>
		if (i == '1')
  80007d:	83 f8 31             	cmp    $0x31,%eax
  800080:	74 07                	je     800089 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800082:	e8 ad ff ff ff       	call   800034 <usage>
  800087:	eb 05                	jmp    80008e <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800089:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	53                   	push   %ebx
  800092:	e8 4a 0d 00 00       	call   800de1 <argnext>
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 df                	jns    80007d <umain+0x2f>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a3:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	e8 73 13 00 00       	call   801426 <fstat>
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 44                	js     8000fe <umain+0xb0>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 22                	je     8000e0 <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000be:	83 ec 04             	sub    $0x4,%esp
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c4:	ff 70 04             	pushl  0x4(%eax)
  8000c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8000ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	68 f4 20 80 00       	push   $0x8020f4
  8000d4:	6a 01                	push   $0x1
  8000d6:	e8 be 16 00 00       	call   801799 <fprintf>
  8000db:	83 c4 20             	add    $0x20,%esp
  8000de:	eb 1e                	jmp    8000fe <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000e0:	83 ec 08             	sub    $0x8,%esp
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000e6:	ff 70 04             	pushl  0x4(%eax)
  8000e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8000ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	68 f4 20 80 00       	push   $0x8020f4
  8000f6:	e8 0d 01 00 00       	call   800208 <cprintf>
  8000fb:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fe:	43                   	inc    %ebx
  8000ff:	83 fb 20             	cmp    $0x20,%ebx
  800102:	75 a5                	jne    8000a9 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	8b 75 08             	mov    0x8(%ebp),%esi
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800117:	e8 d9 0a 00 00       	call   800bf5 <sys_getenvid>
  80011c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800121:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800128:	c1 e0 07             	shl    $0x7,%eax
  80012b:	29 d0                	sub    %edx,%eax
  80012d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800132:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800137:	85 f6                	test   %esi,%esi
  800139:	7e 07                	jle    800142 <libmain+0x36>
		binaryname = argv[0];
  80013b:	8b 03                	mov    (%ebx),%eax
  80013d:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	53                   	push   %ebx
  800146:	56                   	push   %esi
  800147:	e8 02 ff ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  80014c:	e8 0b 00 00 00       	call   80015c <exit>
  800151:	83 c4 10             	add    $0x10,%esp
}
  800154:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	c9                   	leave  
  80015a:	c3                   	ret    
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800162:	e8 a7 0f 00 00       	call   80110e <close_all>
	sys_env_destroy(0);
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	6a 00                	push   $0x0
  80016c:	e8 62 0a 00 00       	call   800bd3 <sys_env_destroy>
  800171:	83 c4 10             	add    $0x10,%esp
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    
	...

00800178 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 03                	mov    (%ebx),%eax
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018b:	40                   	inc    %eax
  80018c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800193:	75 1a                	jne    8001af <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	68 ff 00 00 00       	push   $0xff
  80019d:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a0:	50                   	push   %eax
  8001a1:	e8 e3 09 00 00       	call   800b89 <sys_cputs>
		b->idx = 0;
  8001a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001af:	ff 43 04             	incl   0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 78 01 80 00       	push   $0x800178
  8001e6:	e8 82 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 89 09 00 00       	call   800b89 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	89 d6                	mov    %edx,%esi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800230:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800233:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800242:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800249:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80024c:	72 0c                	jb     80025a <printnum+0x3e>
  80024e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800251:	76 07                	jbe    80025a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800253:	4b                   	dec    %ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7f 31                	jg     800289 <printnum+0x6d>
  800258:	eb 3f                	jmp    800299 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	57                   	push   %edi
  80025e:	4b                   	dec    %ebx
  80025f:	53                   	push   %ebx
  800260:	50                   	push   %eax
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 d4             	pushl  -0x2c(%ebp)
  800267:	ff 75 d0             	pushl  -0x30(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 0b 1c 00 00       	call   801e80 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027f:	e8 98 ff ff ff       	call   80021c <printnum>
  800284:	83 c4 20             	add    $0x20,%esp
  800287:	eb 10                	jmp    800299 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	57                   	push   %edi
  80028e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	4b                   	dec    %ebx
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	85 db                	test   %ebx,%ebx
  800297:	7f f0                	jg     800289 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	83 ec 04             	sub    $0x4,%esp
  8002a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ac:	e8 eb 1c 00 00       	call   801f9c <__umoddi3>
  8002b1:	83 c4 14             	add    $0x14,%esp
  8002b4:	0f be 80 26 21 80 00 	movsbl 0x802126(%eax),%eax
  8002bb:	50                   	push   %eax
  8002bc:	ff 55 e4             	call   *-0x1c(%ebp)
  8002bf:	83 c4 10             	add    $0x10,%esp
}
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cd:	83 fa 01             	cmp    $0x1,%edx
  8002d0:	7e 0e                	jle    8002e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	8b 52 04             	mov    0x4(%edx),%edx
  8002de:	eb 22                	jmp    800302 <getuint+0x38>
	else if (lflag)
  8002e0:	85 d2                	test   %edx,%edx
  8002e2:	74 10                	je     8002f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 0e                	jmp    800302 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800307:	83 fa 01             	cmp    $0x1,%edx
  80030a:	7e 0e                	jle    80031a <getint+0x16>
		return va_arg(*ap, long long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	8b 52 04             	mov    0x4(%edx),%edx
  800318:	eb 1a                	jmp    800334 <getint+0x30>
	else if (lflag)
  80031a:	85 d2                	test   %edx,%edx
  80031c:	74 0c                	je     80032a <getint+0x26>
		return va_arg(*ap, long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	99                   	cltd   
  800328:	eb 0a                	jmp    800334 <getint+0x30>
	else
		return va_arg(*ap, int);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	99                   	cltd   
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 08                	jae    80034e <sprintputch+0x18>
		*b->buf++ = ch;
  800346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800349:	88 0a                	mov    %cl,(%edx)
  80034b:	42                   	inc    %edx
  80034c:	89 10                	mov    %edx,(%eax)
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	pushl  0x10(%ebp)
  80035d:	ff 75 0c             	pushl  0xc(%ebp)
  800360:	ff 75 08             	pushl  0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
	va_end(ap);
  800368:	83 c4 10             	add    $0x10,%esp
}
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 2c             	sub    $0x2c,%esp
  800376:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800379:	8b 75 10             	mov    0x10(%ebp),%esi
  80037c:	eb 13                	jmp    800391 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 6d 03 00 00    	je     8006f3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	57                   	push   %edi
  80038a:	50                   	push   %eax
  80038b:	ff 55 08             	call   *0x8(%ebp)
  80038e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800391:	0f b6 06             	movzbl (%esi),%eax
  800394:	46                   	inc    %esi
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e4                	jne    80037e <vprintfmt+0x11>
  80039a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80039e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b8:	eb 28                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c0:	eb 20                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c8:	eb 18                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d3:	eb 0d                	jmp    8003e2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8a 06                	mov    (%esi),%al
  8003e4:	0f b6 d0             	movzbl %al,%edx
  8003e7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 e0 02 00 00    	ja     8006d5 <vprintfmt+0x368>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	83 ea 30             	sub    $0x30,%edx
  800402:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800405:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800408:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040b:	83 fa 09             	cmp    $0x9,%edx
  80040e:	77 44                	ja     800454 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	89 de                	mov    %ebx,%esi
  800412:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800416:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800419:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80041d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800420:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800423:	83 fb 09             	cmp    $0x9,%ebx
  800426:	76 ed                	jbe    800415 <vprintfmt+0xa8>
  800428:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80042b:	eb 29                	jmp    800456 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043d:	eb 17                	jmp    800456 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	78 85                	js     8003ca <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	89 de                	mov    %ebx,%esi
  800447:	eb 99                	jmp    8003e2 <vprintfmt+0x75>
  800449:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800452:	eb 8e                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800456:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045a:	79 86                	jns    8003e2 <vprintfmt+0x75>
  80045c:	e9 74 ff ff ff       	jmp    8003d5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800461:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	89 de                	mov    %ebx,%esi
  800464:	e9 79 ff ff ff       	jmp    8003e2 <vprintfmt+0x75>
  800469:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	57                   	push   %edi
  800479:	ff 30                	pushl  (%eax)
  80047b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800484:	e9 08 ff ff ff       	jmp    800391 <vprintfmt+0x24>
  800489:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	79 02                	jns    80049d <vprintfmt+0x130>
  80049b:	f7 d8                	neg    %eax
  80049d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x142>
  8004a4:	8b 04 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 1a                	jne    8004c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004af:	52                   	push   %edx
  8004b0:	68 3e 21 80 00       	push   $0x80213e
  8004b5:	57                   	push   %edi
  8004b6:	ff 75 08             	pushl  0x8(%ebp)
  8004b9:	e8 92 fe ff ff       	call   800350 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 c8 fe ff ff       	jmp    800391 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	50                   	push   %eax
  8004ca:	68 f1 24 80 00       	push   $0x8024f1
  8004cf:	57                   	push   %edi
  8004d0:	ff 75 08             	pushl  0x8(%ebp)
  8004d3:	e8 78 fe ff ff       	call   800350 <printfmt>
  8004d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004de:	e9 ae fe ff ff       	jmp    800391 <vprintfmt+0x24>
  8004e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e6:	89 de                	mov    %ebx,%esi
  8004e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	75 07                	jne    800507 <vprintfmt+0x19a>
				p = "(null)";
  800500:	c7 45 d0 37 21 80 00 	movl   $0x802137,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800507:	85 db                	test   %ebx,%ebx
  800509:	7e 42                	jle    80054d <vprintfmt+0x1e0>
  80050b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80050f:	74 3c                	je     80054d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	51                   	push   %ecx
  800515:	ff 75 d0             	pushl  -0x30(%ebp)
  800518:	e8 6f 02 00 00       	call   80078c <strnlen>
  80051d:	29 c3                	sub    %eax,%ebx
  80051f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 db                	test   %ebx,%ebx
  800527:	7e 24                	jle    80054d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800529:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80052d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800530:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	57                   	push   %edi
  800537:	53                   	push   %ebx
  800538:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	4e                   	dec    %esi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 f6                	test   %esi,%esi
  800541:	7f f0                	jg     800533 <vprintfmt+0x1c6>
  800543:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800546:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800550:	0f be 02             	movsbl (%edx),%eax
  800553:	85 c0                	test   %eax,%eax
  800555:	75 47                	jne    80059e <vprintfmt+0x231>
  800557:	eb 37                	jmp    800590 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055d:	74 16                	je     800575 <vprintfmt+0x208>
  80055f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800562:	83 fa 5e             	cmp    $0x5e,%edx
  800565:	76 0e                	jbe    800575 <vprintfmt+0x208>
					putch('?', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 0b                	jmp    800580 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	50                   	push   %eax
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	ff 4d e4             	decl   -0x1c(%ebp)
  800583:	0f be 03             	movsbl (%ebx),%eax
  800586:	85 c0                	test   %eax,%eax
  800588:	74 03                	je     80058d <vprintfmt+0x220>
  80058a:	43                   	inc    %ebx
  80058b:	eb 1b                	jmp    8005a8 <vprintfmt+0x23b>
  80058d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800594:	7f 1e                	jg     8005b4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800599:	e9 f3 fd ff ff       	jmp    800391 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a1:	43                   	inc    %ebx
  8005a2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a8:	85 f6                	test   %esi,%esi
  8005aa:	78 ad                	js     800559 <vprintfmt+0x1ec>
  8005ac:	4e                   	dec    %esi
  8005ad:	79 aa                	jns    800559 <vprintfmt+0x1ec>
  8005af:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b2:	eb dc                	jmp    800590 <vprintfmt+0x223>
  8005b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 20                	push   $0x20
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c0:	4b                   	dec    %ebx
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f ef                	jg     8005b7 <vprintfmt+0x24a>
  8005c8:	e9 c4 fd ff ff       	jmp    800391 <vprintfmt+0x24>
  8005cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 2a fd ff ff       	call   800304 <getint>
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	78 0a                	js     8005ec <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 b0 00 00 00       	jmp    80069c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f5:	f7 db                	neg    %ebx
  8005f7:	83 d6 00             	adc    $0x0,%esi
  8005fa:	f7 de                	neg    %esi
  8005fc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 93 00 00 00       	jmp    80069c <vprintfmt+0x32f>
  800609:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 b4 fc ff ff       	call   8002ca <getuint>
  800616:	89 c3                	mov    %eax,%ebx
  800618:	89 d6                	mov    %edx,%esi
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061f:	eb 7b                	jmp    80069c <vprintfmt+0x32f>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 d6 fc ff ff       	call   800304 <getint>
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800632:	85 d2                	test   %edx,%edx
  800634:	78 07                	js     80063d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800636:	b8 08 00 00 00       	mov    $0x8,%eax
  80063b:	eb 5f                	jmp    80069c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	57                   	push   %edi
  800641:	6a 2d                	push   $0x2d
  800643:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800646:	f7 db                	neg    %ebx
  800648:	83 d6 00             	adc    $0x0,%esi
  80064b:	f7 de                	neg    %esi
  80064d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800650:	b8 08 00 00 00       	mov    $0x8,%eax
  800655:	eb 45                	jmp    80069c <vprintfmt+0x32f>
  800657:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	57                   	push   %edi
  80065e:	6a 30                	push   $0x30
  800660:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	57                   	push   %edi
  800667:	6a 78                	push   $0x78
  800669:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	8b 18                	mov    (%eax),%ebx
  800677:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800684:	eb 16                	jmp    80069c <vprintfmt+0x32f>
  800686:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 37 fc ff ff       	call   8002ca <getuint>
  800693:	89 c3                	mov    %eax,%ebx
  800695:	89 d6                	mov    %edx,%esi
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006a3:	52                   	push   %edx
  8006a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a7:	50                   	push   %eax
  8006a8:	56                   	push   %esi
  8006a9:	53                   	push   %ebx
  8006aa:	89 fa                	mov    %edi,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 68 fb ff ff       	call   80021c <printnum>
			break;
  8006b4:	83 c4 20             	add    $0x20,%esp
  8006b7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ba:	e9 d2 fc ff ff       	jmp    800391 <vprintfmt+0x24>
  8006bf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	57                   	push   %edi
  8006c6:	52                   	push   %edx
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d0:	e9 bc fc ff ff       	jmp    800391 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	57                   	push   %edi
  8006d9:	6a 25                	push   $0x25
  8006db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 02                	jmp    8006e5 <vprintfmt+0x378>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006e8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ec:	75 f5                	jne    8006e3 <vprintfmt+0x376>
  8006ee:	e9 9e fc ff ff       	jmp    800391 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x47>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 29                	jle    800749 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 36 03 80 00       	push   $0x800336
  80072f:	e8 39 fc ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 0c                	jmp    80074e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb 05                	jmp    80074e <vsnprintf+0x53>
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 93 ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3a 00             	cmpb   $0x0,(%edx)
  800775:	74 0e                	je     800785 <strlen+0x19>
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80077c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800781:	75 f9                	jne    80077c <strlen+0x10>
  800783:	eb 05                	jmp    80078a <strlen+0x1e>
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	85 d2                	test   %edx,%edx
  800797:	74 17                	je     8007b0 <strnlen+0x24>
  800799:	80 39 00             	cmpb   $0x0,(%ecx)
  80079c:	74 19                	je     8007b7 <strnlen+0x2b>
  80079e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a4:	39 d0                	cmp    %edx,%eax
  8007a6:	74 14                	je     8007bc <strnlen+0x30>
  8007a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ac:	75 f5                	jne    8007a3 <strnlen+0x17>
  8007ae:	eb 0c                	jmp    8007bc <strnlen+0x30>
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 05                	jmp    8007bc <strnlen+0x30>
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d3:	42                   	inc    %edx
  8007d4:	84 c9                	test   %cl,%cl
  8007d6:	75 f5                	jne    8007cd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	53                   	push   %ebx
  8007e3:	e8 84 ff ff ff       	call   80076c <strlen>
  8007e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 c7 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	85 f6                	test   %esi,%esi
  80080e:	74 15                	je     800825 <strncpy+0x27>
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800815:	8a 1a                	mov    (%edx),%bl
  800817:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 3a 01             	cmpb   $0x1,(%edx)
  80081d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	41                   	inc    %ecx
  800821:	39 ce                	cmp    %ecx,%esi
  800823:	77 f0                	ja     800815 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	57                   	push   %edi
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800835:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 f6                	test   %esi,%esi
  80083a:	74 32                	je     80086e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80083c:	83 fe 01             	cmp    $0x1,%esi
  80083f:	74 22                	je     800863 <strlcpy+0x3a>
  800841:	8a 0b                	mov    (%ebx),%cl
  800843:	84 c9                	test   %cl,%cl
  800845:	74 20                	je     800867 <strlcpy+0x3e>
  800847:	89 f8                	mov    %edi,%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80084e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800851:	88 08                	mov    %cl,(%eax)
  800853:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 f2                	cmp    %esi,%edx
  800856:	74 11                	je     800869 <strlcpy+0x40>
  800858:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80085c:	42                   	inc    %edx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	75 f0                	jne    800851 <strlcpy+0x28>
  800861:	eb 06                	jmp    800869 <strlcpy+0x40>
  800863:	89 f8                	mov    %edi,%eax
  800865:	eb 02                	jmp    800869 <strlcpy+0x40>
  800867:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800869:	c6 00 00             	movb   $0x0,(%eax)
  80086c:	eb 02                	jmp    800870 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800870:	29 f8                	sub    %edi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	8a 01                	mov    (%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 10                	je     800896 <strcmp+0x1f>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	75 0c                	jne    800896 <strcmp+0x1f>
		p++, q++;
  80088a:	41                   	inc    %ecx
  80088b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088c:	8a 01                	mov    (%ecx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1f>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 f4                	je     80088a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	74 1b                	je     8008cc <strncmp+0x2c>
  8008b1:	8a 1a                	mov    (%edx),%bl
  8008b3:	84 db                	test   %bl,%bl
  8008b5:	74 24                	je     8008db <strncmp+0x3b>
  8008b7:	3a 19                	cmp    (%ecx),%bl
  8008b9:	75 20                	jne    8008db <strncmp+0x3b>
  8008bb:	48                   	dec    %eax
  8008bc:	74 15                	je     8008d3 <strncmp+0x33>
		n--, p++, q++;
  8008be:	42                   	inc    %edx
  8008bf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c0:	8a 1a                	mov    (%edx),%bl
  8008c2:	84 db                	test   %bl,%bl
  8008c4:	74 15                	je     8008db <strncmp+0x3b>
  8008c6:	3a 19                	cmp    (%ecx),%bl
  8008c8:	74 f1                	je     8008bb <strncmp+0x1b>
  8008ca:	eb 0f                	jmp    8008db <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strncmp+0x38>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 02             	movzbl (%edx),%eax
  8008de:	0f b6 11             	movzbl (%ecx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb f3                	jmp    8008d8 <strncmp+0x38>

008008e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ee:	8a 10                	mov    (%eax),%dl
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	74 18                	je     80090c <strchr+0x27>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	75 06                	jne    8008fe <strchr+0x19>
  8008f8:	eb 17                	jmp    800911 <strchr+0x2c>
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	74 13                	je     800911 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fe:	40                   	inc    %eax
  8008ff:	8a 10                	mov    (%eax),%dl
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f5                	jne    8008fa <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	eb 05                	jmp    800911 <strchr+0x2c>
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091c:	8a 10                	mov    (%eax),%dl
  80091e:	84 d2                	test   %dl,%dl
  800920:	74 11                	je     800933 <strfind+0x20>
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	75 06                	jne    80092c <strfind+0x19>
  800926:	eb 0b                	jmp    800933 <strfind+0x20>
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	74 07                	je     800933 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092c:	40                   	inc    %eax
  80092d:	8a 10                	mov    (%eax),%dl
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f5                	jne    800928 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 30                	je     800978 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 25                	jne    800975 <memset+0x40>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 20                	jne    800975 <memset+0x40>
		c &= 0xFF;
  800955:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 d0                	or     %edx,%eax
  80096b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800970:	fc                   	cld    
  800971:	f3 ab                	rep stos %eax,%es:(%edi)
  800973:	eb 03                	jmp    800978 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098d:	39 c6                	cmp    %eax,%esi
  80098f:	73 34                	jae    8009c5 <memmove+0x46>
  800991:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800994:	39 d0                	cmp    %edx,%eax
  800996:	73 2d                	jae    8009c5 <memmove+0x46>
		s += n;
		d += n;
  800998:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	75 1b                	jne    8009bb <memmove+0x3c>
  8009a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a6:	75 13                	jne    8009bb <memmove+0x3c>
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 0e                	jne    8009bb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ad:	83 ef 04             	sub    $0x4,%edi
  8009b0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b6:	fd                   	std    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 07                	jmp    8009c2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bb:	4f                   	dec    %edi
  8009bc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c2:	fc                   	cld    
  8009c3:	eb 20                	jmp    8009e5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	75 13                	jne    8009e0 <memmove+0x61>
  8009cd:	a8 03                	test   $0x3,%al
  8009cf:	75 0f                	jne    8009e0 <memmove+0x61>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0a                	jne    8009e0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 05                	jmp    8009e5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ec:	ff 75 10             	pushl  0x10(%ebp)
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	ff 75 08             	pushl  0x8(%ebp)
  8009f5:	e8 85 ff ff ff       	call   80097f <memmove>
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a08:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	74 32                	je     800a41 <memcmp+0x45>
		if (*s1 != *s2)
  800a0f:	8a 03                	mov    (%ebx),%al
  800a11:	8a 0e                	mov    (%esi),%cl
  800a13:	38 c8                	cmp    %cl,%al
  800a15:	74 19                	je     800a30 <memcmp+0x34>
  800a17:	eb 0d                	jmp    800a26 <memcmp+0x2a>
  800a19:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a1d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a21:	42                   	inc    %edx
  800a22:	38 c8                	cmp    %cl,%al
  800a24:	74 10                	je     800a36 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c0             	movzbl %al,%eax
  800a29:	0f b6 c9             	movzbl %cl,%ecx
  800a2c:	29 c8                	sub    %ecx,%eax
  800a2e:	eb 16                	jmp    800a46 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	4f                   	dec    %edi
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	39 fa                	cmp    %edi,%edx
  800a38:	75 df                	jne    800a19 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	eb 05                	jmp    800a46 <memcmp+0x4a>
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	73 12                	jae    800a6c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	75 06                	jne    800a67 <memfind+0x1c>
  800a61:	eb 09                	jmp    800a6c <memfind+0x21>
  800a63:	38 08                	cmp    %cl,(%eax)
  800a65:	74 05                	je     800a6c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	40                   	inc    %eax
  800a68:	39 c2                	cmp    %eax,%edx
  800a6a:	77 f7                	ja     800a63 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 01                	jmp    800a7d <strtol+0xf>
		s++;
  800a7c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7d:	8a 02                	mov    (%edx),%al
  800a7f:	3c 20                	cmp    $0x20,%al
  800a81:	74 f9                	je     800a7c <strtol+0xe>
  800a83:	3c 09                	cmp    $0x9,%al
  800a85:	74 f5                	je     800a7c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a87:	3c 2b                	cmp    $0x2b,%al
  800a89:	75 08                	jne    800a93 <strtol+0x25>
		s++;
  800a8b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	eb 13                	jmp    800aa6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	75 0a                	jne    800aa1 <strtol+0x33>
		s++, neg = 1;
  800a97:	8d 52 01             	lea    0x1(%edx),%edx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9f:	eb 05                	jmp    800aa6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 05                	je     800aaf <strtol+0x41>
  800aaa:	83 fb 10             	cmp    $0x10,%ebx
  800aad:	75 28                	jne    800ad7 <strtol+0x69>
  800aaf:	8a 02                	mov    (%edx),%al
  800ab1:	3c 30                	cmp    $0x30,%al
  800ab3:	75 10                	jne    800ac5 <strtol+0x57>
  800ab5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab9:	75 0a                	jne    800ac5 <strtol+0x57>
		s += 2, base = 16;
  800abb:	83 c2 02             	add    $0x2,%edx
  800abe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac3:	eb 12                	jmp    800ad7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	75 0e                	jne    800ad7 <strtol+0x69>
  800ac9:	3c 30                	cmp    $0x30,%al
  800acb:	75 05                	jne    800ad2 <strtol+0x64>
		s++, base = 8;
  800acd:	42                   	inc    %edx
  800ace:	b3 08                	mov    $0x8,%bl
  800ad0:	eb 05                	jmp    800ad7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ade:	8a 0a                	mov    (%edx),%cl
  800ae0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae3:	80 fb 09             	cmp    $0x9,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x82>
			dig = *s - '0';
  800ae8:	0f be c9             	movsbl %cl,%ecx
  800aeb:	83 e9 30             	sub    $0x30,%ecx
  800aee:	eb 1e                	jmp    800b0e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0x92>
			dig = *s - 'a' + 10;
  800af8:	0f be c9             	movsbl %cl,%ecx
  800afb:	83 e9 57             	sub    $0x57,%ecx
  800afe:	eb 0e                	jmp    800b0e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 13                	ja     800b1b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b08:	0f be c9             	movsbl %cl,%ecx
  800b0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0e:	39 f1                	cmp    %esi,%ecx
  800b10:	7d 0d                	jge    800b1f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b12:	42                   	inc    %edx
  800b13:	0f af c6             	imul   %esi,%eax
  800b16:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b19:	eb c3                	jmp    800ade <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	89 c1                	mov    %eax,%ecx
  800b1d:	eb 02                	jmp    800b21 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b25:	74 05                	je     800b2c <strtol+0xbe>
		*endptr = (char *) s;
  800b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	74 04                	je     800b34 <strtol+0xc6>
  800b30:	89 c8                	mov    %ecx,%eax
  800b32:	f7 d8                	neg    %eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    
  800b39:	00 00                	add    %al,(%eax)
	...

00800b3c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 1c             	sub    $0x1c,%esp
  800b45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b48:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b4b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b50:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b59:	cd 30                	int    $0x30
  800b5b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b61:	74 1c                	je     800b7f <syscall+0x43>
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 18                	jle    800b7f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	50                   	push   %eax
  800b6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6e:	68 1f 24 80 00       	push   $0x80241f
  800b73:	6a 42                	push   $0x42
  800b75:	68 3c 24 80 00       	push   $0x80243c
  800b7a:	e8 4d 11 00 00       	call   801ccc <_panic>

	return ret;
}
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	ff 75 0c             	pushl  0xc(%ebp)
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba5:	e8 92 ff ff ff       	call   800b3c <syscall>
  800baa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sys_cgetc>:

int
sys_cgetc(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcc:	e8 6b ff ff ff       	call   800b3c <syscall>
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	6a 00                	push   $0x0
  800bdf:	6a 00                	push   $0x0
  800be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be4:	ba 01 00 00 00       	mov    $0x1,%edx
  800be9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bee:	e8 49 ff ff ff       	call   800b3c <syscall>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	6a 00                	push   $0x0
  800c01:	6a 00                	push   $0x0
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c12:	e8 25 ff ff ff       	call   800b3c <syscall>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <sys_yield>:

void
sys_yield(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c1f:	6a 00                	push   $0x0
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c36:	e8 01 ff ff ff       	call   800b3c <syscall>
  800c3b:	83 c4 10             	add    $0x10,%esp
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	ff 75 10             	pushl  0x10(%ebp)
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c53:	ba 01 00 00 00       	mov    $0x1,%edx
  800c58:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5d:	e8 da fe ff ff       	call   800b3c <syscall>
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c6a:	ff 75 18             	pushl  0x18(%ebp)
  800c6d:	ff 75 14             	pushl  0x14(%ebp)
  800c70:	ff 75 10             	pushl  0x10(%ebp)
  800c73:	ff 75 0c             	pushl  0xc(%ebp)
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c83:	e8 b4 fe ff ff       	call   800b3c <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	e8 91 fe ff ff       	call   800b3c <syscall>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cb3:	6a 00                	push   $0x0
  800cb5:	6a 00                	push   $0x0
  800cb7:	6a 00                	push   $0x0
  800cb9:	ff 75 0c             	pushl  0xc(%ebp)
  800cbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc9:	e8 6e fe ff ff       	call   800b3c <syscall>
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cd6:	6a 00                	push   $0x0
  800cd8:	6a 00                	push   $0x0
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	e8 4b fe ff ff       	call   800b3c <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	ff 75 0c             	pushl  0xc(%ebp)
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0f:	e8 28 fe ff ff       	call   800b3c <syscall>
}
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d1c:	6a 00                	push   $0x0
  800d1e:	ff 75 14             	pushl  0x14(%ebp)
  800d21:	ff 75 10             	pushl  0x10(%ebp)
  800d24:	ff 75 0c             	pushl  0xc(%ebp)
  800d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d34:	e8 03 fe ff ff       	call   800b3c <syscall>
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d56:	e8 e1 fd ff ff       	call   800b3c <syscall>
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d63:	6a 00                	push   $0x0
  800d65:	6a 00                	push   $0x0
  800d67:	6a 00                	push   $0x0
  800d69:	ff 75 0c             	pushl  0xc(%ebp)
  800d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d79:	e8 be fd ff ff       	call   800b3c <syscall>
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d86:	6a 00                	push   $0x0
  800d88:	ff 75 14             	pushl  0x14(%ebp)
  800d8b:	ff 75 10             	pushl  0x10(%ebp)
  800d8e:	ff 75 0c             	pushl  0xc(%ebp)
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9e:	e8 99 fd ff ff       	call   800b3c <syscall>
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    
  800da5:	00 00                	add    %al,(%eax)
	...

00800da8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800db4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800db6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800db9:	83 3a 01             	cmpl   $0x1,(%edx)
  800dbc:	7e 0b                	jle    800dc9 <argstart+0x21>
  800dbe:	85 c9                	test   %ecx,%ecx
  800dc0:	75 0e                	jne    800dd0 <argstart+0x28>
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	eb 0c                	jmp    800dd5 <argstart+0x2d>
  800dc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dce:	eb 05                	jmp    800dd5 <argstart+0x2d>
  800dd0:	ba f1 20 80 00       	mov    $0x8020f1,%edx
  800dd5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dd8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <argnext>:

int
argnext(struct Argstate *args)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800ded:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800df4:	8b 43 08             	mov    0x8(%ebx),%eax
  800df7:	85 c0                	test   %eax,%eax
  800df9:	74 6c                	je     800e67 <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  800dfb:	80 38 00             	cmpb   $0x0,(%eax)
  800dfe:	75 4d                	jne    800e4d <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e00:	8b 0b                	mov    (%ebx),%ecx
  800e02:	83 39 01             	cmpl   $0x1,(%ecx)
  800e05:	74 52                	je     800e59 <argnext+0x78>
		    || args->argv[1][0] != '-'
  800e07:	8b 43 04             	mov    0x4(%ebx),%eax
  800e0a:	8d 70 04             	lea    0x4(%eax),%esi
  800e0d:	8b 50 04             	mov    0x4(%eax),%edx
  800e10:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800e13:	75 44                	jne    800e59 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  800e15:	8d 7a 01             	lea    0x1(%edx),%edi
  800e18:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  800e1c:	74 3b                	je     800e59 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e1e:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 11                	mov    (%ecx),%edx
  800e26:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e2d:	52                   	push   %edx
  800e2e:	83 c0 08             	add    $0x8,%eax
  800e31:	50                   	push   %eax
  800e32:	56                   	push   %esi
  800e33:	e8 47 fb ff ff       	call   80097f <memmove>
		(*args->argc)--;
  800e38:	8b 03                	mov    (%ebx),%eax
  800e3a:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e3c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e45:	75 06                	jne    800e4d <argnext+0x6c>
  800e47:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e4b:	74 0c                	je     800e59 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e4d:	8b 53 08             	mov    0x8(%ebx),%edx
  800e50:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e53:	42                   	inc    %edx
  800e54:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e57:	eb 13                	jmp    800e6c <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  800e59:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e65:	eb 05                	jmp    800e6c <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e7c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	74 57                	je     800eda <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  800e83:	80 38 00             	cmpb   $0x0,(%eax)
  800e86:	74 0c                	je     800e94 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  800e88:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e8b:	c7 43 08 f1 20 80 00 	movl   $0x8020f1,0x8(%ebx)
  800e92:	eb 41                	jmp    800ed5 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  800e94:	8b 03                	mov    (%ebx),%eax
  800e96:	83 38 01             	cmpl   $0x1,(%eax)
  800e99:	7e 2c                	jle    800ec7 <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  800e9b:	8b 53 04             	mov    0x4(%ebx),%edx
  800e9e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ea1:	8b 72 04             	mov    0x4(%edx),%esi
  800ea4:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	8b 00                	mov    (%eax),%eax
  800eac:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800eb3:	50                   	push   %eax
  800eb4:	83 c2 08             	add    $0x8,%edx
  800eb7:	52                   	push   %edx
  800eb8:	51                   	push   %ecx
  800eb9:	e8 c1 fa ff ff       	call   80097f <memmove>
		(*args->argc)--;
  800ebe:	8b 03                	mov    (%ebx),%eax
  800ec0:	ff 08                	decl   (%eax)
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	eb 0e                	jmp    800ed5 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  800ec7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ece:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ed5:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ed8:	eb 05                	jmp    800edf <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800edf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800eef:	8b 42 0c             	mov    0xc(%edx),%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	75 0c                	jne    800f02 <argvalue+0x1c>
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	52                   	push   %edx
  800efa:	e8 75 ff ff ff       	call   800e74 <argnextvalue>
  800eff:	83 c4 10             	add    $0x10,%esp
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f17:	ff 75 08             	pushl  0x8(%ebp)
  800f1a:	e8 e5 ff ff ff       	call   800f04 <fd2num>
  800f1f:	83 c4 04             	add    $0x4,%esp
  800f22:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f27:	c1 e0 0c             	shl    $0xc,%eax
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f33:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f38:	a8 01                	test   $0x1,%al
  800f3a:	74 34                	je     800f70 <fd_alloc+0x44>
  800f3c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f41:	a8 01                	test   $0x1,%al
  800f43:	74 32                	je     800f77 <fd_alloc+0x4b>
  800f45:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800f4a:	89 c1                	mov    %eax,%ecx
  800f4c:	89 c2                	mov    %eax,%edx
  800f4e:	c1 ea 16             	shr    $0x16,%edx
  800f51:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f58:	f6 c2 01             	test   $0x1,%dl
  800f5b:	74 1f                	je     800f7c <fd_alloc+0x50>
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 0c             	shr    $0xc,%edx
  800f62:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	75 17                	jne    800f85 <fd_alloc+0x59>
  800f6e:	eb 0c                	jmp    800f7c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f70:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f75:	eb 05                	jmp    800f7c <fd_alloc+0x50>
  800f77:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f7c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f83:	eb 17                	jmp    800f9c <fd_alloc+0x70>
  800f85:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f8a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f8f:	75 b9                	jne    800f4a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f97:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f9c:	5b                   	pop    %ebx
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fa5:	83 f8 1f             	cmp    $0x1f,%eax
  800fa8:	77 36                	ja     800fe0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800faa:	05 00 00 0d 00       	add    $0xd0000,%eax
  800faf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	c1 ea 16             	shr    $0x16,%edx
  800fb7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fbe:	f6 c2 01             	test   $0x1,%dl
  800fc1:	74 24                	je     800fe7 <fd_lookup+0x48>
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	c1 ea 0c             	shr    $0xc,%edx
  800fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcf:	f6 c2 01             	test   $0x1,%dl
  800fd2:	74 1a                	je     800fee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	89 02                	mov    %eax,(%edx)
	return 0;
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fde:	eb 13                	jmp    800ff3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe5:	eb 0c                	jmp    800ff3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fec:	eb 05                	jmp    800ff3 <fd_lookup+0x54>
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801002:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801008:	74 0d                	je     801017 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80100a:	b8 00 00 00 00       	mov    $0x0,%eax
  80100f:	eb 14                	jmp    801025 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801011:	39 0a                	cmp    %ecx,(%edx)
  801013:	75 10                	jne    801025 <dev_lookup+0x30>
  801015:	eb 05                	jmp    80101c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801017:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80101c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80101e:	b8 00 00 00 00       	mov    $0x0,%eax
  801023:	eb 31                	jmp    801056 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801025:	40                   	inc    %eax
  801026:	8b 14 85 c8 24 80 00 	mov    0x8024c8(,%eax,4),%edx
  80102d:	85 d2                	test   %edx,%edx
  80102f:	75 e0                	jne    801011 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801031:	a1 04 40 80 00       	mov    0x804004,%eax
  801036:	8b 40 48             	mov    0x48(%eax),%eax
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	51                   	push   %ecx
  80103d:	50                   	push   %eax
  80103e:	68 4c 24 80 00       	push   $0x80244c
  801043:	e8 c0 f1 ff ff       	call   800208 <cprintf>
	*dev = 0;
  801048:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 20             	sub    $0x20,%esp
  801063:	8b 75 08             	mov    0x8(%ebp),%esi
  801066:	8a 45 0c             	mov    0xc(%ebp),%al
  801069:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106c:	56                   	push   %esi
  80106d:	e8 92 fe ff ff       	call   800f04 <fd2num>
  801072:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801075:	89 14 24             	mov    %edx,(%esp)
  801078:	50                   	push   %eax
  801079:	e8 21 ff ff ff       	call   800f9f <fd_lookup>
  80107e:	89 c3                	mov    %eax,%ebx
  801080:	83 c4 08             	add    $0x8,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 05                	js     80108c <fd_close+0x31>
	    || fd != fd2)
  801087:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80108a:	74 0d                	je     801099 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80108c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801090:	75 48                	jne    8010da <fd_close+0x7f>
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	eb 41                	jmp    8010da <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109f:	50                   	push   %eax
  8010a0:	ff 36                	pushl  (%esi)
  8010a2:	e8 4e ff ff ff       	call   800ff5 <dev_lookup>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 1c                	js     8010cc <fd_close+0x71>
		if (dev->dev_close)
  8010b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b3:	8b 40 10             	mov    0x10(%eax),%eax
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	74 0d                	je     8010c7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	56                   	push   %esi
  8010be:	ff d0                	call   *%eax
  8010c0:	89 c3                	mov    %eax,%ebx
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	eb 05                	jmp    8010cc <fd_close+0x71>
		else
			r = 0;
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	56                   	push   %esi
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 b3 fb ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8010d7:	83 c4 10             	add    $0x10,%esp
}
  8010da:	89 d8                	mov    %ebx,%eax
  8010dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	ff 75 08             	pushl  0x8(%ebp)
  8010f0:	e8 aa fe ff ff       	call   800f9f <fd_lookup>
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 10                	js     80110c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	6a 01                	push   $0x1
  801101:	ff 75 f4             	pushl  -0xc(%ebp)
  801104:	e8 52 ff ff ff       	call   80105b <fd_close>
  801109:	83 c4 10             	add    $0x10,%esp
}
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    

0080110e <close_all>:

void
close_all(void)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	53                   	push   %ebx
  801112:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801115:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	53                   	push   %ebx
  80111e:	e8 c0 ff ff ff       	call   8010e3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801123:	43                   	inc    %ebx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	83 fb 20             	cmp    $0x20,%ebx
  80112a:	75 ee                	jne    80111a <close_all+0xc>
		close(i);
}
  80112c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 2c             	sub    $0x2c,%esp
  80113a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80113d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	ff 75 08             	pushl  0x8(%ebp)
  801144:	e8 56 fe ff ff       	call   800f9f <fd_lookup>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	0f 88 c0 00 00 00    	js     801216 <dup+0xe5>
		return r;
	close(newfdnum);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	57                   	push   %edi
  80115a:	e8 84 ff ff ff       	call   8010e3 <close>

	newfd = INDEX2FD(newfdnum);
  80115f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801165:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801168:	83 c4 04             	add    $0x4,%esp
  80116b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116e:	e8 a1 fd ff ff       	call   800f14 <fd2data>
  801173:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801175:	89 34 24             	mov    %esi,(%esp)
  801178:	e8 97 fd ff ff       	call   800f14 <fd2data>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801183:	89 d8                	mov    %ebx,%eax
  801185:	c1 e8 16             	shr    $0x16,%eax
  801188:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118f:	a8 01                	test   $0x1,%al
  801191:	74 37                	je     8011ca <dup+0x99>
  801193:	89 d8                	mov    %ebx,%eax
  801195:	c1 e8 0c             	shr    $0xc,%eax
  801198:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 26                	je     8011ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b3:	50                   	push   %eax
  8011b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011b7:	6a 00                	push   $0x0
  8011b9:	53                   	push   %ebx
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 a3 fa ff ff       	call   800c64 <sys_page_map>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	83 c4 20             	add    $0x20,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 2d                	js     8011f7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	c1 ea 0c             	shr    $0xc,%edx
  8011d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011e2:	52                   	push   %edx
  8011e3:	56                   	push   %esi
  8011e4:	6a 00                	push   $0x0
  8011e6:	50                   	push   %eax
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 76 fa ff ff       	call   800c64 <sys_page_map>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	79 1d                	jns    801214 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	56                   	push   %esi
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 88 fa ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	ff 75 d4             	pushl  -0x2c(%ebp)
  801208:	6a 00                	push   $0x0
  80120a:	e8 7b fa ff ff       	call   800c8a <sys_page_unmap>
	return r;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	eb 02                	jmp    801216 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801214:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801216:	89 d8                	mov    %ebx,%eax
  801218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5e                   	pop    %esi
  80121d:	5f                   	pop    %edi
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	83 ec 14             	sub    $0x14,%esp
  801227:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	53                   	push   %ebx
  80122f:	e8 6b fd ff ff       	call   800f9f <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 67                	js     8012a2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	ff 30                	pushl  (%eax)
  801247:	e8 a9 fd ff ff       	call   800ff5 <dev_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 4f                	js     8012a2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	8b 50 08             	mov    0x8(%eax),%edx
  801259:	83 e2 03             	and    $0x3,%edx
  80125c:	83 fa 01             	cmp    $0x1,%edx
  80125f:	75 21                	jne    801282 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801261:	a1 04 40 80 00       	mov    0x804004,%eax
  801266:	8b 40 48             	mov    0x48(%eax),%eax
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	53                   	push   %ebx
  80126d:	50                   	push   %eax
  80126e:	68 8d 24 80 00       	push   $0x80248d
  801273:	e8 90 ef ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801280:	eb 20                	jmp    8012a2 <read+0x82>
	}
	if (!dev->dev_read)
  801282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801285:	8b 52 08             	mov    0x8(%edx),%edx
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 11                	je     80129d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	ff 75 10             	pushl  0x10(%ebp)
  801292:	ff 75 0c             	pushl  0xc(%ebp)
  801295:	50                   	push   %eax
  801296:	ff d2                	call   *%edx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	eb 05                	jmp    8012a2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80129d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	57                   	push   %edi
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b6:	85 f6                	test   %esi,%esi
  8012b8:	74 31                	je     8012eb <readn+0x44>
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	89 f2                	mov    %esi,%edx
  8012c9:	29 c2                	sub    %eax,%edx
  8012cb:	52                   	push   %edx
  8012cc:	03 45 0c             	add    0xc(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	57                   	push   %edi
  8012d1:	e8 4a ff ff ff       	call   801220 <read>
		if (m < 0)
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 17                	js     8012f4 <readn+0x4d>
			return m;
		if (m == 0)
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	74 11                	je     8012f2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e1:	01 c3                	add    %eax,%ebx
  8012e3:	89 d8                	mov    %ebx,%eax
  8012e5:	39 f3                	cmp    %esi,%ebx
  8012e7:	72 db                	jb     8012c4 <readn+0x1d>
  8012e9:	eb 09                	jmp    8012f4 <readn+0x4d>
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f0:	eb 02                	jmp    8012f4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012f2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 14             	sub    $0x14,%esp
  801303:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	53                   	push   %ebx
  80130b:	e8 8f fc ff ff       	call   800f9f <fd_lookup>
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 62                	js     801379 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131d:	50                   	push   %eax
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	ff 30                	pushl  (%eax)
  801323:	e8 cd fc ff ff       	call   800ff5 <dev_lookup>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 4a                	js     801379 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801332:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801336:	75 21                	jne    801359 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801338:	a1 04 40 80 00       	mov    0x804004,%eax
  80133d:	8b 40 48             	mov    0x48(%eax),%eax
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	53                   	push   %ebx
  801344:	50                   	push   %eax
  801345:	68 a9 24 80 00       	push   $0x8024a9
  80134a:	e8 b9 ee ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801357:	eb 20                	jmp    801379 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801359:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135c:	8b 52 0c             	mov    0xc(%edx),%edx
  80135f:	85 d2                	test   %edx,%edx
  801361:	74 11                	je     801374 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801363:	83 ec 04             	sub    $0x4,%esp
  801366:	ff 75 10             	pushl  0x10(%ebp)
  801369:	ff 75 0c             	pushl  0xc(%ebp)
  80136c:	50                   	push   %eax
  80136d:	ff d2                	call   *%edx
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	eb 05                	jmp    801379 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801374:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <seek>:

int
seek(int fdnum, off_t offset)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801384:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	ff 75 08             	pushl  0x8(%ebp)
  80138b:	e8 0f fc ff ff       	call   800f9f <fd_lookup>
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 0e                	js     8013a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801397:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80139a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 14             	sub    $0x14,%esp
  8013ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	53                   	push   %ebx
  8013b6:	e8 e4 fb ff ff       	call   800f9f <fd_lookup>
  8013bb:	83 c4 08             	add    $0x8,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 5f                	js     801421 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	ff 30                	pushl  (%eax)
  8013ce:	e8 22 fc ff ff       	call   800ff5 <dev_lookup>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 47                	js     801421 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e1:	75 21                	jne    801404 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e8:	8b 40 48             	mov    0x48(%eax),%eax
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	50                   	push   %eax
  8013f0:	68 6c 24 80 00       	push   $0x80246c
  8013f5:	e8 0e ee ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801402:	eb 1d                	jmp    801421 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801404:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801407:	8b 52 18             	mov    0x18(%edx),%edx
  80140a:	85 d2                	test   %edx,%edx
  80140c:	74 0e                	je     80141c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	ff 75 0c             	pushl  0xc(%ebp)
  801414:	50                   	push   %eax
  801415:	ff d2                	call   *%edx
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	eb 05                	jmp    801421 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80141c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 14             	sub    $0x14,%esp
  80142d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	ff 75 08             	pushl  0x8(%ebp)
  801437:	e8 63 fb ff ff       	call   800f9f <fd_lookup>
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 52                	js     801495 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 a1 fb ff ff       	call   800ff5 <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 3a                	js     801495 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801462:	74 2c                	je     801490 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801464:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801467:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146e:	00 00 00 
	stat->st_isdir = 0;
  801471:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801478:	00 00 00 
	stat->st_dev = dev;
  80147b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	ff 75 f0             	pushl  -0x10(%ebp)
  801488:	ff 50 14             	call   *0x14(%eax)
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	eb 05                	jmp    801495 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801490:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	6a 00                	push   $0x0
  8014a4:	ff 75 08             	pushl  0x8(%ebp)
  8014a7:	e8 78 01 00 00       	call   801624 <open>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 1b                	js     8014d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	ff 75 0c             	pushl  0xc(%ebp)
  8014bb:	50                   	push   %eax
  8014bc:	e8 65 ff ff ff       	call   801426 <fstat>
  8014c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 18 fc ff ff       	call   8010e3 <close>
	return r;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	89 f3                	mov    %esi,%ebx
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    
  8014d9:	00 00                	add    %al,(%eax)
	...

008014dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	89 c3                	mov    %eax,%ebx
  8014e3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014ec:	75 12                	jne    801500 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	6a 01                	push   $0x1
  8014f3:	e8 e6 08 00 00       	call   801dde <ipc_find_env>
  8014f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8014fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801500:	6a 07                	push   $0x7
  801502:	68 00 50 80 00       	push   $0x805000
  801507:	53                   	push   %ebx
  801508:	ff 35 00 40 80 00    	pushl  0x804000
  80150e:	e8 76 08 00 00       	call   801d89 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801513:	83 c4 0c             	add    $0xc,%esp
  801516:	6a 00                	push   $0x0
  801518:	56                   	push   %esi
  801519:	6a 00                	push   $0x0
  80151b:	e8 f4 07 00 00       	call   801d14 <ipc_recv>
}
  801520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	53                   	push   %ebx
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
  801534:	8b 40 0c             	mov    0xc(%eax),%eax
  801537:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80153c:	ba 00 00 00 00       	mov    $0x0,%edx
  801541:	b8 05 00 00 00       	mov    $0x5,%eax
  801546:	e8 91 ff ff ff       	call   8014dc <fsipc>
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 2c                	js     80157b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	68 00 50 80 00       	push   $0x805000
  801557:	53                   	push   %ebx
  801558:	e8 61 f2 ff ff       	call   8007be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80155d:	a1 80 50 80 00       	mov    0x805080,%eax
  801562:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801568:	a1 84 50 80 00       	mov    0x805084,%eax
  80156d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	8b 40 0c             	mov    0xc(%eax),%eax
  80158c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 06 00 00 00       	mov    $0x6,%eax
  80159b:	e8 3c ff ff ff       	call   8014dc <fsipc>
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c5:	e8 12 ff ff ff       	call   8014dc <fsipc>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 4b                	js     80161b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d0:	39 c6                	cmp    %eax,%esi
  8015d2:	73 16                	jae    8015ea <devfile_read+0x48>
  8015d4:	68 d8 24 80 00       	push   $0x8024d8
  8015d9:	68 df 24 80 00       	push   $0x8024df
  8015de:	6a 7d                	push   $0x7d
  8015e0:	68 f4 24 80 00       	push   $0x8024f4
  8015e5:	e8 e2 06 00 00       	call   801ccc <_panic>
	assert(r <= PGSIZE);
  8015ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ef:	7e 16                	jle    801607 <devfile_read+0x65>
  8015f1:	68 ff 24 80 00       	push   $0x8024ff
  8015f6:	68 df 24 80 00       	push   $0x8024df
  8015fb:	6a 7e                	push   $0x7e
  8015fd:	68 f4 24 80 00       	push   $0x8024f4
  801602:	e8 c5 06 00 00       	call   801ccc <_panic>
	memmove(buf, &fsipcbuf, r);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	50                   	push   %eax
  80160b:	68 00 50 80 00       	push   $0x805000
  801610:	ff 75 0c             	pushl  0xc(%ebp)
  801613:	e8 67 f3 ff ff       	call   80097f <memmove>
	return r;
  801618:	83 c4 10             	add    $0x10,%esp
}
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801620:	5b                   	pop    %ebx
  801621:	5e                   	pop    %esi
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
  801629:	83 ec 1c             	sub    $0x1c,%esp
  80162c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80162f:	56                   	push   %esi
  801630:	e8 37 f1 ff ff       	call   80076c <strlen>
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80163d:	7f 65                	jg     8016a4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	e8 e1 f8 ff ff       	call   800f2c <fd_alloc>
  80164b:	89 c3                	mov    %eax,%ebx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 55                	js     8016a9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	56                   	push   %esi
  801658:	68 00 50 80 00       	push   $0x805000
  80165d:	e8 5c f1 ff ff       	call   8007be <strcpy>
	fsipcbuf.open.req_omode = mode;
  801662:	8b 45 0c             	mov    0xc(%ebp),%eax
  801665:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166d:	b8 01 00 00 00       	mov    $0x1,%eax
  801672:	e8 65 fe ff ff       	call   8014dc <fsipc>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	79 12                	jns    801692 <open+0x6e>
		fd_close(fd, 0);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	6a 00                	push   $0x0
  801685:	ff 75 f4             	pushl  -0xc(%ebp)
  801688:	e8 ce f9 ff ff       	call   80105b <fd_close>
		return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb 17                	jmp    8016a9 <open+0x85>
	}

	return fd2num(fd);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	ff 75 f4             	pushl  -0xc(%ebp)
  801698:	e8 67 f8 ff ff       	call   800f04 <fd2num>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 05                	jmp    8016a9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a9:	89 d8                	mov    %ebx,%eax
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    
	...

008016b4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 04             	sub    $0x4,%esp
  8016bb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8016bd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016c1:	7e 2e                	jle    8016f1 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	ff 70 04             	pushl  0x4(%eax)
  8016c9:	8d 40 10             	lea    0x10(%eax),%eax
  8016cc:	50                   	push   %eax
  8016cd:	ff 33                	pushl  (%ebx)
  8016cf:	e8 28 fc ff ff       	call   8012fc <write>
		if (result > 0)
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	7e 03                	jle    8016de <writebuf+0x2a>
			b->result += result;
  8016db:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016de:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016e1:	74 0e                	je     8016f1 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	7e 05                	jle    8016ee <writebuf+0x3a>
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <putch>:

static void
putch(int ch, void *thunk)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801700:	8b 43 04             	mov    0x4(%ebx),%eax
  801703:	8b 55 08             	mov    0x8(%ebp),%edx
  801706:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80170a:	40                   	inc    %eax
  80170b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80170e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801713:	75 0e                	jne    801723 <putch+0x2d>
		writebuf(b);
  801715:	89 d8                	mov    %ebx,%eax
  801717:	e8 98 ff ff ff       	call   8016b4 <writebuf>
		b->idx = 0;
  80171c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801723:	83 c4 04             	add    $0x4,%esp
  801726:	5b                   	pop    %ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80173b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801742:	00 00 00 
	b.result = 0;
  801745:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80174c:	00 00 00 
	b.error = 1;
  80174f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801756:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801759:	ff 75 10             	pushl  0x10(%ebp)
  80175c:	ff 75 0c             	pushl  0xc(%ebp)
  80175f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	68 f6 16 80 00       	push   $0x8016f6
  80176b:	e8 fd eb ff ff       	call   80036d <vprintfmt>
	if (b.idx > 0)
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80177a:	7e 0b                	jle    801787 <vfprintf+0x5e>
		writebuf(&b);
  80177c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801782:	e8 2d ff ff ff       	call   8016b4 <writebuf>

	return (b.result ? b.result : b.error);
  801787:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80178d:	85 c0                	test   %eax,%eax
  80178f:	75 06                	jne    801797 <vfprintf+0x6e>
  801791:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80179f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017a2:	50                   	push   %eax
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	ff 75 08             	pushl  0x8(%ebp)
  8017a9:	e8 7b ff ff ff       	call   801729 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <printf>:

int
printf(const char *fmt, ...)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017b9:	50                   	push   %eax
  8017ba:	ff 75 08             	pushl  0x8(%ebp)
  8017bd:	6a 01                	push   $0x1
  8017bf:	e8 65 ff ff ff       	call   801729 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    
	...

008017c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	ff 75 08             	pushl  0x8(%ebp)
  8017d6:	e8 39 f7 ff ff       	call   800f14 <fd2data>
  8017db:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	68 0b 25 80 00       	push   $0x80250b
  8017e5:	56                   	push   %esi
  8017e6:	e8 d3 ef ff ff       	call   8007be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ee:	2b 03                	sub    (%ebx),%eax
  8017f0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8017f6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017fd:	00 00 00 
	stat->st_dev = &devpipe;
  801800:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801807:	30 80 00 
	return 0;
}
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
  80180f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801820:	53                   	push   %ebx
  801821:	6a 00                	push   $0x0
  801823:	e8 62 f4 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801828:	89 1c 24             	mov    %ebx,(%esp)
  80182b:	e8 e4 f6 ff ff       	call   800f14 <fd2data>
  801830:	83 c4 08             	add    $0x8,%esp
  801833:	50                   	push   %eax
  801834:	6a 00                	push   $0x0
  801836:	e8 4f f4 ff ff       	call   800c8a <sys_page_unmap>
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	57                   	push   %edi
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
  801846:	83 ec 1c             	sub    $0x1c,%esp
  801849:	89 c7                	mov    %eax,%edi
  80184b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80184e:	a1 04 40 80 00       	mov    0x804004,%eax
  801853:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	57                   	push   %edi
  80185a:	e8 dd 05 00 00       	call   801e3c <pageref>
  80185f:	89 c6                	mov    %eax,%esi
  801861:	83 c4 04             	add    $0x4,%esp
  801864:	ff 75 e4             	pushl  -0x1c(%ebp)
  801867:	e8 d0 05 00 00       	call   801e3c <pageref>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	39 c6                	cmp    %eax,%esi
  801871:	0f 94 c0             	sete   %al
  801874:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801877:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80187d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801880:	39 cb                	cmp    %ecx,%ebx
  801882:	75 08                	jne    80188c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801884:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5f                   	pop    %edi
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80188c:	83 f8 01             	cmp    $0x1,%eax
  80188f:	75 bd                	jne    80184e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801891:	8b 42 58             	mov    0x58(%edx),%eax
  801894:	6a 01                	push   $0x1
  801896:	50                   	push   %eax
  801897:	53                   	push   %ebx
  801898:	68 12 25 80 00       	push   $0x802512
  80189d:	e8 66 e9 ff ff       	call   800208 <cprintf>
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	eb a7                	jmp    80184e <_pipeisclosed+0xe>

008018a7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 28             	sub    $0x28,%esp
  8018b0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018b3:	56                   	push   %esi
  8018b4:	e8 5b f6 ff ff       	call   800f14 <fd2data>
  8018b9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c2:	75 4a                	jne    80190e <devpipe_write+0x67>
  8018c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8018c9:	eb 56                	jmp    801921 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018cb:	89 da                	mov    %ebx,%edx
  8018cd:	89 f0                	mov    %esi,%eax
  8018cf:	e8 6c ff ff ff       	call   801840 <_pipeisclosed>
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	75 4d                	jne    801925 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018d8:	e8 3c f3 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018dd:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e0:	8b 13                	mov    (%ebx),%edx
  8018e2:	83 c2 20             	add    $0x20,%edx
  8018e5:	39 d0                	cmp    %edx,%eax
  8018e7:	73 e2                	jae    8018cb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018f1:	79 05                	jns    8018f8 <devpipe_write+0x51>
  8018f3:	4a                   	dec    %edx
  8018f4:	83 ca e0             	or     $0xffffffe0,%edx
  8018f7:	42                   	inc    %edx
  8018f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8018fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801902:	40                   	inc    %eax
  801903:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801906:	47                   	inc    %edi
  801907:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80190a:	77 07                	ja     801913 <devpipe_write+0x6c>
  80190c:	eb 13                	jmp    801921 <devpipe_write+0x7a>
  80190e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801913:	8b 43 04             	mov    0x4(%ebx),%eax
  801916:	8b 13                	mov    (%ebx),%edx
  801918:	83 c2 20             	add    $0x20,%edx
  80191b:	39 d0                	cmp    %edx,%eax
  80191d:	73 ac                	jae    8018cb <devpipe_write+0x24>
  80191f:	eb c8                	jmp    8018e9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801921:	89 f8                	mov    %edi,%eax
  801923:	eb 05                	jmp    80192a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80192a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5f                   	pop    %edi
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	57                   	push   %edi
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	83 ec 18             	sub    $0x18,%esp
  80193b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80193e:	57                   	push   %edi
  80193f:	e8 d0 f5 ff ff       	call   800f14 <fd2data>
  801944:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80194d:	75 44                	jne    801993 <devpipe_read+0x61>
  80194f:	be 00 00 00 00       	mov    $0x0,%esi
  801954:	eb 4f                	jmp    8019a5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801956:	89 f0                	mov    %esi,%eax
  801958:	eb 54                	jmp    8019ae <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80195a:	89 da                	mov    %ebx,%edx
  80195c:	89 f8                	mov    %edi,%eax
  80195e:	e8 dd fe ff ff       	call   801840 <_pipeisclosed>
  801963:	85 c0                	test   %eax,%eax
  801965:	75 42                	jne    8019a9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801967:	e8 ad f2 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80196c:	8b 03                	mov    (%ebx),%eax
  80196e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801971:	74 e7                	je     80195a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801973:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801978:	79 05                	jns    80197f <devpipe_read+0x4d>
  80197a:	48                   	dec    %eax
  80197b:	83 c8 e0             	or     $0xffffffe0,%eax
  80197e:	40                   	inc    %eax
  80197f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801983:	8b 55 0c             	mov    0xc(%ebp),%edx
  801986:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801989:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198b:	46                   	inc    %esi
  80198c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80198f:	77 07                	ja     801998 <devpipe_read+0x66>
  801991:	eb 12                	jmp    8019a5 <devpipe_read+0x73>
  801993:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801998:	8b 03                	mov    (%ebx),%eax
  80199a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80199d:	75 d4                	jne    801973 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80199f:	85 f6                	test   %esi,%esi
  8019a1:	75 b3                	jne    801956 <devpipe_read+0x24>
  8019a3:	eb b5                	jmp    80195a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019a5:	89 f0                	mov    %esi,%eax
  8019a7:	eb 05                	jmp    8019ae <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	57                   	push   %edi
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 28             	sub    $0x28,%esp
  8019bf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019c5:	50                   	push   %eax
  8019c6:	e8 61 f5 ff ff       	call   800f2c <fd_alloc>
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 24 01 00 00    	js     801afc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	68 07 04 00 00       	push   $0x407
  8019e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e3:	6a 00                	push   $0x0
  8019e5:	e8 56 f2 ff ff       	call   800c40 <sys_page_alloc>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	0f 88 05 01 00 00    	js     801afc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	e8 29 f5 ff ff       	call   800f2c <fd_alloc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	0f 88 dc 00 00 00    	js     801aec <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	68 07 04 00 00       	push   $0x407
  801a18:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 1e f2 ff ff       	call   800c40 <sys_page_alloc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	0f 88 bd 00 00 00    	js     801aec <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a35:	e8 da f4 ff ff       	call   800f14 <fd2data>
  801a3a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a3c:	83 c4 0c             	add    $0xc,%esp
  801a3f:	68 07 04 00 00       	push   $0x407
  801a44:	50                   	push   %eax
  801a45:	6a 00                	push   $0x0
  801a47:	e8 f4 f1 ff ff       	call   800c40 <sys_page_alloc>
  801a4c:	89 c3                	mov    %eax,%ebx
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	0f 88 83 00 00 00    	js     801adc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5f:	e8 b0 f4 ff ff       	call   800f14 <fd2data>
  801a64:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a6b:	50                   	push   %eax
  801a6c:	6a 00                	push   $0x0
  801a6e:	56                   	push   %esi
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 ee f1 ff ff       	call   800c64 <sys_page_map>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 20             	add    $0x20,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 4f                	js     801ace <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aa2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aaf:	e8 50 f4 ff ff       	call   800f04 <fd2num>
  801ab4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ab6:	83 c4 04             	add    $0x4,%esp
  801ab9:	ff 75 e0             	pushl  -0x20(%ebp)
  801abc:	e8 43 f4 ff ff       	call   800f04 <fd2num>
  801ac1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801acc:	eb 2e                	jmp    801afc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	56                   	push   %esi
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 b1 f1 ff ff       	call   800c8a <sys_page_unmap>
  801ad9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 a1 f1 ff ff       	call   800c8a <sys_page_unmap>
  801ae9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aec:	83 ec 08             	sub    $0x8,%esp
  801aef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af2:	6a 00                	push   $0x0
  801af4:	e8 91 f1 ff ff       	call   800c8a <sys_page_unmap>
  801af9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801afc:	89 d8                	mov    %ebx,%eax
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0f:	50                   	push   %eax
  801b10:	ff 75 08             	pushl  0x8(%ebp)
  801b13:	e8 87 f4 ff ff       	call   800f9f <fd_lookup>
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	78 18                	js     801b37 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	ff 75 f4             	pushl  -0xc(%ebp)
  801b25:	e8 ea f3 ff ff       	call   800f14 <fd2data>
	return _pipeisclosed(fd, p);
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2f:	e8 0c fd ff ff       	call   801840 <_pipeisclosed>
  801b34:	83 c4 10             	add    $0x10,%esp
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    
  801b39:	00 00                	add    %al,(%eax)
	...

00801b3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b4c:	68 2a 25 80 00       	push   $0x80252a
  801b51:	ff 75 0c             	pushl  0xc(%ebp)
  801b54:	e8 65 ec ff ff       	call   8007be <strcpy>
	return 0;
}
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b70:	74 45                	je     801bb7 <devcons_write+0x57>
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
  801b77:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b7c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b85:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b87:	83 fb 7f             	cmp    $0x7f,%ebx
  801b8a:	76 05                	jbe    801b91 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b8c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b91:	83 ec 04             	sub    $0x4,%esp
  801b94:	53                   	push   %ebx
  801b95:	03 45 0c             	add    0xc(%ebp),%eax
  801b98:	50                   	push   %eax
  801b99:	57                   	push   %edi
  801b9a:	e8 e0 ed ff ff       	call   80097f <memmove>
		sys_cputs(buf, m);
  801b9f:	83 c4 08             	add    $0x8,%esp
  801ba2:	53                   	push   %ebx
  801ba3:	57                   	push   %edi
  801ba4:	e8 e0 ef ff ff       	call   800b89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba9:	01 de                	add    %ebx,%esi
  801bab:	89 f0                	mov    %esi,%eax
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bb3:	72 cd                	jb     801b82 <devcons_write+0x22>
  801bb5:	eb 05                	jmp    801bbc <devcons_write+0x5c>
  801bb7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bd0:	75 07                	jne    801bd9 <devcons_read+0x13>
  801bd2:	eb 25                	jmp    801bf9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bd4:	e8 40 f0 ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bd9:	e8 d1 ef ff ff       	call   800baf <sys_cgetc>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	74 f2                	je     801bd4 <devcons_read+0xe>
  801be2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 1d                	js     801c05 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801be8:	83 f8 04             	cmp    $0x4,%eax
  801beb:	74 13                	je     801c00 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf0:	88 10                	mov    %dl,(%eax)
	return 1;
  801bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf7:	eb 0c                	jmp    801c05 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfe:	eb 05                	jmp    801c05 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c13:	6a 01                	push   $0x1
  801c15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c18:	50                   	push   %eax
  801c19:	e8 6b ef ff ff       	call   800b89 <sys_cputs>
  801c1e:	83 c4 10             	add    $0x10,%esp
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <getchar>:

int
getchar(void)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c29:	6a 01                	push   $0x1
  801c2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 ea f5 ff ff       	call   801220 <read>
	if (r < 0)
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 0f                	js     801c4c <getchar+0x29>
		return r;
	if (r < 1)
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	7e 06                	jle    801c47 <getchar+0x24>
		return -E_EOF;
	return c;
  801c41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c45:	eb 05                	jmp    801c4c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c57:	50                   	push   %eax
  801c58:	ff 75 08             	pushl  0x8(%ebp)
  801c5b:	e8 3f f3 ff ff       	call   800f9f <fd_lookup>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 11                	js     801c78 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c70:	39 10                	cmp    %edx,(%eax)
  801c72:	0f 94 c0             	sete   %al
  801c75:	0f b6 c0             	movzbl %al,%eax
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <opencons>:

int
opencons(void)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c83:	50                   	push   %eax
  801c84:	e8 a3 f2 ff ff       	call   800f2c <fd_alloc>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 3a                	js     801cca <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 9e ef ff ff       	call   800c40 <sys_page_alloc>
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 21                	js     801cca <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ca9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	50                   	push   %eax
  801cc2:	e8 3d f2 ff ff       	call   800f04 <fd2num>
  801cc7:	83 c4 10             	add    $0x10,%esp
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cd1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cd4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801cda:	e8 16 ef ff ff       	call   800bf5 <sys_getenvid>
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 0c             	pushl  0xc(%ebp)
  801ce5:	ff 75 08             	pushl  0x8(%ebp)
  801ce8:	53                   	push   %ebx
  801ce9:	50                   	push   %eax
  801cea:	68 38 25 80 00       	push   $0x802538
  801cef:	e8 14 e5 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cf4:	83 c4 18             	add    $0x18,%esp
  801cf7:	56                   	push   %esi
  801cf8:	ff 75 10             	pushl  0x10(%ebp)
  801cfb:	e8 b7 e4 ff ff       	call   8001b7 <vcprintf>
	cprintf("\n");
  801d00:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  801d07:	e8 fc e4 ff ff       	call   800208 <cprintf>
  801d0c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d0f:	cc                   	int3   
  801d10:	eb fd                	jmp    801d0f <_panic+0x43>
	...

00801d14 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	8b 75 08             	mov    0x8(%ebp),%esi
  801d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801d22:	85 c0                	test   %eax,%eax
  801d24:	74 0e                	je     801d34 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801d26:	83 ec 0c             	sub    $0xc,%esp
  801d29:	50                   	push   %eax
  801d2a:	e8 0c f0 ff ff       	call   800d3b <sys_ipc_recv>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	eb 10                	jmp    801d44 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	68 00 00 c0 ee       	push   $0xeec00000
  801d3c:	e8 fa ef ff ff       	call   800d3b <sys_ipc_recv>
  801d41:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801d44:	85 c0                	test   %eax,%eax
  801d46:	75 26                	jne    801d6e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d48:	85 f6                	test   %esi,%esi
  801d4a:	74 0a                	je     801d56 <ipc_recv+0x42>
  801d4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d51:	8b 40 74             	mov    0x74(%eax),%eax
  801d54:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d56:	85 db                	test   %ebx,%ebx
  801d58:	74 0a                	je     801d64 <ipc_recv+0x50>
  801d5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d5f:	8b 40 78             	mov    0x78(%eax),%eax
  801d62:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801d64:	a1 04 40 80 00       	mov    0x804004,%eax
  801d69:	8b 40 70             	mov    0x70(%eax),%eax
  801d6c:	eb 14                	jmp    801d82 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801d6e:	85 f6                	test   %esi,%esi
  801d70:	74 06                	je     801d78 <ipc_recv+0x64>
  801d72:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801d78:	85 db                	test   %ebx,%ebx
  801d7a:	74 06                	je     801d82 <ipc_recv+0x6e>
  801d7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	57                   	push   %edi
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d98:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801d9b:	85 db                	test   %ebx,%ebx
  801d9d:	75 25                	jne    801dc4 <ipc_send+0x3b>
  801d9f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801da4:	eb 1e                	jmp    801dc4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801da6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801da9:	75 07                	jne    801db2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801dab:	e8 69 ee ff ff       	call   800c19 <sys_yield>
  801db0:	eb 12                	jmp    801dc4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801db2:	50                   	push   %eax
  801db3:	68 5c 25 80 00       	push   $0x80255c
  801db8:	6a 43                	push   $0x43
  801dba:	68 6f 25 80 00       	push   $0x80256f
  801dbf:	e8 08 ff ff ff       	call   801ccc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	57                   	push   %edi
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 47 ef ff ff       	call   800d16 <sys_ipc_try_send>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	75 d0                	jne    801da6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	53                   	push   %ebx
  801de2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801de5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801deb:	74 22                	je     801e0f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ded:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801df2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	c1 e2 07             	shl    $0x7,%edx
  801dfe:	29 ca                	sub    %ecx,%edx
  801e00:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e06:	8b 52 50             	mov    0x50(%edx),%edx
  801e09:	39 da                	cmp    %ebx,%edx
  801e0b:	75 1d                	jne    801e2a <ipc_find_env+0x4c>
  801e0d:	eb 05                	jmp    801e14 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801e1b:	c1 e0 07             	shl    $0x7,%eax
  801e1e:	29 d0                	sub    %edx,%eax
  801e20:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e25:	8b 40 40             	mov    0x40(%eax),%eax
  801e28:	eb 0c                	jmp    801e36 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e2a:	40                   	inc    %eax
  801e2b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e30:	75 c0                	jne    801df2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e32:	66 b8 00 00          	mov    $0x0,%ax
}
  801e36:	5b                   	pop    %ebx
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    
  801e39:	00 00                	add    %al,(%eax)
	...

00801e3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e42:	89 c2                	mov    %eax,%edx
  801e44:	c1 ea 16             	shr    $0x16,%edx
  801e47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e4e:	f6 c2 01             	test   $0x1,%dl
  801e51:	74 1e                	je     801e71 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e53:	c1 e8 0c             	shr    $0xc,%eax
  801e56:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e5d:	a8 01                	test   $0x1,%al
  801e5f:	74 17                	je     801e78 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e61:	c1 e8 0c             	shr    $0xc,%eax
  801e64:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e6b:	ef 
  801e6c:	0f b7 c0             	movzwl %ax,%eax
  801e6f:	eb 0c                	jmp    801e7d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	eb 05                	jmp    801e7d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    
	...

00801e80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	83 ec 10             	sub    $0x10,%esp
  801e88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e8e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801e91:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e94:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e97:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	75 2e                	jne    801ecc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e9e:	39 f1                	cmp    %esi,%ecx
  801ea0:	77 5a                	ja     801efc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ea2:	85 c9                	test   %ecx,%ecx
  801ea4:	75 0b                	jne    801eb1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f1                	div    %ecx
  801eaf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801eb1:	31 d2                	xor    %edx,%edx
  801eb3:	89 f0                	mov    %esi,%eax
  801eb5:	f7 f1                	div    %ecx
  801eb7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eb9:	89 f8                	mov    %edi,%eax
  801ebb:	f7 f1                	div    %ecx
  801ebd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ebf:	89 f8                	mov    %edi,%eax
  801ec1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    
  801eca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ecc:	39 f0                	cmp    %esi,%eax
  801ece:	77 1c                	ja     801eec <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ed0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ed3:	83 f7 1f             	xor    $0x1f,%edi
  801ed6:	75 3c                	jne    801f14 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ed8:	39 f0                	cmp    %esi,%eax
  801eda:	0f 82 90 00 00 00    	jb     801f70 <__udivdi3+0xf0>
  801ee0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ee3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ee6:	0f 86 84 00 00 00    	jbe    801f70 <__udivdi3+0xf0>
  801eec:	31 f6                	xor    %esi,%esi
  801eee:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ef0:	89 f8                	mov    %edi,%eax
  801ef2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    
  801efb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801efc:	89 f2                	mov    %esi,%edx
  801efe:	89 f8                	mov    %edi,%eax
  801f00:	f7 f1                	div    %ecx
  801f02:	89 c7                	mov    %eax,%edi
  801f04:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f06:	89 f8                	mov    %edi,%eax
  801f08:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	5e                   	pop    %esi
  801f0e:	5f                   	pop    %edi
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    
  801f11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f14:	89 f9                	mov    %edi,%ecx
  801f16:	d3 e0                	shl    %cl,%eax
  801f18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f1b:	b8 20 00 00 00       	mov    $0x20,%eax
  801f20:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801f22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f25:	88 c1                	mov    %al,%cl
  801f27:	d3 ea                	shr    %cl,%edx
  801f29:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f2c:	09 ca                	or     %ecx,%edx
  801f2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801f31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f34:	89 f9                	mov    %edi,%ecx
  801f36:	d3 e2                	shl    %cl,%edx
  801f38:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801f3b:	89 f2                	mov    %esi,%edx
  801f3d:	88 c1                	mov    %al,%cl
  801f3f:	d3 ea                	shr    %cl,%edx
  801f41:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801f44:	89 f2                	mov    %esi,%edx
  801f46:	89 f9                	mov    %edi,%ecx
  801f48:	d3 e2                	shl    %cl,%edx
  801f4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f4d:	88 c1                	mov    %al,%cl
  801f4f:	d3 ee                	shr    %cl,%esi
  801f51:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f56:	89 f0                	mov    %esi,%eax
  801f58:	89 ca                	mov    %ecx,%edx
  801f5a:	f7 75 ec             	divl   -0x14(%ebp)
  801f5d:	89 d1                	mov    %edx,%ecx
  801f5f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f61:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f64:	39 d1                	cmp    %edx,%ecx
  801f66:	72 28                	jb     801f90 <__udivdi3+0x110>
  801f68:	74 1a                	je     801f84 <__udivdi3+0x104>
  801f6a:	89 f7                	mov    %esi,%edi
  801f6c:	31 f6                	xor    %esi,%esi
  801f6e:	eb 80                	jmp    801ef0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f70:	31 f6                	xor    %esi,%esi
  801f72:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f77:	89 f8                	mov    %edi,%eax
  801f79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    
  801f82:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f87:	89 f9                	mov    %edi,%ecx
  801f89:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f8b:	39 c2                	cmp    %eax,%edx
  801f8d:	73 db                	jae    801f6a <__udivdi3+0xea>
  801f8f:	90                   	nop
		{
		  q0--;
  801f90:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f93:	31 f6                	xor    %esi,%esi
  801f95:	e9 56 ff ff ff       	jmp    801ef0 <__udivdi3+0x70>
	...

00801f9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	57                   	push   %edi
  801fa0:	56                   	push   %esi
  801fa1:	83 ec 20             	sub    $0x20,%esp
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801faa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801fad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fb0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801fb9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	75 15                	jne    801fd4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801fbf:	39 f1                	cmp    %esi,%ecx
  801fc1:	0f 86 99 00 00 00    	jbe    802060 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801fc9:	89 d0                	mov    %edx,%eax
  801fcb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fcd:	83 c4 20             	add    $0x20,%esp
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	c9                   	leave  
  801fd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fd4:	39 f7                	cmp    %esi,%edi
  801fd6:	0f 87 a4 00 00 00    	ja     802080 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fdc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801fdf:	83 f0 1f             	xor    $0x1f,%eax
  801fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fe5:	0f 84 a1 00 00 00    	je     80208c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801feb:	89 f8                	mov    %edi,%eax
  801fed:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ff0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ff2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ff7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ffa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ffd:	89 f9                	mov    %edi,%ecx
  801fff:	d3 ea                	shr    %cl,%edx
  802001:	09 c2                	or     %eax,%edx
  802003:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802009:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80200c:	d3 e0                	shl    %cl,%eax
  80200e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802011:	89 f2                	mov    %esi,%edx
  802013:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802015:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802018:	d3 e0                	shl    %cl,%eax
  80201a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80201d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802020:	89 f9                	mov    %edi,%ecx
  802022:	d3 e8                	shr    %cl,%eax
  802024:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802026:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802028:	89 f2                	mov    %esi,%edx
  80202a:	f7 75 f0             	divl   -0x10(%ebp)
  80202d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80202f:	f7 65 f4             	mull   -0xc(%ebp)
  802032:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802035:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802037:	39 d6                	cmp    %edx,%esi
  802039:	72 71                	jb     8020ac <__umoddi3+0x110>
  80203b:	74 7f                	je     8020bc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80203d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802040:	29 c8                	sub    %ecx,%eax
  802042:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802044:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802047:	d3 e8                	shr    %cl,%eax
  802049:	89 f2                	mov    %esi,%edx
  80204b:	89 f9                	mov    %edi,%ecx
  80204d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80204f:	09 d0                	or     %edx,%eax
  802051:	89 f2                	mov    %esi,%edx
  802053:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802056:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802058:	83 c4 20             	add    $0x20,%esp
  80205b:	5e                   	pop    %esi
  80205c:	5f                   	pop    %edi
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    
  80205f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802060:	85 c9                	test   %ecx,%ecx
  802062:	75 0b                	jne    80206f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802064:	b8 01 00 00 00       	mov    $0x1,%eax
  802069:	31 d2                	xor    %edx,%edx
  80206b:	f7 f1                	div    %ecx
  80206d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80206f:	89 f0                	mov    %esi,%eax
  802071:	31 d2                	xor    %edx,%edx
  802073:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802075:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802078:	f7 f1                	div    %ecx
  80207a:	e9 4a ff ff ff       	jmp    801fc9 <__umoddi3+0x2d>
  80207f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802080:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802082:	83 c4 20             	add    $0x20,%esp
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	c9                   	leave  
  802088:	c3                   	ret    
  802089:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	72 05                	jb     802095 <__umoddi3+0xf9>
  802090:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802093:	77 0c                	ja     8020a1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802095:	89 f2                	mov    %esi,%edx
  802097:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209a:	29 c8                	sub    %ecx,%eax
  80209c:	19 fa                	sbb    %edi,%edx
  80209e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020a4:	83 c4 20             	add    $0x20,%esp
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    
  8020ab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8020af:	89 c1                	mov    %eax,%ecx
  8020b1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8020b4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8020b7:	eb 84                	jmp    80203d <__umoddi3+0xa1>
  8020b9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020bc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020bf:	72 eb                	jb     8020ac <__umoddi3+0x110>
  8020c1:	89 f2                	mov    %esi,%edx
  8020c3:	e9 75 ff ff ff       	jmp    80203d <__umoddi3+0xa1>
