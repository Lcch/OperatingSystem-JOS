
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
  80003a:	68 00 21 80 00       	push   $0x802100
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
  800068:	e8 13 0d 00 00       	call   800d80 <argstart>
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
  800092:	e8 22 0d 00 00       	call   800db9 <argnext>
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
  8000ae:	e8 4b 13 00 00       	call   8013fe <fstat>
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
  8000cf:	68 14 21 80 00       	push   $0x802114
  8000d4:	6a 01                	push   $0x1
  8000d6:	e8 b6 16 00 00       	call   801791 <fprintf>
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
  8000f1:	68 14 21 80 00       	push   $0x802114
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
  800162:	e8 7f 0f 00 00       	call   8010e6 <close_all>
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
  800270:	e8 33 1c 00 00       	call   801ea8 <__udivdi3>
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
  8002ac:	e8 13 1d 00 00       	call   801fc4 <__umoddi3>
  8002b1:	83 c4 14             	add    $0x14,%esp
  8002b4:	0f be 80 46 21 80 00 	movsbl 0x802146(%eax),%eax
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
  8003f8:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
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
  8004a4:	8b 04 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 1a                	jne    8004c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004af:	52                   	push   %edx
  8004b0:	68 5e 21 80 00       	push   $0x80215e
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
  8004ca:	68 17 25 80 00       	push   $0x802517
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
  800500:	c7 45 d0 57 21 80 00 	movl   $0x802157,-0x30(%ebp)
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
  800b6e:	68 3f 24 80 00       	push   $0x80243f
  800b73:	6a 42                	push   $0x42
  800b75:	68 5c 24 80 00       	push   $0x80245c
  800b7a:	e8 45 11 00 00       	call   801cc4 <_panic>

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

00800d80 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800d8c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800d8e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800d91:	83 3a 01             	cmpl   $0x1,(%edx)
  800d94:	7e 0b                	jle    800da1 <argstart+0x21>
  800d96:	85 c9                	test   %ecx,%ecx
  800d98:	75 0e                	jne    800da8 <argstart+0x28>
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	eb 0c                	jmp    800dad <argstart+0x2d>
  800da1:	ba 00 00 00 00       	mov    $0x0,%edx
  800da6:	eb 05                	jmp    800dad <argstart+0x2d>
  800da8:	ba 36 25 80 00       	mov    $0x802536,%edx
  800dad:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800db0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <argnext>:

