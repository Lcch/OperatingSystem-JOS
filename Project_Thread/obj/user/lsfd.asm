
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
  80003f:	e8 c0 01 00 00       	call   800204 <cprintf>
	exit();
  800044:	e8 0f 01 00 00       	call   800158 <exit>
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
  800068:	e8 7b 0d 00 00       	call   800de8 <argstart>
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
  800092:	e8 8a 0d 00 00       	call   800e21 <argnext>
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
  8000ae:	e8 b3 13 00 00       	call   801466 <fstat>
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
  8000d6:	e8 fe 16 00 00       	call   8017d9 <fprintf>
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
  8000f6:	e8 09 01 00 00       	call   800204 <cprintf>
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
  800117:	e8 d5 0a 00 00       	call   800bf1 <sys_getenvid>
  80011c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800121:	89 c2                	mov    %eax,%edx
  800123:	c1 e2 07             	shl    $0x7,%edx
  800126:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80012d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	85 f6                	test   %esi,%esi
  800134:	7e 07                	jle    80013d <libmain+0x31>
		binaryname = argv[0];
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	53                   	push   %ebx
  800141:	56                   	push   %esi
  800142:	e8 07 ff ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  800147:	e8 0c 00 00 00       	call   800158 <exit>
  80014c:	83 c4 10             	add    $0x10,%esp
}
  80014f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	c9                   	leave  
  800155:	c3                   	ret    
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015e:	e8 eb 0f 00 00       	call   80114e <close_all>
	sys_env_destroy(0);
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	6a 00                	push   $0x0
  800168:	e8 62 0a 00 00       	call   800bcf <sys_env_destroy>
  80016d:	83 c4 10             	add    $0x10,%esp
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    
	...

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 03                	mov    (%ebx),%eax
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800187:	40                   	inc    %eax
  800188:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	75 1a                	jne    8001ab <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800191:	83 ec 08             	sub    $0x8,%esp
  800194:	68 ff 00 00 00       	push   $0xff
  800199:	8d 43 08             	lea    0x8(%ebx),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 e3 09 00 00       	call   800b85 <sys_cputs>
		b->idx = 0;
  8001a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ab:	ff 43 04             	incl   0x4(%ebx)
}
  8001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	ff 75 08             	pushl  0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 74 01 80 00       	push   $0x800174
  8001e2:	e8 82 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 89 09 00 00       	call   800b85 <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	50                   	push   %eax
  80020e:	ff 75 08             	pushl  0x8(%ebp)
  800211:	e8 9d ff ff ff       	call   8001b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 2c             	sub    $0x2c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800238:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80023e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800245:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800248:	72 0c                	jb     800256 <printnum+0x3e>
  80024a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024d:	76 07                	jbe    800256 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f 31                	jg     800285 <printnum+0x6d>
  800254:	eb 3f                	jmp    800295 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	57                   	push   %edi
  80025a:	4b                   	dec    %ebx
  80025b:	53                   	push   %ebx
  80025c:	50                   	push   %eax
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	ff 75 d4             	pushl  -0x2c(%ebp)
  800263:	ff 75 d0             	pushl  -0x30(%ebp)
  800266:	ff 75 dc             	pushl  -0x24(%ebp)
  800269:	ff 75 d8             	pushl  -0x28(%ebp)
  80026c:	e8 3f 1c 00 00       	call   801eb0 <__udivdi3>
  800271:	83 c4 18             	add    $0x18,%esp
  800274:	52                   	push   %edx
  800275:	50                   	push   %eax
  800276:	89 f2                	mov    %esi,%edx
  800278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027b:	e8 98 ff ff ff       	call   800218 <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 10                	jmp    800295 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	57                   	push   %edi
  80028a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028d:	4b                   	dec    %ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f f0                	jg     800285 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029f:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 1f 1d 00 00       	call   801fcc <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 46 21 80 00 	movsbl 0x802146(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002bb:	83 c4 10             	add    $0x10,%esp
}
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800303:	83 fa 01             	cmp    $0x1,%edx
  800306:	7e 0e                	jle    800316 <getint+0x16>
		return va_arg(*ap, long long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	8b 52 04             	mov    0x4(%edx),%edx
  800314:	eb 1a                	jmp    800330 <getint+0x30>
	else if (lflag)
  800316:	85 d2                	test   %edx,%edx
  800318:	74 0c                	je     800326 <getint+0x26>
		return va_arg(*ap, long);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	99                   	cltd   
  800324:	eb 0a                	jmp    800330 <getint+0x30>
	else
		return va_arg(*ap, int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800338:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	3b 50 04             	cmp    0x4(%eax),%edx
  800340:	73 08                	jae    80034a <sprintputch+0x18>
		*b->buf++ = ch;
  800342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800345:	88 0a                	mov    %cl,(%edx)
  800347:	42                   	inc    %edx
  800348:	89 10                	mov    %edx,(%eax)
}
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
  800364:	83 c4 10             	add    $0x10,%esp
}
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800375:	8b 75 10             	mov    0x10(%ebp),%esi
  800378:	eb 13                	jmp    80038d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037a:	85 c0                	test   %eax,%eax
  80037c:	0f 84 6d 03 00 00    	je     8006ef <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	57                   	push   %edi
  800386:	50                   	push   %eax
  800387:	ff 55 08             	call   *0x8(%ebp)
  80038a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e4                	jne    80037a <vprintfmt+0x11>
  800396:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80039a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003a8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	eb 28                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003bc:	eb 20                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c4:	eb 18                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cf:	eb 0d                	jmp    8003de <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8a 06                	mov    (%esi),%al
  8003e0:	0f b6 d0             	movzbl %al,%edx
  8003e3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003e6:	83 e8 23             	sub    $0x23,%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 e0 02 00 00    	ja     8006d1 <vprintfmt+0x368>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	83 ea 30             	sub    $0x30,%edx
  8003fe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800401:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800404:	8d 50 d0             	lea    -0x30(%eax),%edx
  800407:	83 fa 09             	cmp    $0x9,%edx
  80040a:	77 44                	ja     800450 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	89 de                	mov    %ebx,%esi
  80040e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800412:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800415:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800419:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80041c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80041f:	83 fb 09             	cmp    $0x9,%ebx
  800422:	76 ed                	jbe    800411 <vprintfmt+0xa8>
  800424:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800427:	eb 29                	jmp    800452 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	8b 00                	mov    (%eax),%eax
  800434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800439:	eb 17                	jmp    800452 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	78 85                	js     8003c6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 de                	mov    %ebx,%esi
  800443:	eb 99                	jmp    8003de <vprintfmt+0x75>
  800445:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800447:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80044e:	eb 8e                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800452:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800456:	79 86                	jns    8003de <vprintfmt+0x75>
  800458:	e9 74 ff ff ff       	jmp    8003d1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	89 de                	mov    %ebx,%esi
  800460:	e9 79 ff ff ff       	jmp    8003de <vprintfmt+0x75>
  800465:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	57                   	push   %edi
  800475:	ff 30                	pushl  (%eax)
  800477:	ff 55 08             	call   *0x8(%ebp)
			break;
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800480:	e9 08 ff ff ff       	jmp    80038d <vprintfmt+0x24>
  800485:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 50 04             	lea    0x4(%eax),%edx
  80048e:	89 55 14             	mov    %edx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	79 02                	jns    800499 <vprintfmt+0x130>
  800497:	f7 d8                	neg    %eax
  800499:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 0f             	cmp    $0xf,%eax
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x142>
  8004a0:	8b 04 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	75 1a                	jne    8004c5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	52                   	push   %edx
  8004ac:	68 5e 21 80 00       	push   $0x80215e
  8004b1:	57                   	push   %edi
  8004b2:	ff 75 08             	pushl  0x8(%ebp)
  8004b5:	e8 92 fe ff ff       	call   80034c <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c0:	e9 c8 fe ff ff       	jmp    80038d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004c5:	50                   	push   %eax
  8004c6:	68 11 25 80 00       	push   $0x802511
  8004cb:	57                   	push   %edi
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 78 fe ff ff       	call   80034c <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004da:	e9 ae fe ff ff       	jmp    80038d <vprintfmt+0x24>
  8004df:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e2:	89 de                	mov    %ebx,%esi
  8004e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	75 07                	jne    800503 <vprintfmt+0x19a>
				p = "(null)";
  8004fc:	c7 45 d0 57 21 80 00 	movl   $0x802157,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800503:	85 db                	test   %ebx,%ebx
  800505:	7e 42                	jle    800549 <vprintfmt+0x1e0>
  800507:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80050b:	74 3c                	je     800549 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	51                   	push   %ecx
  800511:	ff 75 d0             	pushl  -0x30(%ebp)
  800514:	e8 6f 02 00 00       	call   800788 <strnlen>
  800519:	29 c3                	sub    %eax,%ebx
  80051b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 db                	test   %ebx,%ebx
  800523:	7e 24                	jle    800549 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800525:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800529:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80052c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	53                   	push   %ebx
  800534:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	4e                   	dec    %esi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 f6                	test   %esi,%esi
  80053d:	7f f0                	jg     80052f <vprintfmt+0x1c6>
  80053f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800542:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80054c:	0f be 02             	movsbl (%edx),%eax
  80054f:	85 c0                	test   %eax,%eax
  800551:	75 47                	jne    80059a <vprintfmt+0x231>
  800553:	eb 37                	jmp    80058c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	74 16                	je     800571 <vprintfmt+0x208>
  80055b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055e:	83 fa 5e             	cmp    $0x5e,%edx
  800561:	76 0e                	jbe    800571 <vprintfmt+0x208>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0b                	jmp    80057c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	57                   	push   %edi
  800575:	50                   	push   %eax
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	ff 4d e4             	decl   -0x1c(%ebp)
  80057f:	0f be 03             	movsbl (%ebx),%eax
  800582:	85 c0                	test   %eax,%eax
  800584:	74 03                	je     800589 <vprintfmt+0x220>
  800586:	43                   	inc    %ebx
  800587:	eb 1b                	jmp    8005a4 <vprintfmt+0x23b>
  800589:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800590:	7f 1e                	jg     8005b0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800595:	e9 f3 fd ff ff       	jmp    80038d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80059d:	43                   	inc    %ebx
  80059e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a4:	85 f6                	test   %esi,%esi
  8005a6:	78 ad                	js     800555 <vprintfmt+0x1ec>
  8005a8:	4e                   	dec    %esi
  8005a9:	79 aa                	jns    800555 <vprintfmt+0x1ec>
  8005ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ae:	eb dc                	jmp    80058c <vprintfmt+0x223>
  8005b0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	6a 20                	push   $0x20
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	4b                   	dec    %ebx
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	7f ef                	jg     8005b3 <vprintfmt+0x24a>
  8005c4:	e9 c4 fd ff ff       	jmp    80038d <vprintfmt+0x24>
  8005c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 2a fd ff ff       	call   800300 <getint>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005da:	85 d2                	test   %edx,%edx
  8005dc:	78 0a                	js     8005e8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 b0 00 00 00       	jmp    800698 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	57                   	push   %edi
  8005ec:	6a 2d                	push   $0x2d
  8005ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f1:	f7 db                	neg    %ebx
  8005f3:	83 d6 00             	adc    $0x0,%esi
  8005f6:	f7 de                	neg    %esi
  8005f8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 93 00 00 00       	jmp    800698 <vprintfmt+0x32f>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800608:	89 ca                	mov    %ecx,%edx
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 b4 fc ff ff       	call   8002c6 <getuint>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	89 d6                	mov    %edx,%esi
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061b:	eb 7b                	jmp    800698 <vprintfmt+0x32f>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 d6 fc ff ff       	call   800300 <getint>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80062e:	85 d2                	test   %edx,%edx
  800630:	78 07                	js     800639 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
  800637:	eb 5f                	jmp    800698 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	57                   	push   %edi
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800642:	f7 db                	neg    %ebx
  800644:	83 d6 00             	adc    $0x0,%esi
  800647:	f7 de                	neg    %esi
  800649:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80064c:	b8 08 00 00 00       	mov    $0x8,%eax
  800651:	eb 45                	jmp    800698 <vprintfmt+0x32f>
  800653:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	57                   	push   %edi
  80065a:	6a 30                	push   $0x30
  80065c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	6a 78                	push   $0x78
  800665:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800671:	8b 18                	mov    (%eax),%ebx
  800673:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800680:	eb 16                	jmp    800698 <vprintfmt+0x32f>
  800682:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800685:	89 ca                	mov    %ecx,%edx
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 37 fc ff ff       	call   8002c6 <getuint>
  80068f:	89 c3                	mov    %eax,%ebx
  800691:	89 d6                	mov    %edx,%esi
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80069f:	52                   	push   %edx
  8006a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a3:	50                   	push   %eax
  8006a4:	56                   	push   %esi
  8006a5:	53                   	push   %ebx
  8006a6:	89 fa                	mov    %edi,%edx
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	e8 68 fb ff ff       	call   800218 <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006b6:	e9 d2 fc ff ff       	jmp    80038d <vprintfmt+0x24>
  8006bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	57                   	push   %edi
  8006c2:	52                   	push   %edx
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cc:	e9 bc fc ff ff       	jmp    80038d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	57                   	push   %edi
  8006d5:	6a 25                	push   $0x25
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 02                	jmp    8006e1 <vprintfmt+0x378>
  8006df:	89 c6                	mov    %eax,%esi
  8006e1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006e4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e8:	75 f5                	jne    8006df <vprintfmt+0x376>
  8006ea:	e9 9e fc ff ff       	jmp    80038d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 29                	jle    800745 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 32 03 80 00       	push   $0x800332
  80072b:	e8 39 fc ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 0c                	jmp    80074a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800743:	eb 05                	jmp    80074a <vsnprintf+0x53>
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800755:	50                   	push   %eax
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 93 ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
	...

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3a 00             	cmpb   $0x0,(%edx)
  800771:	74 0e                	je     800781 <strlen+0x19>
  800773:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800778:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077d:	75 f9                	jne    800778 <strlen+0x10>
  80077f:	eb 05                	jmp    800786 <strlen+0x1e>
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	85 d2                	test   %edx,%edx
  800793:	74 17                	je     8007ac <strnlen+0x24>
  800795:	80 39 00             	cmpb   $0x0,(%ecx)
  800798:	74 19                	je     8007b3 <strnlen+0x2b>
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80079f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	39 d0                	cmp    %edx,%eax
  8007a2:	74 14                	je     8007b8 <strnlen+0x30>
  8007a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a8:	75 f5                	jne    80079f <strnlen+0x17>
  8007aa:	eb 0c                	jmp    8007b8 <strnlen+0x30>
  8007ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b1:	eb 05                	jmp    8007b8 <strnlen+0x30>
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007cc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007cf:	42                   	inc    %edx
  8007d0:	84 c9                	test   %cl,%cl
  8007d2:	75 f5                	jne    8007c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 84 ff ff ff       	call   800768 <strlen>
  8007e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c7 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	85 f6                	test   %esi,%esi
  80080a:	74 15                	je     800821 <strncpy+0x27>
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800811:	8a 1a                	mov    (%edx),%bl
  800813:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 3a 01             	cmpb   $0x1,(%edx)
  800819:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	41                   	inc    %ecx
  80081d:	39 ce                	cmp    %ecx,%esi
  80081f:	77 f0                	ja     800811 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	57                   	push   %edi
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800831:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 f6                	test   %esi,%esi
  800836:	74 32                	je     80086a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800838:	83 fe 01             	cmp    $0x1,%esi
  80083b:	74 22                	je     80085f <strlcpy+0x3a>
  80083d:	8a 0b                	mov    (%ebx),%cl
  80083f:	84 c9                	test   %cl,%cl
  800841:	74 20                	je     800863 <strlcpy+0x3e>
  800843:	89 f8                	mov    %edi,%eax
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80084a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084d:	88 08                	mov    %cl,(%eax)
  80084f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800850:	39 f2                	cmp    %esi,%edx
  800852:	74 11                	je     800865 <strlcpy+0x40>
  800854:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800858:	42                   	inc    %edx
  800859:	84 c9                	test   %cl,%cl
  80085b:	75 f0                	jne    80084d <strlcpy+0x28>
  80085d:	eb 06                	jmp    800865 <strlcpy+0x40>
  80085f:	89 f8                	mov    %edi,%eax
  800861:	eb 02                	jmp    800865 <strlcpy+0x40>
  800863:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
  800868:	eb 02                	jmp    80086c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80086c:	29 f8                	sub    %edi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	8a 01                	mov    (%ecx),%al
  80087e:	84 c0                	test   %al,%al
  800880:	74 10                	je     800892 <strcmp+0x1f>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	75 0c                	jne    800892 <strcmp+0x1f>
		p++, q++;
  800886:	41                   	inc    %ecx
  800887:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800888:	8a 01                	mov    (%ecx),%al
  80088a:	84 c0                	test   %al,%al
  80088c:	74 04                	je     800892 <strcmp+0x1f>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	74 f4                	je     800886 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	74 1b                	je     8008c8 <strncmp+0x2c>
  8008ad:	8a 1a                	mov    (%edx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	74 24                	je     8008d7 <strncmp+0x3b>
  8008b3:	3a 19                	cmp    (%ecx),%bl
  8008b5:	75 20                	jne    8008d7 <strncmp+0x3b>
  8008b7:	48                   	dec    %eax
  8008b8:	74 15                	je     8008cf <strncmp+0x33>
		n--, p++, q++;
  8008ba:	42                   	inc    %edx
  8008bb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bc:	8a 1a                	mov    (%edx),%bl
  8008be:	84 db                	test   %bl,%bl
  8008c0:	74 15                	je     8008d7 <strncmp+0x3b>
  8008c2:	3a 19                	cmp    (%ecx),%bl
  8008c4:	74 f1                	je     8008b7 <strncmp+0x1b>
  8008c6:	eb 0f                	jmp    8008d7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 05                	jmp    8008d4 <strncmp+0x38>
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 02             	movzbl (%edx),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb f3                	jmp    8008d4 <strncmp+0x38>

008008e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ea:	8a 10                	mov    (%eax),%dl
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 18                	je     800908 <strchr+0x27>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	75 06                	jne    8008fa <strchr+0x19>
  8008f4:	eb 17                	jmp    80090d <strchr+0x2c>
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 13                	je     80090d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	40                   	inc    %eax
  8008fb:	8a 10                	mov    (%eax),%dl
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f5                	jne    8008f6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	eb 05                	jmp    80090d <strchr+0x2c>
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800918:	8a 10                	mov    (%eax),%dl
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 11                	je     80092f <strfind+0x20>
		if (*s == c)
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	75 06                	jne    800928 <strfind+0x19>
  800922:	eb 0b                	jmp    80092f <strfind+0x20>
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 07                	je     80092f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800928:	40                   	inc    %eax
  800929:	8a 10                	mov    (%eax),%dl
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f5                	jne    800924 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	74 30                	je     800974 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800944:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094a:	75 25                	jne    800971 <memset+0x40>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 20                	jne    800971 <memset+0x40>
		c &= 0xFF;
  800951:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800954:	89 d3                	mov    %edx,%ebx
  800956:	c1 e3 08             	shl    $0x8,%ebx
  800959:	89 d6                	mov    %edx,%esi
  80095b:	c1 e6 18             	shl    $0x18,%esi
  80095e:	89 d0                	mov    %edx,%eax
  800960:	c1 e0 10             	shl    $0x10,%eax
  800963:	09 f0                	or     %esi,%eax
  800965:	09 d0                	or     %edx,%eax
  800967:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800969:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096c:	fc                   	cld    
  80096d:	f3 ab                	rep stos %eax,%es:(%edi)
  80096f:	eb 03                	jmp    800974 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800989:	39 c6                	cmp    %eax,%esi
  80098b:	73 34                	jae    8009c1 <memmove+0x46>
  80098d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800990:	39 d0                	cmp    %edx,%eax
  800992:	73 2d                	jae    8009c1 <memmove+0x46>
		s += n;
		d += n;
  800994:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 1b                	jne    8009b7 <memmove+0x3c>
  80099c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a2:	75 13                	jne    8009b7 <memmove+0x3c>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0e                	jne    8009b7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 07                	jmp    8009be <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b7:	4f                   	dec    %edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
  8009bf:	eb 20                	jmp    8009e1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x61>
  8009c9:	a8 03                	test   $0x3,%al
  8009cb:	75 0f                	jne    8009dc <memmove+0x61>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0a                	jne    8009dc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 05                	jmp    8009e1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 85 ff ff ff       	call   80097b <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	85 ff                	test   %edi,%edi
  800a09:	74 32                	je     800a3d <memcmp+0x45>
		if (*s1 != *s2)
  800a0b:	8a 03                	mov    (%ebx),%al
  800a0d:	8a 0e                	mov    (%esi),%cl
  800a0f:	38 c8                	cmp    %cl,%al
  800a11:	74 19                	je     800a2c <memcmp+0x34>
  800a13:	eb 0d                	jmp    800a22 <memcmp+0x2a>
  800a15:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a19:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a1d:	42                   	inc    %edx
  800a1e:	38 c8                	cmp    %cl,%al
  800a20:	74 10                	je     800a32 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a22:	0f b6 c0             	movzbl %al,%eax
  800a25:	0f b6 c9             	movzbl %cl,%ecx
  800a28:	29 c8                	sub    %ecx,%eax
  800a2a:	eb 16                	jmp    800a42 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	4f                   	dec    %edi
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	39 fa                	cmp    %edi,%edx
  800a34:	75 df                	jne    800a15 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 05                	jmp    800a42 <memcmp+0x4a>
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	73 12                	jae    800a68 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	75 06                	jne    800a63 <memfind+0x1c>
  800a5d:	eb 09                	jmp    800a68 <memfind+0x21>
  800a5f:	38 08                	cmp    %cl,(%eax)
  800a61:	74 05                	je     800a68 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a63:	40                   	inc    %eax
  800a64:	39 c2                	cmp    %eax,%edx
  800a66:	77 f7                	ja     800a5f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a76:	eb 01                	jmp    800a79 <strtol+0xf>
		s++;
  800a78:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	8a 02                	mov    (%edx),%al
  800a7b:	3c 20                	cmp    $0x20,%al
  800a7d:	74 f9                	je     800a78 <strtol+0xe>
  800a7f:	3c 09                	cmp    $0x9,%al
  800a81:	74 f5                	je     800a78 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a83:	3c 2b                	cmp    $0x2b,%al
  800a85:	75 08                	jne    800a8f <strtol+0x25>
		s++;
  800a87:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	eb 13                	jmp    800aa2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8f:	3c 2d                	cmp    $0x2d,%al
  800a91:	75 0a                	jne    800a9d <strtol+0x33>
		s++, neg = 1;
  800a93:	8d 52 01             	lea    0x1(%edx),%edx
  800a96:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9b:	eb 05                	jmp    800aa2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 05                	je     800aab <strtol+0x41>
  800aa6:	83 fb 10             	cmp    $0x10,%ebx
  800aa9:	75 28                	jne    800ad3 <strtol+0x69>
  800aab:	8a 02                	mov    (%edx),%al
  800aad:	3c 30                	cmp    $0x30,%al
  800aaf:	75 10                	jne    800ac1 <strtol+0x57>
  800ab1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab5:	75 0a                	jne    800ac1 <strtol+0x57>
		s += 2, base = 16;
  800ab7:	83 c2 02             	add    $0x2,%edx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb 12                	jmp    800ad3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	75 0e                	jne    800ad3 <strtol+0x69>
  800ac5:	3c 30                	cmp    $0x30,%al
  800ac7:	75 05                	jne    800ace <strtol+0x64>
		s++, base = 8;
  800ac9:	42                   	inc    %edx
  800aca:	b3 08                	mov    $0x8,%bl
  800acc:	eb 05                	jmp    800ad3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ace:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ada:	8a 0a                	mov    (%edx),%cl
  800adc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	77 08                	ja     800aec <strtol+0x82>
			dig = *s - '0';
  800ae4:	0f be c9             	movsbl %cl,%ecx
  800ae7:	83 e9 30             	sub    $0x30,%ecx
  800aea:	eb 1e                	jmp    800b0a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0x92>
			dig = *s - 'a' + 10;
  800af4:	0f be c9             	movsbl %cl,%ecx
  800af7:	83 e9 57             	sub    $0x57,%ecx
  800afa:	eb 0e                	jmp    800b0a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 13                	ja     800b17 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b04:	0f be c9             	movsbl %cl,%ecx
  800b07:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0a:	39 f1                	cmp    %esi,%ecx
  800b0c:	7d 0d                	jge    800b1b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b0e:	42                   	inc    %edx
  800b0f:	0f af c6             	imul   %esi,%eax
  800b12:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b15:	eb c3                	jmp    800ada <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	89 c1                	mov    %eax,%ecx
  800b19:	eb 02                	jmp    800b1d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b21:	74 05                	je     800b28 <strtol+0xbe>
		*endptr = (char *) s;
  800b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b26:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b28:	85 ff                	test   %edi,%edi
  800b2a:	74 04                	je     800b30 <strtol+0xc6>
  800b2c:	89 c8                	mov    %ecx,%eax
  800b2e:	f7 d8                	neg    %eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    
  800b35:	00 00                	add    %al,(%eax)
	...

00800b38 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 1c             	sub    $0x1c,%esp
  800b41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b44:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b47:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	8b 75 14             	mov    0x14(%ebp),%esi
  800b4c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b55:	cd 30                	int    $0x30
  800b57:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b5d:	74 1c                	je     800b7b <syscall+0x43>
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 18                	jle    800b7b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b6a:	68 3f 24 80 00       	push   $0x80243f
  800b6f:	6a 42                	push   $0x42
  800b71:	68 5c 24 80 00       	push   $0x80245c
  800b76:	e8 91 11 00 00       	call   801d0c <_panic>

	return ret;
}
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	ff 75 0c             	pushl  0xc(%ebp)
  800b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	e8 92 ff ff ff       	call   800b38 <syscall>
  800ba6:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_cgetc>:

int
sys_cgetc(void)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc8:	e8 6b ff ff ff       	call   800b38 <syscall>
}
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be0:	ba 01 00 00 00       	mov    $0x1,%edx
  800be5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bea:	e8 49 ff ff ff       	call   800b38 <syscall>
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0e:	e8 25 ff ff ff       	call   800b38 <syscall>
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    

00800c15 <sys_yield>:

void
sys_yield(void)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	6a 00                	push   $0x0
  800c23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c32:	e8 01 ff ff ff       	call   800b38 <syscall>
  800c37:	83 c4 10             	add    $0x10,%esp
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	ff 75 10             	pushl  0x10(%ebp)
  800c49:	ff 75 0c             	pushl  0xc(%ebp)
  800c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c54:	b8 04 00 00 00       	mov    $0x4,%eax
  800c59:	e8 da fe ff ff       	call   800b38 <syscall>
}
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c66:	ff 75 18             	pushl  0x18(%ebp)
  800c69:	ff 75 14             	pushl  0x14(%ebp)
  800c6c:	ff 75 10             	pushl  0x10(%ebp)
  800c6f:	ff 75 0c             	pushl  0xc(%ebp)
  800c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c75:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7f:	e8 b4 fe ff ff       	call   800b38 <syscall>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c8c:	6a 00                	push   $0x0
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	e8 91 fe ff ff       	call   800b38 <syscall>
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc5:	e8 6e fe ff ff       	call   800b38 <syscall>
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cd2:	6a 00                	push   $0x0
  800cd4:	6a 00                	push   $0x0
  800cd6:	6a 00                	push   $0x0
  800cd8:	ff 75 0c             	pushl  0xc(%ebp)
  800cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cde:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce8:	e8 4b fe ff ff       	call   800b38 <syscall>
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	6a 00                	push   $0x0
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d01:	ba 01 00 00 00       	mov    $0x1,%edx
  800d06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0b:	e8 28 fe ff ff       	call   800b38 <syscall>
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d18:	6a 00                	push   $0x0
  800d1a:	ff 75 14             	pushl  0x14(%ebp)
  800d1d:	ff 75 10             	pushl  0x10(%ebp)
  800d20:	ff 75 0c             	pushl  0xc(%ebp)
  800d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d26:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d30:	e8 03 fe ff ff       	call   800b38 <syscall>
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d3d:	6a 00                	push   $0x0
  800d3f:	6a 00                	push   $0x0
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d48:	ba 01 00 00 00       	mov    $0x1,%edx
  800d4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d52:	e8 e1 fd ff ff       	call   800b38 <syscall>
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d5f:	6a 00                	push   $0x0
  800d61:	6a 00                	push   $0x0
  800d63:	6a 00                	push   $0x0
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d75:	e8 be fd ff ff       	call   800b38 <syscall>
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d82:	6a 00                	push   $0x0
  800d84:	ff 75 14             	pushl  0x14(%ebp)
  800d87:	ff 75 10             	pushl  0x10(%ebp)
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9a:	e8 99 fd ff ff       	call   800b38 <syscall>
} 
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800da7:	6a 00                	push   $0x0
  800da9:	6a 00                	push   $0x0
  800dab:	6a 00                	push   $0x0
  800dad:	6a 00                	push   $0x0
  800daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	b8 11 00 00 00       	mov    $0x11,%eax
  800dbc:	e8 77 fd ff ff       	call   800b38 <syscall>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	6a 00                	push   $0x0
  800dcf:	6a 00                	push   $0x0
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddb:	b8 10 00 00 00       	mov    $0x10,%eax
  800de0:	e8 53 fd ff ff       	call   800b38 <syscall>
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    
	...