int
argnext(struct Argstate *args)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dc5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dcc:	8b 43 08             	mov    0x8(%ebx),%eax
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	74 6c                	je     800e3f <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  800dd3:	80 38 00             	cmpb   $0x0,(%eax)
  800dd6:	75 4d                	jne    800e25 <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800dd8:	8b 0b                	mov    (%ebx),%ecx
  800dda:	83 39 01             	cmpl   $0x1,(%ecx)
  800ddd:	74 52                	je     800e31 <argnext+0x78>
		    || args->argv[1][0] != '-'
  800ddf:	8b 43 04             	mov    0x4(%ebx),%eax
  800de2:	8d 70 04             	lea    0x4(%eax),%esi
  800de5:	8b 50 04             	mov    0x4(%eax),%edx
  800de8:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800deb:	75 44                	jne    800e31 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  800ded:	8d 7a 01             	lea    0x1(%edx),%edi
  800df0:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  800df4:	74 3b                	je     800e31 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800df6:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	8b 11                	mov    (%ecx),%edx
  800dfe:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e05:	52                   	push   %edx
  800e06:	83 c0 08             	add    $0x8,%eax
  800e09:	50                   	push   %eax
  800e0a:	56                   	push   %esi
  800e0b:	e8 6f fb ff ff       	call   80097f <memmove>
		(*args->argc)--;
  800e10:	8b 03                	mov    (%ebx),%eax
  800e12:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e14:	8b 43 08             	mov    0x8(%ebx),%eax
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e1d:	75 06                	jne    800e25 <argnext+0x6c>
  800e1f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e23:	74 0c                	je     800e31 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e25:	8b 53 08             	mov    0x8(%ebx),%edx
  800e28:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e2b:	42                   	inc    %edx
  800e2c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e2f:	eb 13                	jmp    800e44 <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  800e31:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e3d:	eb 05                	jmp    800e44 <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e54:	8b 43 08             	mov    0x8(%ebx),%eax
  800e57:	85 c0                	test   %eax,%eax
  800e59:	74 57                	je     800eb2 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  800e5b:	80 38 00             	cmpb   $0x0,(%eax)
  800e5e:	74 0c                	je     800e6c <argnextvalue+0x20>
		args->argvalue = args->curarg;
  800e60:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e63:	c7 43 08 36 25 80 00 	movl   $0x802536,0x8(%ebx)
  800e6a:	eb 41                	jmp    800ead <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  800e6c:	8b 03                	mov    (%ebx),%eax
  800e6e:	83 38 01             	cmpl   $0x1,(%eax)
  800e71:	7e 2c                	jle    800e9f <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  800e73:	8b 53 04             	mov    0x4(%ebx),%edx
  800e76:	8d 4a 04             	lea    0x4(%edx),%ecx
  800e79:	8b 72 04             	mov    0x4(%edx),%esi
  800e7c:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	8b 00                	mov    (%eax),%eax
  800e84:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e8b:	50                   	push   %eax
  800e8c:	83 c2 08             	add    $0x8,%edx
  800e8f:	52                   	push   %edx
  800e90:	51                   	push   %ecx
  800e91:	e8 e9 fa ff ff       	call   80097f <memmove>
		(*args->argc)--;
  800e96:	8b 03                	mov    (%ebx),%eax
  800e98:	ff 08                	decl   (%eax)
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	eb 0e                	jmp    800ead <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  800e9f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ea6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ead:	8b 43 0c             	mov    0xc(%ebx),%eax
  800eb0:	eb 05                	jmp    800eb7 <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ec7:	8b 42 0c             	mov    0xc(%edx),%eax
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	75 0c                	jne    800eda <argvalue+0x1c>
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	52                   	push   %edx
  800ed2:	e8 75 ff ff ff       	call   800e4c <argnextvalue>
  800ed7:	83 c4 10             	add    $0x10,%esp
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eef:	ff 75 08             	pushl  0x8(%ebp)
  800ef2:	e8 e5 ff ff ff       	call   800edc <fd2num>
  800ef7:	83 c4 04             	add    $0x4,%esp
  800efa:	05 20 00 0d 00       	add    $0xd0020,%eax
  800eff:	c1 e0 0c             	shl    $0xc,%eax
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	53                   	push   %ebx
  800f08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f0b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f10:	a8 01                	test   $0x1,%al
  800f12:	74 34                	je     800f48 <fd_alloc+0x44>
  800f14:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f19:	a8 01                	test   $0x1,%al
  800f1b:	74 32                	je     800f4f <fd_alloc+0x4b>
  800f1d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 16             	shr    $0x16,%edx
  800f29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 1f                	je     800f54 <fd_alloc+0x50>
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 0c             	shr    $0xc,%edx
  800f3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	75 17                	jne    800f5d <fd_alloc+0x59>
  800f46:	eb 0c                	jmp    800f54 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f48:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f4d:	eb 05                	jmp    800f54 <fd_alloc+0x50>
  800f4f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f54:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f56:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5b:	eb 17                	jmp    800f74 <fd_alloc+0x70>
  800f5d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f62:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f67:	75 b9                	jne    800f22 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f6f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f74:	5b                   	pop    %ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f7d:	83 f8 1f             	cmp    $0x1f,%eax
  800f80:	77 36                	ja     800fb8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f82:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f87:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f8a:	89 c2                	mov    %eax,%edx
  800f8c:	c1 ea 16             	shr    $0x16,%edx
  800f8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f96:	f6 c2 01             	test   $0x1,%dl
  800f99:	74 24                	je     800fbf <fd_lookup+0x48>
  800f9b:	89 c2                	mov    %eax,%edx
  800f9d:	c1 ea 0c             	shr    $0xc,%edx
  800fa0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa7:	f6 c2 01             	test   $0x1,%dl
  800faa:	74 1a                	je     800fc6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800faf:	89 02                	mov    %eax,(%edx)
	return 0;
  800fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb6:	eb 13                	jmp    800fcb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fbd:	eb 0c                	jmp    800fcb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fbf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc4:	eb 05                	jmp    800fcb <fd_lookup+0x54>
  800fc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 04             	sub    $0x4,%esp
  800fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fda:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800fe0:	74 0d                	je     800fef <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	eb 14                	jmp    800ffd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800fe9:	39 0a                	cmp    %ecx,(%edx)
  800feb:	75 10                	jne    800ffd <dev_lookup+0x30>
  800fed:	eb 05                	jmp    800ff4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fef:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ff4:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ff6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffb:	eb 31                	jmp    80102e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffd:	40                   	inc    %eax
  800ffe:	8b 14 85 e8 24 80 00 	mov    0x8024e8(,%eax,4),%edx
  801005:	85 d2                	test   %edx,%edx
  801007:	75 e0                	jne    800fe9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801009:	a1 04 40 80 00       	mov    0x804004,%eax
  80100e:	8b 40 48             	mov    0x48(%eax),%eax
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	51                   	push   %ecx
  801015:	50                   	push   %eax
  801016:	68 6c 24 80 00       	push   $0x80246c
  80101b:	e8 e8 f1 ff ff       	call   800208 <cprintf>
	*dev = 0;
  801020:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	83 ec 20             	sub    $0x20,%esp
  80103b:	8b 75 08             	mov    0x8(%ebp),%esi
  80103e:	8a 45 0c             	mov    0xc(%ebp),%al
  801041:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801044:	56                   	push   %esi
  801045:	e8 92 fe ff ff       	call   800edc <fd2num>
  80104a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80104d:	89 14 24             	mov    %edx,(%esp)
  801050:	50                   	push   %eax
  801051:	e8 21 ff ff ff       	call   800f77 <fd_lookup>
  801056:	89 c3                	mov    %eax,%ebx
  801058:	83 c4 08             	add    $0x8,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 05                	js     801064 <fd_close+0x31>
	    || fd != fd2)
  80105f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801062:	74 0d                	je     801071 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801064:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801068:	75 48                	jne    8010b2 <fd_close+0x7f>
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106f:	eb 41                	jmp    8010b2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801077:	50                   	push   %eax
  801078:	ff 36                	pushl  (%esi)
  80107a:	e8 4e ff ff ff       	call   800fcd <dev_lookup>
  80107f:	89 c3                	mov    %eax,%ebx
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 1c                	js     8010a4 <fd_close+0x71>
		if (dev->dev_close)
  801088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108b:	8b 40 10             	mov    0x10(%eax),%eax
  80108e:	85 c0                	test   %eax,%eax
  801090:	74 0d                	je     80109f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	56                   	push   %esi
  801096:	ff d0                	call   *%eax
  801098:	89 c3                	mov    %eax,%ebx
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	eb 05                	jmp    8010a4 <fd_close+0x71>
		else
			r = 0;
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 db fb ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8010af:	83 c4 10             	add    $0x10,%esp
}
  8010b2:	89 d8                	mov    %ebx,%eax
  8010b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	ff 75 08             	pushl  0x8(%ebp)
  8010c8:	e8 aa fe ff ff       	call   800f77 <fd_lookup>
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 10                	js     8010e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	6a 01                	push   $0x1
  8010d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010dc:	e8 52 ff ff ff       	call   801033 <fd_close>
  8010e1:	83 c4 10             	add    $0x10,%esp
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <close_all>:

void
close_all(void)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	53                   	push   %ebx
  8010f6:	e8 c0 ff ff ff       	call   8010bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fb:	43                   	inc    %ebx
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	83 fb 20             	cmp    $0x20,%ebx
  801102:	75 ee                	jne    8010f2 <close_all+0xc>
		close(i);
}
  801104:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	83 ec 2c             	sub    $0x2c,%esp
  801112:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801115:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	ff 75 08             	pushl  0x8(%ebp)
  80111c:	e8 56 fe ff ff       	call   800f77 <fd_lookup>
  801121:	89 c3                	mov    %eax,%ebx
  801123:	83 c4 08             	add    $0x8,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	0f 88 c0 00 00 00    	js     8011ee <dup+0xe5>
		return r;
	close(newfdnum);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	57                   	push   %edi
  801132:	e8 84 ff ff ff       	call   8010bb <close>

	newfd = INDEX2FD(newfdnum);
  801137:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80113d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801140:	83 c4 04             	add    $0x4,%esp
  801143:	ff 75 e4             	pushl  -0x1c(%ebp)
  801146:	e8 a1 fd ff ff       	call   800eec <fd2data>
  80114b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80114d:	89 34 24             	mov    %esi,(%esp)
  801150:	e8 97 fd ff ff       	call   800eec <fd2data>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	c1 e8 16             	shr    $0x16,%eax
  801160:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801167:	a8 01                	test   $0x1,%al
  801169:	74 37                	je     8011a2 <dup+0x99>
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	c1 e8 0c             	shr    $0xc,%eax
  801170:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 26                	je     8011a2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	25 07 0e 00 00       	and    $0xe07,%eax
  80118b:	50                   	push   %eax
  80118c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118f:	6a 00                	push   $0x0
  801191:	53                   	push   %ebx
  801192:	6a 00                	push   $0x0
  801194:	e8 cb fa ff ff       	call   800c64 <sys_page_map>
  801199:	89 c3                	mov    %eax,%ebx
  80119b:	83 c4 20             	add    $0x20,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 2d                	js     8011cf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011ba:	52                   	push   %edx
  8011bb:	56                   	push   %esi
  8011bc:	6a 00                	push   $0x0
  8011be:	50                   	push   %eax
  8011bf:	6a 00                	push   $0x0
  8011c1:	e8 9e fa ff ff       	call   800c64 <sys_page_map>
  8011c6:	89 c3                	mov    %eax,%ebx
  8011c8:	83 c4 20             	add    $0x20,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	79 1d                	jns    8011ec <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	56                   	push   %esi
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 b0 fa ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011da:	83 c4 08             	add    $0x8,%esp
  8011dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011e0:	6a 00                	push   $0x0
  8011e2:	e8 a3 fa ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	eb 02                	jmp    8011ee <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011ec:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ee:	89 d8                	mov    %ebx,%eax
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	53                   	push   %ebx
  801207:	e8 6b fd ff ff       	call   800f77 <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 67                	js     80127a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	ff 30                	pushl  (%eax)
  80121f:	e8 a9 fd ff ff       	call   800fcd <dev_lookup>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 4f                	js     80127a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	8b 50 08             	mov    0x8(%eax),%edx
  801231:	83 e2 03             	and    $0x3,%edx
  801234:	83 fa 01             	cmp    $0x1,%edx
  801237:	75 21                	jne    80125a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801239:	a1 04 40 80 00       	mov    0x804004,%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	53                   	push   %ebx
  801245:	50                   	push   %eax
  801246:	68 ad 24 80 00       	push   $0x8024ad
  80124b:	e8 b8 ef ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801258:	eb 20                	jmp    80127a <read+0x82>
	}
	if (!dev->dev_read)
  80125a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125d:	8b 52 08             	mov    0x8(%edx),%edx
  801260:	85 d2                	test   %edx,%edx
  801262:	74 11                	je     801275 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	ff 75 10             	pushl  0x10(%ebp)
  80126a:	ff 75 0c             	pushl  0xc(%ebp)
  80126d:	50                   	push   %eax
  80126e:	ff d2                	call   *%edx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	eb 05                	jmp    80127a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801275:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80127a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128e:	85 f6                	test   %esi,%esi
  801290:	74 31                	je     8012c3 <readn+0x44>
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	89 f2                	mov    %esi,%edx
  8012a1:	29 c2                	sub    %eax,%edx
  8012a3:	52                   	push   %edx
  8012a4:	03 45 0c             	add    0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	57                   	push   %edi
  8012a9:	e8 4a ff ff ff       	call   8011f8 <read>
		if (m < 0)
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 17                	js     8012cc <readn+0x4d>
			return m;
		if (m == 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	74 11                	je     8012ca <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b9:	01 c3                	add    %eax,%ebx
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	39 f3                	cmp    %esi,%ebx
  8012bf:	72 db                	jb     80129c <readn+0x1d>
  8012c1:	eb 09                	jmp    8012cc <readn+0x4d>
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 02                	jmp    8012cc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012ca:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 14             	sub    $0x14,%esp
  8012db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	53                   	push   %ebx
  8012e3:	e8 8f fc ff ff       	call   800f77 <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 62                	js     801351 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	ff 30                	pushl  (%eax)
  8012fb:	e8 cd fc ff ff       	call   800fcd <dev_lookup>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 4a                	js     801351 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130e:	75 21                	jne    801331 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801310:	a1 04 40 80 00       	mov    0x804004,%eax
  801315:	8b 40 48             	mov    0x48(%eax),%eax
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	53                   	push   %ebx
  80131c:	50                   	push   %eax
  80131d:	68 c9 24 80 00       	push   $0x8024c9
  801322:	e8 e1 ee ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132f:	eb 20                	jmp    801351 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801331:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801334:	8b 52 0c             	mov    0xc(%edx),%edx
  801337:	85 d2                	test   %edx,%edx
  801339:	74 11                	je     80134c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	ff 75 10             	pushl  0x10(%ebp)
  801341:	ff 75 0c             	pushl  0xc(%ebp)
  801344:	50                   	push   %eax
  801345:	ff d2                	call   *%edx
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	eb 05                	jmp    801351 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <seek>:

int
seek(int fdnum, off_t offset)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 0f fc ff ff       	call   800f77 <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 0e                	js     80137d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80136f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801372:	8b 55 0c             	mov    0xc(%ebp),%edx
  801375:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	53                   	push   %ebx
  80138e:	e8 e4 fb ff ff       	call   800f77 <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 5f                	js     8013f9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	ff 30                	pushl  (%eax)
  8013a6:	e8 22 fc ff ff       	call   800fcd <dev_lookup>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 47                	js     8013f9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b9:	75 21                	jne    8013dc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013bb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c0:	8b 40 48             	mov    0x48(%eax),%eax
  8013c3:	83 ec 04             	sub    $0x4,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	50                   	push   %eax
  8013c8:	68 8c 24 80 00       	push   $0x80248c
  8013cd:	e8 36 ee ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013da:	eb 1d                	jmp    8013f9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013df:	8b 52 18             	mov    0x18(%edx),%edx
  8013e2:	85 d2                	test   %edx,%edx
  8013e4:	74 0e                	je     8013f4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	50                   	push   %eax
  8013ed:	ff d2                	call   *%edx
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	eb 05                	jmp    8013f9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 14             	sub    $0x14,%esp
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801408:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	ff 75 08             	pushl  0x8(%ebp)
  80140f:	e8 63 fb ff ff       	call   800f77 <fd_lookup>
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 52                	js     80146d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801425:	ff 30                	pushl  (%eax)
  801427:	e8 a1 fb ff ff       	call   800fcd <dev_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 3a                	js     80146d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801433:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801436:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143a:	74 2c                	je     801468 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80143f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801446:	00 00 00 
	stat->st_isdir = 0;
  801449:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801450:	00 00 00 
	stat->st_dev = dev;
  801453:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	53                   	push   %ebx
  80145d:	ff 75 f0             	pushl  -0x10(%ebp)
  801460:	ff 50 14             	call   *0x14(%eax)
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	eb 05                	jmp    80146d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801468:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80146d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	56                   	push   %esi
  801476:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	6a 00                	push   $0x0
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 8b 01 00 00       	call   80160f <open>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 1b                	js     8014a8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	50                   	push   %eax
  801494:	e8 65 ff ff ff       	call   8013fe <fstat>
  801499:	89 c6                	mov    %eax,%esi
	close(fd);
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	e8 18 fc ff ff       	call   8010bb <close>
	return r;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	89 f3                	mov    %esi,%ebx
}
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    
  8014b1:	00 00                	add    %al,(%eax)
	...