00800de8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800df4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800df6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800df9:	83 3a 01             	cmpl   $0x1,(%edx)
  800dfc:	7e 0b                	jle    800e09 <argstart+0x21>
  800dfe:	85 c9                	test   %ecx,%ecx
  800e00:	75 0e                	jne    800e10 <argstart+0x28>
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	eb 0c                	jmp    800e15 <argstart+0x2d>
  800e09:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0e:	eb 05                	jmp    800e15 <argstart+0x2d>
  800e10:	ba 11 21 80 00       	mov    $0x802111,%edx
  800e15:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e18:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <argnext>:

int
argnext(struct Argstate *args)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e2d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e34:	8b 43 08             	mov    0x8(%ebx),%eax
  800e37:	85 c0                	test   %eax,%eax
  800e39:	74 6c                	je     800ea7 <argnext+0x86>
		return -1;

	if (!*args->curarg) {
  800e3b:	80 38 00             	cmpb   $0x0,(%eax)
  800e3e:	75 4d                	jne    800e8d <argnext+0x6c>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e40:	8b 0b                	mov    (%ebx),%ecx
  800e42:	83 39 01             	cmpl   $0x1,(%ecx)
  800e45:	74 52                	je     800e99 <argnext+0x78>
		    || args->argv[1][0] != '-'
  800e47:	8b 43 04             	mov    0x4(%ebx),%eax
  800e4a:	8d 70 04             	lea    0x4(%eax),%esi
  800e4d:	8b 50 04             	mov    0x4(%eax),%edx
  800e50:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800e53:	75 44                	jne    800e99 <argnext+0x78>
		    || args->argv[1][1] == '\0')
  800e55:	8d 7a 01             	lea    0x1(%edx),%edi
  800e58:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  800e5c:	74 3b                	je     800e99 <argnext+0x78>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e5e:	89 7b 08             	mov    %edi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	8b 11                	mov    (%ecx),%edx
  800e66:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e6d:	52                   	push   %edx
  800e6e:	83 c0 08             	add    $0x8,%eax
  800e71:	50                   	push   %eax
  800e72:	56                   	push   %esi
  800e73:	e8 03 fb ff ff       	call   80097b <memmove>
		(*args->argc)--;
  800e78:	8b 03                	mov    (%ebx),%eax
  800e7a:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e7c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e85:	75 06                	jne    800e8d <argnext+0x6c>
  800e87:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e8b:	74 0c                	je     800e99 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e8d:	8b 53 08             	mov    0x8(%ebx),%edx
  800e90:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e93:	42                   	inc    %edx
  800e94:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e97:	eb 13                	jmp    800eac <argnext+0x8b>

    endofargs:
	args->curarg = 0;
  800e99:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ea0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ea5:	eb 05                	jmp    800eac <argnext+0x8b>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800ea7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800ebc:	8b 43 08             	mov    0x8(%ebx),%eax
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	74 57                	je     800f1a <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  800ec3:	80 38 00             	cmpb   $0x0,(%eax)
  800ec6:	74 0c                	je     800ed4 <argnextvalue+0x20>
		args->argvalue = args->curarg;
  800ec8:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ecb:	c7 43 08 11 21 80 00 	movl   $0x802111,0x8(%ebx)
  800ed2:	eb 41                	jmp    800f15 <argnextvalue+0x61>
	} else if (*args->argc > 1) {
  800ed4:	8b 03                	mov    (%ebx),%eax
  800ed6:	83 38 01             	cmpl   $0x1,(%eax)
  800ed9:	7e 2c                	jle    800f07 <argnextvalue+0x53>
		args->argvalue = args->argv[1];
  800edb:	8b 53 04             	mov    0x4(%ebx),%edx
  800ede:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ee1:	8b 72 04             	mov    0x4(%edx),%esi
  800ee4:	89 73 0c             	mov    %esi,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	8b 00                	mov    (%eax),%eax
  800eec:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ef3:	50                   	push   %eax
  800ef4:	83 c2 08             	add    $0x8,%edx
  800ef7:	52                   	push   %edx
  800ef8:	51                   	push   %ecx
  800ef9:	e8 7d fa ff ff       	call   80097b <memmove>
		(*args->argc)--;
  800efe:	8b 03                	mov    (%ebx),%eax
  800f00:	ff 08                	decl   (%eax)
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	eb 0e                	jmp    800f15 <argnextvalue+0x61>
	} else {
		args->argvalue = 0;
  800f07:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f0e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f15:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f18:	eb 05                	jmp    800f1f <argnextvalue+0x6b>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f2f:	8b 42 0c             	mov    0xc(%edx),%eax
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 0c                	jne    800f42 <argvalue+0x1c>
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	52                   	push   %edx
  800f3a:	e8 75 ff ff ff       	call   800eb4 <argnextvalue>
  800f3f:	83 c4 10             	add    $0x10,%esp
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f4f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f57:	ff 75 08             	pushl  0x8(%ebp)
  800f5a:	e8 e5 ff ff ff       	call   800f44 <fd2num>
  800f5f:	83 c4 04             	add    $0x4,%esp
  800f62:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f67:	c1 e0 0c             	shl    $0xc,%eax
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	53                   	push   %ebx
  800f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f73:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f78:	a8 01                	test   $0x1,%al
  800f7a:	74 34                	je     800fb0 <fd_alloc+0x44>
  800f7c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f81:	a8 01                	test   $0x1,%al
  800f83:	74 32                	je     800fb7 <fd_alloc+0x4b>
  800f85:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800f8a:	89 c1                	mov    %eax,%ecx
  800f8c:	89 c2                	mov    %eax,%edx
  800f8e:	c1 ea 16             	shr    $0x16,%edx
  800f91:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f98:	f6 c2 01             	test   $0x1,%dl
  800f9b:	74 1f                	je     800fbc <fd_alloc+0x50>
  800f9d:	89 c2                	mov    %eax,%edx
  800f9f:	c1 ea 0c             	shr    $0xc,%edx
  800fa2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa9:	f6 c2 01             	test   $0x1,%dl
  800fac:	75 17                	jne    800fc5 <fd_alloc+0x59>
  800fae:	eb 0c                	jmp    800fbc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fb0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800fb5:	eb 05                	jmp    800fbc <fd_alloc+0x50>
  800fb7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800fbc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	eb 17                	jmp    800fdc <fd_alloc+0x70>
  800fc5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fcf:	75 b9                	jne    800f8a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fd1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fd7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fdc:	5b                   	pop    %ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fe5:	83 f8 1f             	cmp    $0x1f,%eax
  800fe8:	77 36                	ja     801020 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fea:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fef:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ff2:	89 c2                	mov    %eax,%edx
  800ff4:	c1 ea 16             	shr    $0x16,%edx
  800ff7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ffe:	f6 c2 01             	test   $0x1,%dl
  801001:	74 24                	je     801027 <fd_lookup+0x48>
  801003:	89 c2                	mov    %eax,%edx
  801005:	c1 ea 0c             	shr    $0xc,%edx
  801008:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80100f:	f6 c2 01             	test   $0x1,%dl
  801012:	74 1a                	je     80102e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801014:	8b 55 0c             	mov    0xc(%ebp),%edx
  801017:	89 02                	mov    %eax,(%edx)
	return 0;
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	eb 13                	jmp    801033 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801020:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801025:	eb 0c                	jmp    801033 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80102c:	eb 05                	jmp    801033 <fd_lookup+0x54>
  80102e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	53                   	push   %ebx
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801042:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801048:	74 0d                	je     801057 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
  80104f:	eb 14                	jmp    801065 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801051:	39 0a                	cmp    %ecx,(%edx)
  801053:	75 10                	jne    801065 <dev_lookup+0x30>
  801055:	eb 05                	jmp    80105c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801057:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80105c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
  801063:	eb 31                	jmp    801096 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801065:	40                   	inc    %eax
  801066:	8b 14 85 e8 24 80 00 	mov    0x8024e8(,%eax,4),%edx
  80106d:	85 d2                	test   %edx,%edx
  80106f:	75 e0                	jne    801051 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801071:	a1 04 40 80 00       	mov    0x804004,%eax
  801076:	8b 40 48             	mov    0x48(%eax),%eax
  801079:	83 ec 04             	sub    $0x4,%esp
  80107c:	51                   	push   %ecx
  80107d:	50                   	push   %eax
  80107e:	68 6c 24 80 00       	push   $0x80246c
  801083:	e8 7c f1 ff ff       	call   800204 <cprintf>
	*dev = 0;
  801088:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 20             	sub    $0x20,%esp
  8010a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a6:	8a 45 0c             	mov    0xc(%ebp),%al
  8010a9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ac:	56                   	push   %esi
  8010ad:	e8 92 fe ff ff       	call   800f44 <fd2num>
  8010b2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010b5:	89 14 24             	mov    %edx,(%esp)
  8010b8:	50                   	push   %eax
  8010b9:	e8 21 ff ff ff       	call   800fdf <fd_lookup>
  8010be:	89 c3                	mov    %eax,%ebx
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 05                	js     8010cc <fd_close+0x31>
	    || fd != fd2)
  8010c7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ca:	74 0d                	je     8010d9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8010cc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010d0:	75 48                	jne    80111a <fd_close+0x7f>
  8010d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d7:	eb 41                	jmp    80111a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	ff 36                	pushl  (%esi)
  8010e2:	e8 4e ff ff ff       	call   801035 <dev_lookup>
  8010e7:	89 c3                	mov    %eax,%ebx
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 1c                	js     80110c <fd_close+0x71>
		if (dev->dev_close)
  8010f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f3:	8b 40 10             	mov    0x10(%eax),%eax
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	74 0d                	je     801107 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	56                   	push   %esi
  8010fe:	ff d0                	call   *%eax
  801100:	89 c3                	mov    %eax,%ebx
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	eb 05                	jmp    80110c <fd_close+0x71>
		else
			r = 0;
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	e8 6f fb ff ff       	call   800c86 <sys_page_unmap>
	return r;
  801117:	83 c4 10             	add    $0x10,%esp
}
  80111a:	89 d8                	mov    %ebx,%eax
  80111c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801129:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	ff 75 08             	pushl  0x8(%ebp)
  801130:	e8 aa fe ff ff       	call   800fdf <fd_lookup>
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 10                	js     80114c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	6a 01                	push   $0x1
  801141:	ff 75 f4             	pushl  -0xc(%ebp)
  801144:	e8 52 ff ff ff       	call   80109b <fd_close>
  801149:	83 c4 10             	add    $0x10,%esp
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <close_all>:

void
close_all(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	53                   	push   %ebx
  801152:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801155:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	53                   	push   %ebx
  80115e:	e8 c0 ff ff ff       	call   801123 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801163:	43                   	inc    %ebx
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	83 fb 20             	cmp    $0x20,%ebx
  80116a:	75 ee                	jne    80115a <close_all+0xc>
		close(i);
}
  80116c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 2c             	sub    $0x2c,%esp
  80117a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80117d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	ff 75 08             	pushl  0x8(%ebp)
  801184:	e8 56 fe ff ff       	call   800fdf <fd_lookup>
  801189:	89 c3                	mov    %eax,%ebx
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	0f 88 c0 00 00 00    	js     801256 <dup+0xe5>
		return r;
	close(newfdnum);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	57                   	push   %edi
  80119a:	e8 84 ff ff ff       	call   801123 <close>

	newfd = INDEX2FD(newfdnum);
  80119f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011a5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011a8:	83 c4 04             	add    $0x4,%esp
  8011ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ae:	e8 a1 fd ff ff       	call   800f54 <fd2data>
  8011b3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011b5:	89 34 24             	mov    %esi,(%esp)
  8011b8:	e8 97 fd ff ff       	call   800f54 <fd2data>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011c3:	89 d8                	mov    %ebx,%eax
  8011c5:	c1 e8 16             	shr    $0x16,%eax
  8011c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011cf:	a8 01                	test   $0x1,%al
  8011d1:	74 37                	je     80120a <dup+0x99>
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	c1 e8 0c             	shr    $0xc,%eax
  8011d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 26                	je     80120a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011f7:	6a 00                	push   $0x0
  8011f9:	53                   	push   %ebx
  8011fa:	6a 00                	push   $0x0
  8011fc:	e8 5f fa ff ff       	call   800c60 <sys_page_map>
  801201:	89 c3                	mov    %eax,%ebx
  801203:	83 c4 20             	add    $0x20,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 2d                	js     801237 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80120a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 0c             	shr    $0xc,%edx
  801212:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801222:	52                   	push   %edx
  801223:	56                   	push   %esi
  801224:	6a 00                	push   $0x0
  801226:	50                   	push   %eax
  801227:	6a 00                	push   $0x0
  801229:	e8 32 fa ff ff       	call   800c60 <sys_page_map>
  80122e:	89 c3                	mov    %eax,%ebx
  801230:	83 c4 20             	add    $0x20,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	79 1d                	jns    801254 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	56                   	push   %esi
  80123b:	6a 00                	push   $0x0
  80123d:	e8 44 fa ff ff       	call   800c86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	ff 75 d4             	pushl  -0x2c(%ebp)
  801248:	6a 00                	push   $0x0
  80124a:	e8 37 fa ff ff       	call   800c86 <sys_page_unmap>
	return r;
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	eb 02                	jmp    801256 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801254:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801256:	89 d8                	mov    %ebx,%eax
  801258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	53                   	push   %ebx
  801264:	83 ec 14             	sub    $0x14,%esp
  801267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	53                   	push   %ebx
  80126f:	e8 6b fd ff ff       	call   800fdf <fd_lookup>
  801274:	83 c4 08             	add    $0x8,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 67                	js     8012e2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801281:	50                   	push   %eax
  801282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801285:	ff 30                	pushl  (%eax)
  801287:	e8 a9 fd ff ff       	call   801035 <dev_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 4f                	js     8012e2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	8b 50 08             	mov    0x8(%eax),%edx
  801299:	83 e2 03             	and    $0x3,%edx
  80129c:	83 fa 01             	cmp    $0x1,%edx
  80129f:	75 21                	jne    8012c2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a6:	8b 40 48             	mov    0x48(%eax),%eax
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	50                   	push   %eax
  8012ae:	68 ad 24 80 00       	push   $0x8024ad
  8012b3:	e8 4c ef ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c0:	eb 20                	jmp    8012e2 <read+0x82>
	}
	if (!dev->dev_read)
  8012c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c5:	8b 52 08             	mov    0x8(%edx),%edx
  8012c8:	85 d2                	test   %edx,%edx
  8012ca:	74 11                	je     8012dd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012cc:	83 ec 04             	sub    $0x4,%esp
  8012cf:	ff 75 10             	pushl  0x10(%ebp)
  8012d2:	ff 75 0c             	pushl  0xc(%ebp)
  8012d5:	50                   	push   %eax
  8012d6:	ff d2                	call   *%edx
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	eb 05                	jmp    8012e2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	57                   	push   %edi
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f6:	85 f6                	test   %esi,%esi
  8012f8:	74 31                	je     80132b <readn+0x44>
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	89 f2                	mov    %esi,%edx
  801309:	29 c2                	sub    %eax,%edx
  80130b:	52                   	push   %edx
  80130c:	03 45 0c             	add    0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	57                   	push   %edi
  801311:	e8 4a ff ff ff       	call   801260 <read>
		if (m < 0)
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 17                	js     801334 <readn+0x4d>
			return m;
		if (m == 0)
  80131d:	85 c0                	test   %eax,%eax
  80131f:	74 11                	je     801332 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801321:	01 c3                	add    %eax,%ebx
  801323:	89 d8                	mov    %ebx,%eax
  801325:	39 f3                	cmp    %esi,%ebx
  801327:	72 db                	jb     801304 <readn+0x1d>
  801329:	eb 09                	jmp    801334 <readn+0x4d>
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb 02                	jmp    801334 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801332:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	83 ec 14             	sub    $0x14,%esp
  801343:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801346:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	53                   	push   %ebx
  80134b:	e8 8f fc ff ff       	call   800fdf <fd_lookup>
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 62                	js     8013b9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801361:	ff 30                	pushl  (%eax)
  801363:	e8 cd fc ff ff       	call   801035 <dev_lookup>
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 4a                	js     8013b9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801372:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801376:	75 21                	jne    801399 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801378:	a1 04 40 80 00       	mov    0x804004,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	53                   	push   %ebx
  801384:	50                   	push   %eax
  801385:	68 c9 24 80 00       	push   $0x8024c9
  80138a:	e8 75 ee ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb 20                	jmp    8013b9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801399:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139c:	8b 52 0c             	mov    0xc(%edx),%edx
  80139f:	85 d2                	test   %edx,%edx
  8013a1:	74 11                	je     8013b4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	ff 75 10             	pushl  0x10(%ebp)
  8013a9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ac:	50                   	push   %eax
  8013ad:	ff d2                	call   *%edx
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	eb 05                	jmp    8013b9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <seek>:

int
seek(int fdnum, off_t offset)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 08             	pushl  0x8(%ebp)
  8013cb:	e8 0f fc ff ff       	call   800fdf <fd_lookup>
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 0e                	js     8013e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 14             	sub    $0x14,%esp
  8013ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f4:	50                   	push   %eax
  8013f5:	53                   	push   %ebx
  8013f6:	e8 e4 fb ff ff       	call   800fdf <fd_lookup>
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 5f                	js     801461 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	ff 30                	pushl  (%eax)
  80140e:	e8 22 fc ff ff       	call   801035 <dev_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 47                	js     801461 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801421:	75 21                	jne    801444 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801423:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801428:	8b 40 48             	mov    0x48(%eax),%eax
  80142b:	83 ec 04             	sub    $0x4,%esp
  80142e:	53                   	push   %ebx
  80142f:	50                   	push   %eax
  801430:	68 8c 24 80 00       	push   $0x80248c
  801435:	e8 ca ed ff ff       	call   800204 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801442:	eb 1d                	jmp    801461 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801444:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801447:	8b 52 18             	mov    0x18(%edx),%edx
  80144a:	85 d2                	test   %edx,%edx
  80144c:	74 0e                	je     80145c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	50                   	push   %eax
  801455:	ff d2                	call   *%edx
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	eb 05                	jmp    801461 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80145c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801461:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 14             	sub    $0x14,%esp
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801470:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 63 fb ff ff       	call   800fdf <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 52                	js     8014d5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	ff 30                	pushl  (%eax)
  80148f:	e8 a1 fb ff ff       	call   801035 <dev_lookup>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 3a                	js     8014d5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a2:	74 2c                	je     8014d0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ae:	00 00 00 
	stat->st_isdir = 0;
  8014b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014b8:	00 00 00 
	stat->st_dev = dev;
  8014bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8014c8:	ff 50 14             	call   *0x14(%eax)
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	eb 05                	jmp    8014d5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	6a 00                	push   $0x0
  8014e4:	ff 75 08             	pushl  0x8(%ebp)
  8014e7:	e8 78 01 00 00       	call   801664 <open>
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 1b                	js     801510 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	50                   	push   %eax
  8014fc:	e8 65 ff ff ff       	call   801466 <fstat>
  801501:	89 c6                	mov    %eax,%esi
	close(fd);
  801503:	89 1c 24             	mov    %ebx,(%esp)
  801506:	e8 18 fc ff ff       	call   801123 <close>
	return r;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	89 f3                	mov    %esi,%ebx
}
  801510:	89 d8                	mov    %ebx,%eax
  801512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	c9                   	leave  
  801518:	c3                   	ret    
  801519:	00 00                	add    %al,(%eax)
	...

0080151c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	89 c3                	mov    %eax,%ebx
  801523:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801525:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80152c:	75 12                	jne    801540 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	6a 01                	push   $0x1
  801533:	e8 e6 08 00 00       	call   801e1e <ipc_find_env>
  801538:	a3 00 40 80 00       	mov    %eax,0x804000
  80153d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801540:	6a 07                	push   $0x7
  801542:	68 00 50 80 00       	push   $0x805000
  801547:	53                   	push   %ebx
  801548:	ff 35 00 40 80 00    	pushl  0x804000
  80154e:	e8 76 08 00 00       	call   801dc9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801553:	83 c4 0c             	add    $0xc,%esp
  801556:	6a 00                	push   $0x0
  801558:	56                   	push   %esi
  801559:	6a 00                	push   $0x0
  80155b:	e8 f4 07 00 00       	call   801d54 <ipc_recv>
}
  801560:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	53                   	push   %ebx
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801571:	8b 45 08             	mov    0x8(%ebp),%eax
  801574:	8b 40 0c             	mov    0xc(%eax),%eax
  801577:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80157c:	ba 00 00 00 00       	mov    $0x0,%edx
  801581:	b8 05 00 00 00       	mov    $0x5,%eax
  801586:	e8 91 ff ff ff       	call   80151c <fsipc>
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 2c                	js     8015bb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	68 00 50 80 00       	push   $0x805000
  801597:	53                   	push   %ebx
  801598:	e8 1d f2 ff ff       	call   8007ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80159d:	a1 80 50 80 00       	mov    0x805080,%eax
  8015a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015db:	e8 3c ff ff ff       	call   80151c <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	b8 03 00 00 00       	mov    $0x3,%eax
  801605:	e8 12 ff ff ff       	call   80151c <fsipc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 4b                	js     80165b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801610:	39 c6                	cmp    %eax,%esi
  801612:	73 16                	jae    80162a <devfile_read+0x48>
  801614:	68 f8 24 80 00       	push   $0x8024f8
  801619:	68 ff 24 80 00       	push   $0x8024ff
  80161e:	6a 7d                	push   $0x7d
  801620:	68 14 25 80 00       	push   $0x802514
  801625:	e8 e2 06 00 00       	call   801d0c <_panic>
	assert(r <= PGSIZE);
  80162a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80162f:	7e 16                	jle    801647 <devfile_read+0x65>
  801631:	68 1f 25 80 00       	push   $0x80251f
  801636:	68 ff 24 80 00       	push   $0x8024ff
  80163b:	6a 7e                	push   $0x7e
  80163d:	68 14 25 80 00       	push   $0x802514
  801642:	e8 c5 06 00 00       	call   801d0c <_panic>
	memmove(buf, &fsipcbuf, r);
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	50                   	push   %eax
  80164b:	68 00 50 80 00       	push   $0x805000
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	e8 23 f3 ff ff       	call   80097b <memmove>
	return r;
  801658:	83 c4 10             	add    $0x10,%esp
}
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	83 ec 1c             	sub    $0x1c,%esp
  80166c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80166f:	56                   	push   %esi
  801670:	e8 f3 f0 ff ff       	call   800768 <strlen>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167d:	7f 65                	jg     8016e4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	e8 e1 f8 ff ff       	call   800f6c <fd_alloc>
  80168b:	89 c3                	mov    %eax,%ebx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	78 55                	js     8016e9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	56                   	push   %esi
  801698:	68 00 50 80 00       	push   $0x805000
  80169d:	e8 18 f1 ff ff       	call   8007ba <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b2:	e8 65 fe ff ff       	call   80151c <fsipc>
  8016b7:	89 c3                	mov    %eax,%ebx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	79 12                	jns    8016d2 <open+0x6e>
		fd_close(fd, 0);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	6a 00                	push   $0x0
  8016c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c8:	e8 ce f9 ff ff       	call   80109b <fd_close>
		return r;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	eb 17                	jmp    8016e9 <open+0x85>
	}

	return fd2num(fd);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d8:	e8 67 f8 ff ff       	call   800f44 <fd2num>
  8016dd:	89 c3                	mov    %eax,%ebx
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb 05                	jmp    8016e9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016e4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e9:	89 d8                	mov    %ebx,%eax
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    
	...