008014b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014bd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014c4:	75 12                	jne    8014d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	6a 01                	push   $0x1
  8014cb:	e8 39 09 00 00       	call   801e09 <ipc_find_env>
  8014d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8014d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014d8:	6a 07                	push   $0x7
  8014da:	68 00 50 80 00       	push   $0x805000
  8014df:	53                   	push   %ebx
  8014e0:	ff 35 00 40 80 00    	pushl  0x804000
  8014e6:	e8 c9 08 00 00       	call   801db4 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014eb:	83 c4 0c             	add    $0xc,%esp
  8014ee:	6a 00                	push   $0x0
  8014f0:	56                   	push   %esi
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 14 08 00 00       	call   801d0c <ipc_recv>
}
  8014f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	8b 40 0c             	mov    0xc(%eax),%eax
  80150f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801514:	ba 00 00 00 00       	mov    $0x0,%edx
  801519:	b8 05 00 00 00       	mov    $0x5,%eax
  80151e:	e8 91 ff ff ff       	call   8014b4 <fsipc>
  801523:	85 c0                	test   %eax,%eax
  801525:	78 39                	js     801560 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	68 f8 24 80 00       	push   $0x8024f8
  80152f:	e8 d4 ec ff ff       	call   800208 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801534:	83 c4 08             	add    $0x8,%esp
  801537:	68 00 50 80 00       	push   $0x805000
  80153c:	53                   	push   %ebx
  80153d:	e8 7c f2 ff ff       	call   8007be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801542:	a1 80 50 80 00       	mov    0x805080,%eax
  801547:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154d:	a1 84 50 80 00       	mov    0x805084,%eax
  801552:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80156b:	8b 45 08             	mov    0x8(%ebp),%eax
  80156e:	8b 40 0c             	mov    0xc(%eax),%eax
  801571:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801576:	ba 00 00 00 00       	mov    $0x0,%edx
  80157b:	b8 06 00 00 00       	mov    $0x6,%eax
  801580:	e8 2f ff ff ff       	call   8014b4 <fsipc>
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80158f:	8b 45 08             	mov    0x8(%ebp),%eax
  801592:	8b 40 0c             	mov    0xc(%eax),%eax
  801595:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8015aa:	e8 05 ff ff ff       	call   8014b4 <fsipc>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 51                	js     801606 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8015b5:	39 c6                	cmp    %eax,%esi
  8015b7:	73 19                	jae    8015d2 <devfile_read+0x4b>
  8015b9:	68 fe 24 80 00       	push   $0x8024fe
  8015be:	68 05 25 80 00       	push   $0x802505
  8015c3:	68 80 00 00 00       	push   $0x80
  8015c8:	68 1a 25 80 00       	push   $0x80251a
  8015cd:	e8 f2 06 00 00       	call   801cc4 <_panic>
	assert(r <= PGSIZE);
  8015d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015d7:	7e 19                	jle    8015f2 <devfile_read+0x6b>
  8015d9:	68 25 25 80 00       	push   $0x802525
  8015de:	68 05 25 80 00       	push   $0x802505
  8015e3:	68 81 00 00 00       	push   $0x81
  8015e8:	68 1a 25 80 00       	push   $0x80251a
  8015ed:	e8 d2 06 00 00       	call   801cc4 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	50                   	push   %eax
  8015f6:	68 00 50 80 00       	push   $0x805000
  8015fb:	ff 75 0c             	pushl  0xc(%ebp)
  8015fe:	e8 7c f3 ff ff       	call   80097f <memmove>
	return r;
  801603:	83 c4 10             	add    $0x10,%esp
}
  801606:	89 d8                	mov    %ebx,%eax
  801608:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80161a:	56                   	push   %esi
  80161b:	e8 4c f1 ff ff       	call   80076c <strlen>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801628:	7f 72                	jg     80169c <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	e8 ce f8 ff ff       	call   800f04 <fd_alloc>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 62                	js     8016a1 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	56                   	push   %esi
  801643:	68 00 50 80 00       	push   $0x805000
  801648:	e8 71 f1 ff ff       	call   8007be <strcpy>
	fsipcbuf.open.req_omode = mode;
  80164d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801650:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801658:	b8 01 00 00 00       	mov    $0x1,%eax
  80165d:	e8 52 fe ff ff       	call   8014b4 <fsipc>
  801662:	89 c3                	mov    %eax,%ebx
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	79 12                	jns    80167d <open+0x6e>
		fd_close(fd, 0);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	6a 00                	push   $0x0
  801670:	ff 75 f4             	pushl  -0xc(%ebp)
  801673:	e8 bb f9 ff ff       	call   801033 <fd_close>
		return r;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 24                	jmp    8016a1 <open+0x92>
	}


	cprintf("OPEN\n");
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	68 31 25 80 00       	push   $0x802531
  801685:	e8 7e eb ff ff       	call   800208 <cprintf>

	return fd2num(fd);
  80168a:	83 c4 04             	add    $0x4,%esp
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	e8 47 f8 ff ff       	call   800edc <fd2num>
  801695:	89 c3                	mov    %eax,%ebx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	eb 05                	jmp    8016a1 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80169c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8016a1:	89 d8                	mov    %ebx,%eax
  8016a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    
	...

008016ac <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8016b5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016b9:	7e 2e                	jle    8016e9 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	ff 70 04             	pushl  0x4(%eax)
  8016c1:	8d 40 10             	lea    0x10(%eax),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff 33                	pushl  (%ebx)
  8016c7:	e8 08 fc ff ff       	call   8012d4 <write>
		if (result > 0)
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	7e 03                	jle    8016d6 <writebuf+0x2a>
			b->result += result;
  8016d3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016d6:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016d9:	74 0e                	je     8016e9 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	7e 05                	jle    8016e6 <writebuf+0x3a>
  8016e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e6:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <putch>:

static void
putch(int ch, void *thunk)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8016fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fe:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801702:	40                   	inc    %eax
  801703:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801706:	3d 00 01 00 00       	cmp    $0x100,%eax
  80170b:	75 0e                	jne    80171b <putch+0x2d>
		writebuf(b);
  80170d:	89 d8                	mov    %ebx,%eax
  80170f:	e8 98 ff ff ff       	call   8016ac <writebuf>
		b->idx = 0;
  801714:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80171b:	83 c4 04             	add    $0x4,%esp
  80171e:	5b                   	pop    %ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801733:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80173a:	00 00 00 
	b.result = 0;
  80173d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801744:	00 00 00 
	b.error = 1;
  801747:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80174e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801751:	ff 75 10             	pushl  0x10(%ebp)
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	68 ee 16 80 00       	push   $0x8016ee
  801763:	e8 05 ec ff ff       	call   80036d <vprintfmt>
	if (b.idx > 0)
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801772:	7e 0b                	jle    80177f <vfprintf+0x5e>
		writebuf(&b);
  801774:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80177a:	e8 2d ff ff ff       	call   8016ac <writebuf>

	return (b.result ? b.result : b.error);
  80177f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801785:	85 c0                	test   %eax,%eax
  801787:	75 06                	jne    80178f <vfprintf+0x6e>
  801789:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801797:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80179a:	50                   	push   %eax
  80179b:	ff 75 0c             	pushl  0xc(%ebp)
  80179e:	ff 75 08             	pushl  0x8(%ebp)
  8017a1:	e8 7b ff ff ff       	call   801721 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <printf>:

int
printf(const char *fmt, ...)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017b1:	50                   	push   %eax
  8017b2:	ff 75 08             	pushl  0x8(%ebp)
  8017b5:	6a 01                	push   $0x1
  8017b7:	e8 65 ff ff ff       	call   801721 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    
	...