008016f4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 04             	sub    $0x4,%esp
  8016fb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8016fd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801701:	7e 2e                	jle    801731 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801703:	83 ec 04             	sub    $0x4,%esp
  801706:	ff 70 04             	pushl  0x4(%eax)
  801709:	8d 40 10             	lea    0x10(%eax),%eax
  80170c:	50                   	push   %eax
  80170d:	ff 33                	pushl  (%ebx)
  80170f:	e8 28 fc ff ff       	call   80133c <write>
		if (result > 0)
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	7e 03                	jle    80171e <writebuf+0x2a>
			b->result += result;
  80171b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80171e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801721:	74 0e                	je     801731 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  801723:	89 c2                	mov    %eax,%edx
  801725:	85 c0                	test   %eax,%eax
  801727:	7e 05                	jle    80172e <writebuf+0x3a>
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <putch>:

static void
putch(int ch, void *thunk)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801740:	8b 43 04             	mov    0x4(%ebx),%eax
  801743:	8b 55 08             	mov    0x8(%ebp),%edx
  801746:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80174a:	40                   	inc    %eax
  80174b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80174e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801753:	75 0e                	jne    801763 <putch+0x2d>
		writebuf(b);
  801755:	89 d8                	mov    %ebx,%eax
  801757:	e8 98 ff ff ff       	call   8016f4 <writebuf>
		b->idx = 0;
  80175c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801763:	83 c4 04             	add    $0x4,%esp
  801766:	5b                   	pop    %ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80177b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801782:	00 00 00 
	b.result = 0;
  801785:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80178c:	00 00 00 
	b.error = 1;
  80178f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801796:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801799:	ff 75 10             	pushl  0x10(%ebp)
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	68 36 17 80 00       	push   $0x801736
  8017ab:	e8 b9 eb ff ff       	call   800369 <vprintfmt>
	if (b.idx > 0)
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017ba:	7e 0b                	jle    8017c7 <vfprintf+0x5e>
		writebuf(&b);
  8017bc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017c2:	e8 2d ff ff ff       	call   8016f4 <writebuf>

	return (b.result ? b.result : b.error);
  8017c7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	75 06                	jne    8017d7 <vfprintf+0x6e>
  8017d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017df:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017e2:	50                   	push   %eax
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	ff 75 08             	pushl  0x8(%ebp)
  8017e9:	e8 7b ff ff ff       	call   801769 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <printf>:

int
printf(const char *fmt, ...)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017f9:	50                   	push   %eax
  8017fa:	ff 75 08             	pushl  0x8(%ebp)
  8017fd:	6a 01                	push   $0x1
  8017ff:	e8 65 ff ff ff       	call   801769 <vfprintf>
	va_end(ap);

	return cnt;
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    
	...

00801808 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	ff 75 08             	pushl  0x8(%ebp)
  801816:	e8 39 f7 ff ff       	call   800f54 <fd2data>
  80181b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80181d:	83 c4 08             	add    $0x8,%esp
  801820:	68 2b 25 80 00       	push   $0x80252b
  801825:	56                   	push   %esi
  801826:	e8 8f ef ff ff       	call   8007ba <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80182b:	8b 43 04             	mov    0x4(%ebx),%eax
  80182e:	2b 03                	sub    (%ebx),%eax
  801830:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801836:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80183d:	00 00 00 
	stat->st_dev = &devpipe;
  801840:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801847:	30 80 00 
	return 0;
}
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
  80184f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801860:	53                   	push   %ebx
  801861:	6a 00                	push   $0x0
  801863:	e8 1e f4 ff ff       	call   800c86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801868:	89 1c 24             	mov    %ebx,(%esp)
  80186b:	e8 e4 f6 ff ff       	call   800f54 <fd2data>
  801870:	83 c4 08             	add    $0x8,%esp
  801873:	50                   	push   %eax
  801874:	6a 00                	push   $0x0
  801876:	e8 0b f4 ff ff       	call   800c86 <sys_page_unmap>
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 1c             	sub    $0x1c,%esp
  801889:	89 c7                	mov    %eax,%edi
  80188b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80188e:	a1 04 40 80 00       	mov    0x804004,%eax
  801893:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	57                   	push   %edi
  80189a:	e8 cd 05 00 00       	call   801e6c <pageref>
  80189f:	89 c6                	mov    %eax,%esi
  8018a1:	83 c4 04             	add    $0x4,%esp
  8018a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018a7:	e8 c0 05 00 00       	call   801e6c <pageref>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	39 c6                	cmp    %eax,%esi
  8018b1:	0f 94 c0             	sete   %al
  8018b4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018b7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018bd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018c0:	39 cb                	cmp    %ecx,%ebx
  8018c2:	75 08                	jne    8018cc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5f                   	pop    %edi
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018cc:	83 f8 01             	cmp    $0x1,%eax
  8018cf:	75 bd                	jne    80188e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018d1:	8b 42 58             	mov    0x58(%edx),%eax
  8018d4:	6a 01                	push   $0x1
  8018d6:	50                   	push   %eax
  8018d7:	53                   	push   %ebx
  8018d8:	68 32 25 80 00       	push   $0x802532
  8018dd:	e8 22 e9 ff ff       	call   800204 <cprintf>
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	eb a7                	jmp    80188e <_pipeisclosed+0xe>