008017c0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	ff 75 08             	pushl  0x8(%ebp)
  8017ce:	e8 19 f7 ff ff       	call   800eec <fd2data>
  8017d3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8017d5:	83 c4 08             	add    $0x8,%esp
  8017d8:	68 37 25 80 00       	push   $0x802537
  8017dd:	56                   	push   %esi
  8017de:	e8 db ef ff ff       	call   8007be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8017e6:	2b 03                	sub    (%ebx),%eax
  8017e8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8017ee:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017f5:	00 00 00 
	stat->st_dev = &devpipe;
  8017f8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8017ff:	30 80 00 
	return 0;
}
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
  801807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801818:	53                   	push   %ebx
  801819:	6a 00                	push   $0x0
  80181b:	e8 6a f4 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801820:	89 1c 24             	mov    %ebx,(%esp)
  801823:	e8 c4 f6 ff ff       	call   800eec <fd2data>
  801828:	83 c4 08             	add    $0x8,%esp
  80182b:	50                   	push   %eax
  80182c:	6a 00                	push   $0x0
  80182e:	e8 57 f4 ff ff       	call   800c8a <sys_page_unmap>
}
  801833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	83 ec 1c             	sub    $0x1c,%esp
  801841:	89 c7                	mov    %eax,%edi
  801843:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801846:	a1 04 40 80 00       	mov    0x804004,%eax
  80184b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	57                   	push   %edi
  801852:	e8 0d 06 00 00       	call   801e64 <pageref>
  801857:	89 c6                	mov    %eax,%esi
  801859:	83 c4 04             	add    $0x4,%esp
  80185c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185f:	e8 00 06 00 00       	call   801e64 <pageref>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	39 c6                	cmp    %eax,%esi
  801869:	0f 94 c0             	sete   %al
  80186c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80186f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801875:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801878:	39 cb                	cmp    %ecx,%ebx
  80187a:	75 08                	jne    801884 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80187c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5f                   	pop    %edi
  801882:	c9                   	leave  
  801883:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801884:	83 f8 01             	cmp    $0x1,%eax
  801887:	75 bd                	jne    801846 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801889:	8b 42 58             	mov    0x58(%edx),%eax
  80188c:	6a 01                	push   $0x1
  80188e:	50                   	push   %eax
  80188f:	53                   	push   %ebx
  801890:	68 3e 25 80 00       	push   $0x80253e
  801895:	e8 6e e9 ff ff       	call   800208 <cprintf>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	eb a7                	jmp    801846 <_pipeisclosed+0xe>

0080189f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	57                   	push   %edi
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 28             	sub    $0x28,%esp
  8018a8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018ab:	56                   	push   %esi
  8018ac:	e8 3b f6 ff ff       	call   800eec <fd2data>
  8018b1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ba:	75 4a                	jne    801906 <devpipe_write+0x67>
  8018bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8018c1:	eb 56                	jmp    801919 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018c3:	89 da                	mov    %ebx,%edx
  8018c5:	89 f0                	mov    %esi,%eax
  8018c7:	e8 6c ff ff ff       	call   801838 <_pipeisclosed>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	75 4d                	jne    80191d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018d0:	e8 44 f3 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8018d8:	8b 13                	mov    (%ebx),%edx
  8018da:	83 c2 20             	add    $0x20,%edx
  8018dd:	39 d0                	cmp    %edx,%eax
  8018df:	73 e2                	jae    8018c3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018e9:	79 05                	jns    8018f0 <devpipe_write+0x51>
  8018eb:	4a                   	dec    %edx
  8018ec:	83 ca e0             	or     $0xffffffe0,%edx
  8018ef:	42                   	inc    %edx
  8018f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8018f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018fa:	40                   	inc    %eax
  8018fb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fe:	47                   	inc    %edi
  8018ff:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801902:	77 07                	ja     80190b <devpipe_write+0x6c>
  801904:	eb 13                	jmp    801919 <devpipe_write+0x7a>
  801906:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80190b:	8b 43 04             	mov    0x4(%ebx),%eax
  80190e:	8b 13                	mov    (%ebx),%edx
  801910:	83 c2 20             	add    $0x20,%edx
  801913:	39 d0                	cmp    %edx,%eax
  801915:	73 ac                	jae    8018c3 <devpipe_write+0x24>
  801917:	eb c8                	jmp    8018e1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801919:	89 f8                	mov    %edi,%eax
  80191b:	eb 05                	jmp    801922 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801922:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5f                   	pop    %edi
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	83 ec 18             	sub    $0x18,%esp
  801933:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801936:	57                   	push   %edi
  801937:	e8 b0 f5 ff ff       	call   800eec <fd2data>
  80193c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801945:	75 44                	jne    80198b <devpipe_read+0x61>
  801947:	be 00 00 00 00       	mov    $0x0,%esi
  80194c:	eb 4f                	jmp    80199d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80194e:	89 f0                	mov    %esi,%eax
  801950:	eb 54                	jmp    8019a6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801952:	89 da                	mov    %ebx,%edx
  801954:	89 f8                	mov    %edi,%eax
  801956:	e8 dd fe ff ff       	call   801838 <_pipeisclosed>
  80195b:	85 c0                	test   %eax,%eax
  80195d:	75 42                	jne    8019a1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80195f:	e8 b5 f2 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801964:	8b 03                	mov    (%ebx),%eax
  801966:	3b 43 04             	cmp    0x4(%ebx),%eax
  801969:	74 e7                	je     801952 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80196b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801970:	79 05                	jns    801977 <devpipe_read+0x4d>
  801972:	48                   	dec    %eax
  801973:	83 c8 e0             	or     $0xffffffe0,%eax
  801976:	40                   	inc    %eax
  801977:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80197b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801981:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801983:	46                   	inc    %esi
  801984:	39 75 10             	cmp    %esi,0x10(%ebp)
  801987:	77 07                	ja     801990 <devpipe_read+0x66>
  801989:	eb 12                	jmp    80199d <devpipe_read+0x73>
  80198b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801990:	8b 03                	mov    (%ebx),%eax
  801992:	3b 43 04             	cmp    0x4(%ebx),%eax
  801995:	75 d4                	jne    80196b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801997:	85 f6                	test   %esi,%esi
  801999:	75 b3                	jne    80194e <devpipe_read+0x24>
  80199b:	eb b5                	jmp    801952 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80199d:	89 f0                	mov    %esi,%eax
  80199f:	eb 05                	jmp    8019a6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5f                   	pop    %edi
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 28             	sub    $0x28,%esp
  8019b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 41 f5 ff ff       	call   800f04 <fd_alloc>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	0f 88 24 01 00 00    	js     801af4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	68 07 04 00 00       	push   $0x407
  8019d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 5e f2 ff ff       	call   800c40 <sys_page_alloc>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	0f 88 05 01 00 00    	js     801af4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	e8 09 f5 ff ff       	call   800f04 <fd_alloc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 dc 00 00 00    	js     801ae4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	68 07 04 00 00       	push   $0x407
  801a10:	ff 75 e0             	pushl  -0x20(%ebp)
  801a13:	6a 00                	push   $0x0
  801a15:	e8 26 f2 ff ff       	call   800c40 <sys_page_alloc>
  801a1a:	89 c3                	mov    %eax,%ebx
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	0f 88 bd 00 00 00    	js     801ae4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a2d:	e8 ba f4 ff ff       	call   800eec <fd2data>
  801a32:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a34:	83 c4 0c             	add    $0xc,%esp
  801a37:	68 07 04 00 00       	push   $0x407
  801a3c:	50                   	push   %eax
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 fc f1 ff ff       	call   800c40 <sys_page_alloc>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 83 00 00 00    	js     801ad4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 e0             	pushl  -0x20(%ebp)
  801a57:	e8 90 f4 ff ff       	call   800eec <fd2data>
  801a5c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a63:	50                   	push   %eax
  801a64:	6a 00                	push   $0x0
  801a66:	56                   	push   %esi
  801a67:	6a 00                	push   $0x0
  801a69:	e8 f6 f1 ff ff       	call   800c64 <sys_page_map>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 20             	add    $0x20,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 4f                	js     801ac6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a77:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a80:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a8c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a95:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a9a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa7:	e8 30 f4 ff ff       	call   800edc <fd2num>
  801aac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801aae:	83 c4 04             	add    $0x4,%esp
  801ab1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab4:	e8 23 f4 ff ff       	call   800edc <fd2num>
  801ab9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac4:	eb 2e                	jmp    801af4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	56                   	push   %esi
  801aca:	6a 00                	push   $0x0
  801acc:	e8 b9 f1 ff ff       	call   800c8a <sys_page_unmap>
  801ad1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ad4:	83 ec 08             	sub    $0x8,%esp
  801ad7:	ff 75 e0             	pushl  -0x20(%ebp)
  801ada:	6a 00                	push   $0x0
  801adc:	e8 a9 f1 ff ff       	call   800c8a <sys_page_unmap>
  801ae1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aea:	6a 00                	push   $0x0
  801aec:	e8 99 f1 ff ff       	call   800c8a <sys_page_unmap>
  801af1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801af4:	89 d8                	mov    %ebx,%eax
  801af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b07:	50                   	push   %eax
  801b08:	ff 75 08             	pushl  0x8(%ebp)
  801b0b:	e8 67 f4 ff ff       	call   800f77 <fd_lookup>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 18                	js     801b2f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	e8 ca f3 ff ff       	call   800eec <fd2data>
	return _pipeisclosed(fd, p);
  801b22:	89 c2                	mov    %eax,%edx
  801b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b27:	e8 0c fd ff ff       	call   801838 <_pipeisclosed>
  801b2c:	83 c4 10             	add    $0x10,%esp
}
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    
  801b31:	00 00                	add    %al,(%eax)
	...