008018e7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	57                   	push   %edi
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 28             	sub    $0x28,%esp
  8018f0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f3:	56                   	push   %esi
  8018f4:	e8 5b f6 ff ff       	call   800f54 <fd2data>
  8018f9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801902:	75 4a                	jne    80194e <devpipe_write+0x67>
  801904:	bf 00 00 00 00       	mov    $0x0,%edi
  801909:	eb 56                	jmp    801961 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80190b:	89 da                	mov    %ebx,%edx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	e8 6c ff ff ff       	call   801880 <_pipeisclosed>
  801914:	85 c0                	test   %eax,%eax
  801916:	75 4d                	jne    801965 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801918:	e8 f8 f2 ff ff       	call   800c15 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191d:	8b 43 04             	mov    0x4(%ebx),%eax
  801920:	8b 13                	mov    (%ebx),%edx
  801922:	83 c2 20             	add    $0x20,%edx
  801925:	39 d0                	cmp    %edx,%eax
  801927:	73 e2                	jae    80190b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801929:	89 c2                	mov    %eax,%edx
  80192b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801931:	79 05                	jns    801938 <devpipe_write+0x51>
  801933:	4a                   	dec    %edx
  801934:	83 ca e0             	or     $0xffffffe0,%edx
  801937:	42                   	inc    %edx
  801938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80193e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801942:	40                   	inc    %eax
  801943:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801946:	47                   	inc    %edi
  801947:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80194a:	77 07                	ja     801953 <devpipe_write+0x6c>
  80194c:	eb 13                	jmp    801961 <devpipe_write+0x7a>
  80194e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801953:	8b 43 04             	mov    0x4(%ebx),%eax
  801956:	8b 13                	mov    (%ebx),%edx
  801958:	83 c2 20             	add    $0x20,%edx
  80195b:	39 d0                	cmp    %edx,%eax
  80195d:	73 ac                	jae    80190b <devpipe_write+0x24>
  80195f:	eb c8                	jmp    801929 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801961:	89 f8                	mov    %edi,%eax
  801963:	eb 05                	jmp    80196a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80196a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5f                   	pop    %edi
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 18             	sub    $0x18,%esp
  80197b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80197e:	57                   	push   %edi
  80197f:	e8 d0 f5 ff ff       	call   800f54 <fd2data>
  801984:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80198d:	75 44                	jne    8019d3 <devpipe_read+0x61>
  80198f:	be 00 00 00 00       	mov    $0x0,%esi
  801994:	eb 4f                	jmp    8019e5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801996:	89 f0                	mov    %esi,%eax
  801998:	eb 54                	jmp    8019ee <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80199a:	89 da                	mov    %ebx,%edx
  80199c:	89 f8                	mov    %edi,%eax
  80199e:	e8 dd fe ff ff       	call   801880 <_pipeisclosed>
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	75 42                	jne    8019e9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019a7:	e8 69 f2 ff ff       	call   800c15 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019ac:	8b 03                	mov    (%ebx),%eax
  8019ae:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019b1:	74 e7                	je     80199a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019b3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019b8:	79 05                	jns    8019bf <devpipe_read+0x4d>
  8019ba:	48                   	dec    %eax
  8019bb:	83 c8 e0             	or     $0xffffffe0,%eax
  8019be:	40                   	inc    %eax
  8019bf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019c9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cb:	46                   	inc    %esi
  8019cc:	39 75 10             	cmp    %esi,0x10(%ebp)
  8019cf:	77 07                	ja     8019d8 <devpipe_read+0x66>
  8019d1:	eb 12                	jmp    8019e5 <devpipe_read+0x73>
  8019d3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019d8:	8b 03                	mov    (%ebx),%eax
  8019da:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019dd:	75 d4                	jne    8019b3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019df:	85 f6                	test   %esi,%esi
  8019e1:	75 b3                	jne    801996 <devpipe_read+0x24>
  8019e3:	eb b5                	jmp    80199a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019e5:	89 f0                	mov    %esi,%eax
  8019e7:	eb 05                	jmp    8019ee <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5f                   	pop    %edi
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	57                   	push   %edi
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 28             	sub    $0x28,%esp
  8019ff:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	e8 61 f5 ff ff       	call   800f6c <fd_alloc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	0f 88 24 01 00 00    	js     801b3c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	68 07 04 00 00       	push   $0x407
  801a20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a23:	6a 00                	push   $0x0
  801a25:	e8 12 f2 ff ff       	call   800c3c <sys_page_alloc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	0f 88 05 01 00 00    	js     801b3c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a3d:	50                   	push   %eax
  801a3e:	e8 29 f5 ff ff       	call   800f6c <fd_alloc>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	0f 88 dc 00 00 00    	js     801b2c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a50:	83 ec 04             	sub    $0x4,%esp
  801a53:	68 07 04 00 00       	push   $0x407
  801a58:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5b:	6a 00                	push   $0x0
  801a5d:	e8 da f1 ff ff       	call   800c3c <sys_page_alloc>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	0f 88 bd 00 00 00    	js     801b2c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a75:	e8 da f4 ff ff       	call   800f54 <fd2data>
  801a7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7c:	83 c4 0c             	add    $0xc,%esp
  801a7f:	68 07 04 00 00       	push   $0x407
  801a84:	50                   	push   %eax
  801a85:	6a 00                	push   $0x0
  801a87:	e8 b0 f1 ff ff       	call   800c3c <sys_page_alloc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	0f 88 83 00 00 00    	js     801b1c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9f:	e8 b0 f4 ff ff       	call   800f54 <fd2data>
  801aa4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aab:	50                   	push   %eax
  801aac:	6a 00                	push   $0x0
  801aae:	56                   	push   %esi
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 aa f1 ff ff       	call   800c60 <sys_page_map>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	83 c4 20             	add    $0x20,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 4f                	js     801b0e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801abf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801acd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ad4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801add:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aef:	e8 50 f4 ff ff       	call   800f44 <fd2num>
  801af4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801af6:	83 c4 04             	add    $0x4,%esp
  801af9:	ff 75 e0             	pushl  -0x20(%ebp)
  801afc:	e8 43 f4 ff ff       	call   800f44 <fd2num>
  801b01:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0c:	eb 2e                	jmp    801b3c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	56                   	push   %esi
  801b12:	6a 00                	push   $0x0
  801b14:	e8 6d f1 ff ff       	call   800c86 <sys_page_unmap>
  801b19:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b22:	6a 00                	push   $0x0
  801b24:	e8 5d f1 ff ff       	call   800c86 <sys_page_unmap>
  801b29:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b2c:	83 ec 08             	sub    $0x8,%esp
  801b2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b32:	6a 00                	push   $0x0
  801b34:	e8 4d f1 ff ff       	call   800c86 <sys_page_unmap>
  801b39:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b3c:	89 d8                	mov    %ebx,%eax
  801b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4f:	50                   	push   %eax
  801b50:	ff 75 08             	pushl  0x8(%ebp)
  801b53:	e8 87 f4 ff ff       	call   800fdf <fd_lookup>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	78 18                	js     801b77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	ff 75 f4             	pushl  -0xc(%ebp)
  801b65:	e8 ea f3 ff ff       	call   800f54 <fd2data>
	return _pipeisclosed(fd, p);
  801b6a:	89 c2                	mov    %eax,%edx
  801b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6f:	e8 0c fd ff ff       	call   801880 <_pipeisclosed>
  801b74:	83 c4 10             	add    $0x10,%esp
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    
  801b79:	00 00                	add    %al,(%eax)
	...

00801b7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b8c:	68 4a 25 80 00       	push   $0x80254a
  801b91:	ff 75 0c             	pushl  0xc(%ebp)
  801b94:	e8 21 ec ff ff       	call   8007ba <strcpy>
	return 0;
}
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb0:	74 45                	je     801bf7 <devcons_write+0x57>
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801bc7:	83 fb 7f             	cmp    $0x7f,%ebx
  801bca:	76 05                	jbe    801bd1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801bcc:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	53                   	push   %ebx
  801bd5:	03 45 0c             	add    0xc(%ebp),%eax
  801bd8:	50                   	push   %eax
  801bd9:	57                   	push   %edi
  801bda:	e8 9c ed ff ff       	call   80097b <memmove>
		sys_cputs(buf, m);
  801bdf:	83 c4 08             	add    $0x8,%esp
  801be2:	53                   	push   %ebx
  801be3:	57                   	push   %edi
  801be4:	e8 9c ef ff ff       	call   800b85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be9:	01 de                	add    %ebx,%esi
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf3:	72 cd                	jb     801bc2 <devcons_write+0x22>
  801bf5:	eb 05                	jmp    801bfc <devcons_write+0x5c>
  801bf7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfc:	89 f0                	mov    %esi,%eax
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c10:	75 07                	jne    801c19 <devcons_read+0x13>
  801c12:	eb 25                	jmp    801c39 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c14:	e8 fc ef ff ff       	call   800c15 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c19:	e8 8d ef ff ff       	call   800bab <sys_cgetc>
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	74 f2                	je     801c14 <devcons_read+0xe>
  801c22:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 1d                	js     801c45 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c28:	83 f8 04             	cmp    $0x4,%eax
  801c2b:	74 13                	je     801c40 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c30:	88 10                	mov    %dl,(%eax)
	return 1;
  801c32:	b8 01 00 00 00       	mov    $0x1,%eax
  801c37:	eb 0c                	jmp    801c45 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3e:	eb 05                	jmp    801c45 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c53:	6a 01                	push   $0x1
  801c55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c58:	50                   	push   %eax
  801c59:	e8 27 ef ff ff       	call   800b85 <sys_cputs>
  801c5e:	83 c4 10             	add    $0x10,%esp
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <getchar>:

int
getchar(void)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c69:	6a 01                	push   $0x1
  801c6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 ea f5 ff ff       	call   801260 <read>
	if (r < 0)
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	78 0f                	js     801c8c <getchar+0x29>
		return r;
	if (r < 1)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	7e 06                	jle    801c87 <getchar+0x24>
		return -E_EOF;
	return c;
  801c81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c85:	eb 05                	jmp    801c8c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c97:	50                   	push   %eax
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 3f f3 ff ff       	call   800fdf <fd_lookup>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 11                	js     801cb8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb0:	39 10                	cmp    %edx,(%eax)
  801cb2:	0f 94 c0             	sete   %al
  801cb5:	0f b6 c0             	movzbl %al,%eax
}
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <opencons>:

int
opencons(void)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc3:	50                   	push   %eax
  801cc4:	e8 a3 f2 ff ff       	call   800f6c <fd_alloc>
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 3a                	js     801d0a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	68 07 04 00 00       	push   $0x407
  801cd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 5a ef ff ff       	call   800c3c <sys_page_alloc>
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 21                	js     801d0a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	50                   	push   %eax
  801d02:	e8 3d f2 ff ff       	call   800f44 <fd2num>
  801d07:	83 c4 10             	add    $0x10,%esp
}
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	56                   	push   %esi
  801d10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d11:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d14:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d1a:	e8 d2 ee ff ff       	call   800bf1 <sys_getenvid>
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 75 0c             	pushl  0xc(%ebp)
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	53                   	push   %ebx
  801d29:	50                   	push   %eax
  801d2a:	68 58 25 80 00       	push   $0x802558
  801d2f:	e8 d0 e4 ff ff       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d34:	83 c4 18             	add    $0x18,%esp
  801d37:	56                   	push   %esi
  801d38:	ff 75 10             	pushl  0x10(%ebp)
  801d3b:	e8 73 e4 ff ff       	call   8001b3 <vcprintf>
	cprintf("\n");
  801d40:	c7 04 24 10 21 80 00 	movl   $0x802110,(%esp)
  801d47:	e8 b8 e4 ff ff       	call   800204 <cprintf>
  801d4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d4f:	cc                   	int3   
  801d50:	eb fd                	jmp    801d4f <_panic+0x43>
	...

00801d54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	8b 75 08             	mov    0x8(%ebp),%esi
  801d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801d62:	85 c0                	test   %eax,%eax
  801d64:	74 0e                	je     801d74 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	50                   	push   %eax
  801d6a:	e8 c8 ef ff ff       	call   800d37 <sys_ipc_recv>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	eb 10                	jmp    801d84 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801d74:	83 ec 0c             	sub    $0xc,%esp
  801d77:	68 00 00 c0 ee       	push   $0xeec00000
  801d7c:	e8 b6 ef ff ff       	call   800d37 <sys_ipc_recv>
  801d81:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801d84:	85 c0                	test   %eax,%eax
  801d86:	75 26                	jne    801dae <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d88:	85 f6                	test   %esi,%esi
  801d8a:	74 0a                	je     801d96 <ipc_recv+0x42>
  801d8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d91:	8b 40 74             	mov    0x74(%eax),%eax
  801d94:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d96:	85 db                	test   %ebx,%ebx
  801d98:	74 0a                	je     801da4 <ipc_recv+0x50>
  801d9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d9f:	8b 40 78             	mov    0x78(%eax),%eax
  801da2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801da4:	a1 04 40 80 00       	mov    0x804004,%eax
  801da9:	8b 40 70             	mov    0x70(%eax),%eax
  801dac:	eb 14                	jmp    801dc2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801dae:	85 f6                	test   %esi,%esi
  801db0:	74 06                	je     801db8 <ipc_recv+0x64>
  801db2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801db8:	85 db                	test   %ebx,%ebx
  801dba:	74 06                	je     801dc2 <ipc_recv+0x6e>
  801dbc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801dc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	57                   	push   %edi
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ddb:	85 db                	test   %ebx,%ebx
  801ddd:	75 25                	jne    801e04 <ipc_send+0x3b>
  801ddf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801de4:	eb 1e                	jmp    801e04 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801de6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801de9:	75 07                	jne    801df2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801deb:	e8 25 ee ff ff       	call   800c15 <sys_yield>
  801df0:	eb 12                	jmp    801e04 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801df2:	50                   	push   %eax
  801df3:	68 7c 25 80 00       	push   $0x80257c
  801df8:	6a 43                	push   $0x43
  801dfa:	68 8f 25 80 00       	push   $0x80258f
  801dff:	e8 08 ff ff ff       	call   801d0c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	57                   	push   %edi
  801e07:	ff 75 08             	pushl  0x8(%ebp)
  801e0a:	e8 03 ef ff ff       	call   800d12 <sys_ipc_try_send>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	75 d0                	jne    801de6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e19:	5b                   	pop    %ebx
  801e1a:	5e                   	pop    %esi
  801e1b:	5f                   	pop    %edi
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e24:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801e2a:	74 1a                	je     801e46 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e2c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801e31:	89 c2                	mov    %eax,%edx
  801e33:	c1 e2 07             	shl    $0x7,%edx
  801e36:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801e3d:	8b 52 50             	mov    0x50(%edx),%edx
  801e40:	39 ca                	cmp    %ecx,%edx
  801e42:	75 18                	jne    801e5c <ipc_find_env+0x3e>
  801e44:	eb 05                	jmp    801e4b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e4b:	89 c2                	mov    %eax,%edx
  801e4d:	c1 e2 07             	shl    $0x7,%edx
  801e50:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801e57:	8b 40 40             	mov    0x40(%eax),%eax
  801e5a:	eb 0c                	jmp    801e68 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e5c:	40                   	inc    %eax
  801e5d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e62:	75 cd                	jne    801e31 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e64:	66 b8 00 00          	mov    $0x0,%ax
}
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    
	...