00801b34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b44:	68 56 25 80 00       	push   $0x802556
  801b49:	ff 75 0c             	pushl  0xc(%ebp)
  801b4c:	e8 6d ec ff ff       	call   8007be <strcpy>
	return 0;
}
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	57                   	push   %edi
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b68:	74 45                	je     801baf <devcons_write+0x57>
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b74:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b7d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b7f:	83 fb 7f             	cmp    $0x7f,%ebx
  801b82:	76 05                	jbe    801b89 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b84:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	53                   	push   %ebx
  801b8d:	03 45 0c             	add    0xc(%ebp),%eax
  801b90:	50                   	push   %eax
  801b91:	57                   	push   %edi
  801b92:	e8 e8 ed ff ff       	call   80097f <memmove>
		sys_cputs(buf, m);
  801b97:	83 c4 08             	add    $0x8,%esp
  801b9a:	53                   	push   %ebx
  801b9b:	57                   	push   %edi
  801b9c:	e8 e8 ef ff ff       	call   800b89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba1:	01 de                	add    %ebx,%esi
  801ba3:	89 f0                	mov    %esi,%eax
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bab:	72 cd                	jb     801b7a <devcons_write+0x22>
  801bad:	eb 05                	jmp    801bb4 <devcons_write+0x5c>
  801baf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bb4:	89 f0                	mov    %esi,%eax
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bc8:	75 07                	jne    801bd1 <devcons_read+0x13>
  801bca:	eb 25                	jmp    801bf1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bcc:	e8 48 f0 ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bd1:	e8 d9 ef ff ff       	call   800baf <sys_cgetc>
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	74 f2                	je     801bcc <devcons_read+0xe>
  801bda:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 1d                	js     801bfd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801be0:	83 f8 04             	cmp    $0x4,%eax
  801be3:	74 13                	je     801bf8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	88 10                	mov    %dl,(%eax)
	return 1;
  801bea:	b8 01 00 00 00       	mov    $0x1,%eax
  801bef:	eb 0c                	jmp    801bfd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf6:	eb 05                	jmp    801bfd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c0b:	6a 01                	push   $0x1
  801c0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	e8 73 ef ff ff       	call   800b89 <sys_cputs>
  801c16:	83 c4 10             	add    $0x10,%esp
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <getchar>:

int
getchar(void)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c21:	6a 01                	push   $0x1
  801c23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c26:	50                   	push   %eax
  801c27:	6a 00                	push   $0x0
  801c29:	e8 ca f5 ff ff       	call   8011f8 <read>
	if (r < 0)
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 0f                	js     801c44 <getchar+0x29>
		return r;
	if (r < 1)
  801c35:	85 c0                	test   %eax,%eax
  801c37:	7e 06                	jle    801c3f <getchar+0x24>
		return -E_EOF;
	return c;
  801c39:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c3d:	eb 05                	jmp    801c44 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c3f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4f:	50                   	push   %eax
  801c50:	ff 75 08             	pushl  0x8(%ebp)
  801c53:	e8 1f f3 ff ff       	call   800f77 <fd_lookup>
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 11                	js     801c70 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c68:	39 10                	cmp    %edx,(%eax)
  801c6a:	0f 94 c0             	sete   %al
  801c6d:	0f b6 c0             	movzbl %al,%eax
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <opencons>:

int
opencons(void)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7b:	50                   	push   %eax
  801c7c:	e8 83 f2 ff ff       	call   800f04 <fd_alloc>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 3a                	js     801cc2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c88:	83 ec 04             	sub    $0x4,%esp
  801c8b:	68 07 04 00 00       	push   $0x407
  801c90:	ff 75 f4             	pushl  -0xc(%ebp)
  801c93:	6a 00                	push   $0x0
  801c95:	e8 a6 ef ff ff       	call   800c40 <sys_page_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 21                	js     801cc2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ca1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	50                   	push   %eax
  801cba:	e8 1d f2 ff ff       	call   800edc <fd2num>
  801cbf:	83 c4 10             	add    $0x10,%esp
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cc9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ccc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801cd2:	e8 1e ef ff ff       	call   800bf5 <sys_getenvid>
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	ff 75 0c             	pushl  0xc(%ebp)
  801cdd:	ff 75 08             	pushl  0x8(%ebp)
  801ce0:	53                   	push   %ebx
  801ce1:	50                   	push   %eax
  801ce2:	68 64 25 80 00       	push   $0x802564
  801ce7:	e8 1c e5 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cec:	83 c4 18             	add    $0x18,%esp
  801cef:	56                   	push   %esi
  801cf0:	ff 75 10             	pushl  0x10(%ebp)
  801cf3:	e8 bf e4 ff ff       	call   8001b7 <vcprintf>
	cprintf("\n");
  801cf8:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  801cff:	e8 04 e5 ff ff       	call   800208 <cprintf>
  801d04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d07:	cc                   	int3   
  801d08:	eb fd                	jmp    801d07 <_panic+0x43>
	...

00801d0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d1b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	57                   	push   %edi
  801d21:	68 88 25 80 00       	push   $0x802588
  801d26:	e8 dd e4 ff ff       	call   800208 <cprintf>
	int r;
	if (pg != NULL) {
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 db                	test   %ebx,%ebx
  801d30:	74 28                	je     801d5a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	68 98 25 80 00       	push   $0x802598
  801d3a:	e8 c9 e4 ff ff       	call   800208 <cprintf>
		r = sys_ipc_recv(pg);
  801d3f:	89 1c 24             	mov    %ebx,(%esp)
  801d42:	e8 f4 ef ff ff       	call   800d3b <sys_ipc_recv>
  801d47:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801d49:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  801d50:	e8 b3 e4 ff ff       	call   800208 <cprintf>
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	eb 12                	jmp    801d6c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	68 00 00 c0 ee       	push   $0xeec00000
  801d62:	e8 d4 ef ff ff       	call   800d3b <sys_ipc_recv>
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801d6c:	85 db                	test   %ebx,%ebx
  801d6e:	75 26                	jne    801d96 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d70:	85 ff                	test   %edi,%edi
  801d72:	74 0a                	je     801d7e <ipc_recv+0x72>
  801d74:	a1 04 40 80 00       	mov    0x804004,%eax
  801d79:	8b 40 74             	mov    0x74(%eax),%eax
  801d7c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d7e:	85 f6                	test   %esi,%esi
  801d80:	74 0a                	je     801d8c <ipc_recv+0x80>
  801d82:	a1 04 40 80 00       	mov    0x804004,%eax
  801d87:	8b 40 78             	mov    0x78(%eax),%eax
  801d8a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801d8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d91:	8b 58 70             	mov    0x70(%eax),%ebx
  801d94:	eb 14                	jmp    801daa <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801d96:	85 ff                	test   %edi,%edi
  801d98:	74 06                	je     801da0 <ipc_recv+0x94>
  801d9a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801da0:	85 f6                	test   %esi,%esi
  801da2:	74 06                	je     801daa <ipc_recv+0x9e>
  801da4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801daa:	89 d8                	mov    %ebx,%eax
  801dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc3:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801dc6:	85 db                	test   %ebx,%ebx
  801dc8:	75 25                	jne    801def <ipc_send+0x3b>
  801dca:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801dcf:	eb 1e                	jmp    801def <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801dd1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dd4:	75 07                	jne    801ddd <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801dd6:	e8 3e ee ff ff       	call   800c19 <sys_yield>
  801ddb:	eb 12                	jmp    801def <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ddd:	50                   	push   %eax
  801dde:	68 9f 25 80 00       	push   $0x80259f
  801de3:	6a 45                	push   $0x45
  801de5:	68 b2 25 80 00       	push   $0x8025b2
  801dea:	e8 d5 fe ff ff       	call   801cc4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	57                   	push   %edi
  801df2:	ff 75 08             	pushl  0x8(%ebp)
  801df5:	e8 1c ef ff ff       	call   800d16 <sys_ipc_try_send>
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	75 d0                	jne    801dd1 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	53                   	push   %ebx
  801e0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e10:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801e16:	74 22                	je     801e3a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e18:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801e1d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	c1 e2 07             	shl    $0x7,%edx
  801e29:	29 ca                	sub    %ecx,%edx
  801e2b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e31:	8b 52 50             	mov    0x50(%edx),%edx
  801e34:	39 da                	cmp    %ebx,%edx
  801e36:	75 1d                	jne    801e55 <ipc_find_env+0x4c>
  801e38:	eb 05                	jmp    801e3f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e3f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801e46:	c1 e0 07             	shl    $0x7,%eax
  801e49:	29 d0                	sub    %edx,%eax
  801e4b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e50:	8b 40 40             	mov    0x40(%eax),%eax
  801e53:	eb 0c                	jmp    801e61 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e55:	40                   	inc    %eax
  801e56:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e5b:	75 c0                	jne    801e1d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e5d:	66 b8 00 00          	mov    $0x0,%ax
}
  801e61:	5b                   	pop    %ebx
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e6a:	89 c2                	mov    %eax,%edx
  801e6c:	c1 ea 16             	shr    $0x16,%edx
  801e6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e76:	f6 c2 01             	test   $0x1,%dl
  801e79:	74 1e                	je     801e99 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e7b:	c1 e8 0c             	shr    $0xc,%eax
  801e7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e85:	a8 01                	test   $0x1,%al
  801e87:	74 17                	je     801ea0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e89:	c1 e8 0c             	shr    $0xc,%eax
  801e8c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e93:	ef 
  801e94:	0f b7 c0             	movzwl %ax,%eax
  801e97:	eb 0c                	jmp    801ea5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e99:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9e:	eb 05                	jmp    801ea5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    
	...