00801e6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e72:	89 c2                	mov    %eax,%edx
  801e74:	c1 ea 16             	shr    $0x16,%edx
  801e77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e7e:	f6 c2 01             	test   $0x1,%dl
  801e81:	74 1e                	je     801ea1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e83:	c1 e8 0c             	shr    $0xc,%eax
  801e86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e8d:	a8 01                	test   $0x1,%al
  801e8f:	74 17                	je     801ea8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e91:	c1 e8 0c             	shr    $0xc,%eax
  801e94:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e9b:	ef 
  801e9c:	0f b7 c0             	movzwl %ax,%eax
  801e9f:	eb 0c                	jmp    801ead <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea6:	eb 05                	jmp    801ead <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    
	...

00801eb0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	57                   	push   %edi
  801eb4:	56                   	push   %esi
  801eb5:	83 ec 10             	sub    $0x10,%esp
  801eb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ebb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ebe:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ec1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ec4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ec7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	75 2e                	jne    801efc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ece:	39 f1                	cmp    %esi,%ecx
  801ed0:	77 5a                	ja     801f2c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ed2:	85 c9                	test   %ecx,%ecx
  801ed4:	75 0b                	jne    801ee1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f1                	div    %ecx
  801edf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ee1:	31 d2                	xor    %edx,%edx
  801ee3:	89 f0                	mov    %esi,%eax
  801ee5:	f7 f1                	div    %ecx
  801ee7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ee9:	89 f8                	mov    %edi,%eax
  801eeb:	f7 f1                	div    %ecx
  801eed:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801eef:	89 f8                	mov    %edi,%eax
  801ef1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    
  801efa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801efc:	39 f0                	cmp    %esi,%eax
  801efe:	77 1c                	ja     801f1c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f00:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801f03:	83 f7 1f             	xor    $0x1f,%edi
  801f06:	75 3c                	jne    801f44 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f08:	39 f0                	cmp    %esi,%eax
  801f0a:	0f 82 90 00 00 00    	jb     801fa0 <__udivdi3+0xf0>
  801f10:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f13:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801f16:	0f 86 84 00 00 00    	jbe    801fa0 <__udivdi3+0xf0>
  801f1c:	31 f6                	xor    %esi,%esi
  801f1e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f20:	89 f8                	mov    %edi,%eax
  801f22:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	5e                   	pop    %esi
  801f28:	5f                   	pop    %edi
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    
  801f2b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f2c:	89 f2                	mov    %esi,%edx
  801f2e:	89 f8                	mov    %edi,%eax
  801f30:	f7 f1                	div    %ecx
  801f32:	89 c7                	mov    %eax,%edi
  801f34:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f36:	89 f8                	mov    %edi,%eax
  801f38:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    
  801f41:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f44:	89 f9                	mov    %edi,%ecx
  801f46:	d3 e0                	shl    %cl,%eax
  801f48:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f4b:	b8 20 00 00 00       	mov    $0x20,%eax
  801f50:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f55:	88 c1                	mov    %al,%cl
  801f57:	d3 ea                	shr    %cl,%edx
  801f59:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f5c:	09 ca                	or     %ecx,%edx
  801f5e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801f61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f64:	89 f9                	mov    %edi,%ecx
  801f66:	d3 e2                	shl    %cl,%edx
  801f68:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801f6b:	89 f2                	mov    %esi,%edx
  801f6d:	88 c1                	mov    %al,%cl
  801f6f:	d3 ea                	shr    %cl,%edx
  801f71:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801f74:	89 f2                	mov    %esi,%edx
  801f76:	89 f9                	mov    %edi,%ecx
  801f78:	d3 e2                	shl    %cl,%edx
  801f7a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f7d:	88 c1                	mov    %al,%cl
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f83:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801f86:	89 f0                	mov    %esi,%eax
  801f88:	89 ca                	mov    %ecx,%edx
  801f8a:	f7 75 ec             	divl   -0x14(%ebp)
  801f8d:	89 d1                	mov    %edx,%ecx
  801f8f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f91:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f94:	39 d1                	cmp    %edx,%ecx
  801f96:	72 28                	jb     801fc0 <__udivdi3+0x110>
  801f98:	74 1a                	je     801fb4 <__udivdi3+0x104>
  801f9a:	89 f7                	mov    %esi,%edi
  801f9c:	31 f6                	xor    %esi,%esi
  801f9e:	eb 80                	jmp    801f20 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fa0:	31 f6                	xor    %esi,%esi
  801fa2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fa7:	89 f8                	mov    %edi,%eax
  801fa9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    
  801fb2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801fb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fb7:	89 f9                	mov    %edi,%ecx
  801fb9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fbb:	39 c2                	cmp    %eax,%edx
  801fbd:	73 db                	jae    801f9a <__udivdi3+0xea>
  801fbf:	90                   	nop
		{
		  q0--;
  801fc0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fc3:	31 f6                	xor    %esi,%esi
  801fc5:	e9 56 ff ff ff       	jmp    801f20 <__udivdi3+0x70>
	...

00801fcc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	57                   	push   %edi
  801fd0:	56                   	push   %esi
  801fd1:	83 ec 20             	sub    $0x20,%esp
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fda:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801fdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fe0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fe3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fe6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801fe9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801feb:	85 ff                	test   %edi,%edi
  801fed:	75 15                	jne    802004 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801fef:	39 f1                	cmp    %esi,%ecx
  801ff1:	0f 86 99 00 00 00    	jbe    802090 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ff7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ffd:	83 c4 20             	add    $0x20,%esp
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	c9                   	leave  
  802003:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802004:	39 f7                	cmp    %esi,%edi
  802006:	0f 87 a4 00 00 00    	ja     8020b0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80200c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80200f:	83 f0 1f             	xor    $0x1f,%eax
  802012:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802015:	0f 84 a1 00 00 00    	je     8020bc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80201b:	89 f8                	mov    %edi,%eax
  80201d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802020:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802022:	bf 20 00 00 00       	mov    $0x20,%edi
  802027:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80202a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80202d:	89 f9                	mov    %edi,%ecx
  80202f:	d3 ea                	shr    %cl,%edx
  802031:	09 c2                	or     %eax,%edx
  802033:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802039:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80203c:	d3 e0                	shl    %cl,%eax
  80203e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802041:	89 f2                	mov    %esi,%edx
  802043:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802045:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802048:	d3 e0                	shl    %cl,%eax
  80204a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80204d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802050:	89 f9                	mov    %edi,%ecx
  802052:	d3 e8                	shr    %cl,%eax
  802054:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802056:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802058:	89 f2                	mov    %esi,%edx
  80205a:	f7 75 f0             	divl   -0x10(%ebp)
  80205d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80205f:	f7 65 f4             	mull   -0xc(%ebp)
  802062:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802065:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802067:	39 d6                	cmp    %edx,%esi
  802069:	72 71                	jb     8020dc <__umoddi3+0x110>
  80206b:	74 7f                	je     8020ec <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80206d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802070:	29 c8                	sub    %ecx,%eax
  802072:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802074:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 f2                	mov    %esi,%edx
  80207b:	89 f9                	mov    %edi,%ecx
  80207d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80207f:	09 d0                	or     %edx,%eax
  802081:	89 f2                	mov    %esi,%edx
  802083:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802086:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802088:	83 c4 20             	add    $0x20,%esp
  80208b:	5e                   	pop    %esi
  80208c:	5f                   	pop    %edi
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    
  80208f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802090:	85 c9                	test   %ecx,%ecx
  802092:	75 0b                	jne    80209f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802094:	b8 01 00 00 00       	mov    $0x1,%eax
  802099:	31 d2                	xor    %edx,%edx
  80209b:	f7 f1                	div    %ecx
  80209d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80209f:	89 f0                	mov    %esi,%eax
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a8:	f7 f1                	div    %ecx
  8020aa:	e9 4a ff ff ff       	jmp    801ff9 <__umoddi3+0x2d>
  8020af:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8020b0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020b2:	83 c4 20             	add    $0x20,%esp
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    
  8020b9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	72 05                	jb     8020c5 <__umoddi3+0xf9>
  8020c0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8020c3:	77 0c                	ja     8020d1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020c5:	89 f2                	mov    %esi,%edx
  8020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ca:	29 c8                	sub    %ecx,%eax
  8020cc:	19 fa                	sbb    %edi,%edx
  8020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020d4:	83 c4 20             	add    $0x20,%esp
  8020d7:	5e                   	pop    %esi
  8020d8:	5f                   	pop    %edi
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    
  8020db:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8020df:	89 c1                	mov    %eax,%ecx
  8020e1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8020e4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8020e7:	eb 84                	jmp    80206d <__umoddi3+0xa1>
  8020e9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020ef:	72 eb                	jb     8020dc <__umoddi3+0x110>
  8020f1:	89 f2                	mov    %esi,%edx
  8020f3:	e9 75 ff ff ff       	jmp    80206d <__umoddi3+0xa1>