00801ea8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	57                   	push   %edi
  801eac:	56                   	push   %esi
  801ead:	83 ec 10             	sub    $0x10,%esp
  801eb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eb6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801eb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ebc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ebf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	75 2e                	jne    801ef4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ec6:	39 f1                	cmp    %esi,%ecx
  801ec8:	77 5a                	ja     801f24 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801eca:	85 c9                	test   %ecx,%ecx
  801ecc:	75 0b                	jne    801ed9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ece:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed3:	31 d2                	xor    %edx,%edx
  801ed5:	f7 f1                	div    %ecx
  801ed7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ed9:	31 d2                	xor    %edx,%edx
  801edb:	89 f0                	mov    %esi,%eax
  801edd:	f7 f1                	div    %ecx
  801edf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ee1:	89 f8                	mov    %edi,%eax
  801ee3:	f7 f1                	div    %ecx
  801ee5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ee7:	89 f8                	mov    %edi,%eax
  801ee9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    
  801ef2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ef4:	39 f0                	cmp    %esi,%eax
  801ef6:	77 1c                	ja     801f14 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ef8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801efb:	83 f7 1f             	xor    $0x1f,%edi
  801efe:	75 3c                	jne    801f3c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f00:	39 f0                	cmp    %esi,%eax
  801f02:	0f 82 90 00 00 00    	jb     801f98 <__udivdi3+0xf0>
  801f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f0b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801f0e:	0f 86 84 00 00 00    	jbe    801f98 <__udivdi3+0xf0>
  801f14:	31 f6                	xor    %esi,%esi
  801f16:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f18:	89 f8                	mov    %edi,%eax
  801f1a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	5e                   	pop    %esi
  801f20:	5f                   	pop    %edi
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    
  801f23:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f24:	89 f2                	mov    %esi,%edx
  801f26:	89 f8                	mov    %edi,%eax
  801f28:	f7 f1                	div    %ecx
  801f2a:	89 c7                	mov    %eax,%edi
  801f2c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f2e:	89 f8                	mov    %edi,%eax
  801f30:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    
  801f39:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f3c:	89 f9                	mov    %edi,%ecx
  801f3e:	d3 e0                	shl    %cl,%eax
  801f40:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f43:	b8 20 00 00 00       	mov    $0x20,%eax
  801f48:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801f4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f4d:	88 c1                	mov    %al,%cl
  801f4f:	d3 ea                	shr    %cl,%edx
  801f51:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f54:	09 ca                	or     %ecx,%edx
  801f56:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801f59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f5c:	89 f9                	mov    %edi,%ecx
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801f63:	89 f2                	mov    %esi,%edx
  801f65:	88 c1                	mov    %al,%cl
  801f67:	d3 ea                	shr    %cl,%edx
  801f69:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801f6c:	89 f2                	mov    %esi,%edx
  801f6e:	89 f9                	mov    %edi,%ecx
  801f70:	d3 e2                	shl    %cl,%edx
  801f72:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f75:	88 c1                	mov    %al,%cl
  801f77:	d3 ee                	shr    %cl,%esi
  801f79:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f7b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f7e:	89 f0                	mov    %esi,%eax
  801f80:	89 ca                	mov    %ecx,%edx
  801f82:	f7 75 ec             	divl   -0x14(%ebp)
  801f85:	89 d1                	mov    %edx,%ecx
  801f87:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f89:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f8c:	39 d1                	cmp    %edx,%ecx
  801f8e:	72 28                	jb     801fb8 <__udivdi3+0x110>
  801f90:	74 1a                	je     801fac <__udivdi3+0x104>
  801f92:	89 f7                	mov    %esi,%edi
  801f94:	31 f6                	xor    %esi,%esi
  801f96:	eb 80                	jmp    801f18 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f98:	31 f6                	xor    %esi,%esi
  801f9a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    
  801faa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801fac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801faf:	89 f9                	mov    %edi,%ecx
  801fb1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fb3:	39 c2                	cmp    %eax,%edx
  801fb5:	73 db                	jae    801f92 <__udivdi3+0xea>
  801fb7:	90                   	nop
		{
		  q0--;
  801fb8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fbb:	31 f6                	xor    %esi,%esi
  801fbd:	e9 56 ff ff ff       	jmp    801f18 <__udivdi3+0x70>
	...

00801fc4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	57                   	push   %edi
  801fc8:	56                   	push   %esi
  801fc9:	83 ec 20             	sub    $0x20,%esp
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fd2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801fd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801fe1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fe3:	85 ff                	test   %edi,%edi
  801fe5:	75 15                	jne    801ffc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801fe7:	39 f1                	cmp    %esi,%ecx
  801fe9:	0f 86 99 00 00 00    	jbe    802088 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fef:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ff1:	89 d0                	mov    %edx,%eax
  801ff3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ff5:	83 c4 20             	add    $0x20,%esp
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ffc:	39 f7                	cmp    %esi,%edi
  801ffe:	0f 87 a4 00 00 00    	ja     8020a8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802004:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802007:	83 f0 1f             	xor    $0x1f,%eax
  80200a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80200d:	0f 84 a1 00 00 00    	je     8020b4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802013:	89 f8                	mov    %edi,%eax
  802015:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802018:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80201a:	bf 20 00 00 00       	mov    $0x20,%edi
  80201f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802022:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 ea                	shr    %cl,%edx
  802029:	09 c2                	or     %eax,%edx
  80202b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80202e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802031:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802034:	d3 e0                	shl    %cl,%eax
  802036:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802039:	89 f2                	mov    %esi,%edx
  80203b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80203d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802040:	d3 e0                	shl    %cl,%eax
  802042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802045:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802048:	89 f9                	mov    %edi,%ecx
  80204a:	d3 e8                	shr    %cl,%eax
  80204c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80204e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802050:	89 f2                	mov    %esi,%edx
  802052:	f7 75 f0             	divl   -0x10(%ebp)
  802055:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802057:	f7 65 f4             	mull   -0xc(%ebp)
  80205a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80205d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80205f:	39 d6                	cmp    %edx,%esi
  802061:	72 71                	jb     8020d4 <__umoddi3+0x110>
  802063:	74 7f                	je     8020e4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802068:	29 c8                	sub    %ecx,%eax
  80206a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80206c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80206f:	d3 e8                	shr    %cl,%eax
  802071:	89 f2                	mov    %esi,%edx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802077:	09 d0                	or     %edx,%eax
  802079:	89 f2                	mov    %esi,%edx
  80207b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80207e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802080:	83 c4 20             	add    $0x20,%esp
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	c9                   	leave  
  802086:	c3                   	ret    
  802087:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802088:	85 c9                	test   %ecx,%ecx
  80208a:	75 0b                	jne    802097 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80208c:	b8 01 00 00 00       	mov    $0x1,%eax
  802091:	31 d2                	xor    %edx,%edx
  802093:	f7 f1                	div    %ecx
  802095:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802097:	89 f0                	mov    %esi,%eax
  802099:	31 d2                	xor    %edx,%edx
  80209b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80209d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a0:	f7 f1                	div    %ecx
  8020a2:	e9 4a ff ff ff       	jmp    801ff1 <__umoddi3+0x2d>
  8020a7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8020a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020aa:	83 c4 20             	add    $0x20,%esp
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    
  8020b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020b4:	39 f7                	cmp    %esi,%edi
  8020b6:	72 05                	jb     8020bd <__umoddi3+0xf9>
  8020b8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8020bb:	77 0c                	ja     8020c9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020bd:	89 f2                	mov    %esi,%edx
  8020bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c2:	29 c8                	sub    %ecx,%eax
  8020c4:	19 fa                	sbb    %edi,%edx
  8020c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020cc:	83 c4 20             	add    $0x20,%esp
  8020cf:	5e                   	pop    %esi
  8020d0:	5f                   	pop    %edi
  8020d1:	c9                   	leave  
  8020d2:	c3                   	ret    
  8020d3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8020d7:	89 c1                	mov    %eax,%ecx
  8020d9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8020dc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8020df:	eb 84                	jmp    802065 <__umoddi3+0xa1>
  8020e1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020e7:	72 eb                	jb     8020d4 <__umoddi3+0x110>
  8020e9:	89 f2                	mov    %esi,%edx
  8020eb:	e9 75 ff ff ff       	jmp    802065 <__umoddi3+0xa1>
