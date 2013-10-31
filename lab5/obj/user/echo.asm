
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 62                	jle    8000aa <umain+0x76>
  800048:	8d 5e 04             	lea    0x4(%esi),%ebx
  80004b:	83 ec 08             	sub    $0x8,%esp
  80004e:	68 20 1e 80 00       	push   $0x801e20
  800053:	ff 76 04             	pushl  0x4(%esi)
  800056:	e8 00 02 00 00       	call   80025b <strcmp>
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	85 c0                	test   %eax,%eax
  800060:	75 5e                	jne    8000c0 <umain+0x8c>
		nflag = 1;
		argc--;
  800062:	4f                   	dec    %edi
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800063:	83 ff 01             	cmp    $0x1,%edi
  800066:	7f 61                	jg     8000c9 <umain+0x95>
  800068:	eb 6f                	jmp    8000d9 <umain+0xa5>
		if (i > 1)
  80006a:	83 fb 01             	cmp    $0x1,%ebx
  80006d:	7e 14                	jle    800083 <umain+0x4f>
			write(1, " ", 1);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	6a 01                	push   $0x1
  800074:	68 23 1e 80 00       	push   $0x801e23
  800079:	6a 01                	push   $0x1
  80007b:	e8 dc 0a 00 00       	call   800b5c <write>
  800080:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800083:	83 ec 0c             	sub    $0xc,%esp
  800086:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800089:	e8 c2 00 00 00       	call   800150 <strlen>
  80008e:	83 c4 0c             	add    $0xc,%esp
  800091:	50                   	push   %eax
  800092:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800095:	6a 01                	push   $0x1
  800097:	e8 c0 0a 00 00       	call   800b5c <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80009c:	43                   	inc    %ebx
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	39 fb                	cmp    %edi,%ebx
  8000a2:	7c c6                	jl     80006a <umain+0x36>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000a8:	75 2f                	jne    8000d9 <umain+0xa5>
		write(1, "\n", 1);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	6a 01                	push   $0x1
  8000af:	68 33 1f 80 00       	push   $0x801f33
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 a1 0a 00 00       	call   800b5c <write>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	eb 19                	jmp    8000d9 <umain+0xa5>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  8000c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8000c7:	eb 09                	jmp    8000d2 <umain+0x9e>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
  8000c9:	89 de                	mov    %ebx,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  8000cb:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  8000d2:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000d7:	eb aa                	jmp    800083 <umain+0x4f>
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
		write(1, "\n", 1);
}
  8000d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ef:	e8 e5 04 00 00       	call   8005d9 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	29 d0                	sub    %edx,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 f6                	test   %esi,%esi
  800111:	7e 07                	jle    80011a <libmain+0x36>
		binaryname = argv[0];
  800113:	8b 03                	mov    (%ebx),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	53                   	push   %ebx
  80011e:	56                   	push   %esi
  80011f:	e8 10 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
  800129:	83 c4 10             	add    $0x10,%esp
}
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	c9                   	leave  
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013a:	e8 2f 08 00 00       	call   80096e <close_all>
	sys_env_destroy(0);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	6a 00                	push   $0x0
  800144:	e8 6e 04 00 00       	call   8005b7 <sys_env_destroy>
  800149:	83 c4 10             	add    $0x10,%esp
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    
	...

00800150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800156:	80 3a 00             	cmpb   $0x0,(%edx)
  800159:	74 0e                	je     800169 <strlen+0x19>
  80015b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800160:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800161:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800165:	75 f9                	jne    800160 <strlen+0x10>
  800167:	eb 05                	jmp    80016e <strlen+0x1e>
  800169:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800179:	85 d2                	test   %edx,%edx
  80017b:	74 17                	je     800194 <strnlen+0x24>
  80017d:	80 39 00             	cmpb   $0x0,(%ecx)
  800180:	74 19                	je     80019b <strnlen+0x2b>
  800182:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800187:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800188:	39 d0                	cmp    %edx,%eax
  80018a:	74 14                	je     8001a0 <strnlen+0x30>
  80018c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800190:	75 f5                	jne    800187 <strnlen+0x17>
  800192:	eb 0c                	jmp    8001a0 <strnlen+0x30>
  800194:	b8 00 00 00 00       	mov    $0x0,%eax
  800199:	eb 05                	jmp    8001a0 <strnlen+0x30>
  80019b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	53                   	push   %ebx
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001b7:	42                   	inc    %edx
  8001b8:	84 c9                	test   %cl,%cl
  8001ba:	75 f5                	jne    8001b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001bc:	5b                   	pop    %ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	53                   	push   %ebx
  8001c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c6:	53                   	push   %ebx
  8001c7:	e8 84 ff ff ff       	call   800150 <strlen>
  8001cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8001d5:	50                   	push   %eax
  8001d6:	e8 c7 ff ff ff       	call   8001a2 <strcpy>
	return dst;
}
  8001db:	89 d8                	mov    %ebx,%eax
  8001dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f0:	85 f6                	test   %esi,%esi
  8001f2:	74 15                	je     800209 <strncpy+0x27>
  8001f4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8001f9:	8a 1a                	mov    (%edx),%bl
  8001fb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001fe:	80 3a 01             	cmpb   $0x1,(%edx)
  800201:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800204:	41                   	inc    %ecx
  800205:	39 ce                	cmp    %ecx,%esi
  800207:	77 f0                	ja     8001f9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	8b 7d 08             	mov    0x8(%ebp),%edi
  800216:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800219:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80021c:	85 f6                	test   %esi,%esi
  80021e:	74 32                	je     800252 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800220:	83 fe 01             	cmp    $0x1,%esi
  800223:	74 22                	je     800247 <strlcpy+0x3a>
  800225:	8a 0b                	mov    (%ebx),%cl
  800227:	84 c9                	test   %cl,%cl
  800229:	74 20                	je     80024b <strlcpy+0x3e>
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800232:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800235:	88 08                	mov    %cl,(%eax)
  800237:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800238:	39 f2                	cmp    %esi,%edx
  80023a:	74 11                	je     80024d <strlcpy+0x40>
  80023c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800240:	42                   	inc    %edx
  800241:	84 c9                	test   %cl,%cl
  800243:	75 f0                	jne    800235 <strlcpy+0x28>
  800245:	eb 06                	jmp    80024d <strlcpy+0x40>
  800247:	89 f8                	mov    %edi,%eax
  800249:	eb 02                	jmp    80024d <strlcpy+0x40>
  80024b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80024d:	c6 00 00             	movb   $0x0,(%eax)
  800250:	eb 02                	jmp    800254 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800252:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800254:	29 f8                	sub    %edi,%eax
}
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800264:	8a 01                	mov    (%ecx),%al
  800266:	84 c0                	test   %al,%al
  800268:	74 10                	je     80027a <strcmp+0x1f>
  80026a:	3a 02                	cmp    (%edx),%al
  80026c:	75 0c                	jne    80027a <strcmp+0x1f>
		p++, q++;
  80026e:	41                   	inc    %ecx
  80026f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800270:	8a 01                	mov    (%ecx),%al
  800272:	84 c0                	test   %al,%al
  800274:	74 04                	je     80027a <strcmp+0x1f>
  800276:	3a 02                	cmp    (%edx),%al
  800278:	74 f4                	je     80026e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80027a:	0f b6 c0             	movzbl %al,%eax
  80027d:	0f b6 12             	movzbl (%edx),%edx
  800280:	29 d0                	sub    %edx,%eax
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800291:	85 c0                	test   %eax,%eax
  800293:	74 1b                	je     8002b0 <strncmp+0x2c>
  800295:	8a 1a                	mov    (%edx),%bl
  800297:	84 db                	test   %bl,%bl
  800299:	74 24                	je     8002bf <strncmp+0x3b>
  80029b:	3a 19                	cmp    (%ecx),%bl
  80029d:	75 20                	jne    8002bf <strncmp+0x3b>
  80029f:	48                   	dec    %eax
  8002a0:	74 15                	je     8002b7 <strncmp+0x33>
		n--, p++, q++;
  8002a2:	42                   	inc    %edx
  8002a3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8002a4:	8a 1a                	mov    (%edx),%bl
  8002a6:	84 db                	test   %bl,%bl
  8002a8:	74 15                	je     8002bf <strncmp+0x3b>
  8002aa:	3a 19                	cmp    (%ecx),%bl
  8002ac:	74 f1                	je     80029f <strncmp+0x1b>
  8002ae:	eb 0f                	jmp    8002bf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b5:	eb 05                	jmp    8002bc <strncmp+0x38>
  8002b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002bc:	5b                   	pop    %ebx
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002bf:	0f b6 02             	movzbl (%edx),%eax
  8002c2:	0f b6 11             	movzbl (%ecx),%edx
  8002c5:	29 d0                	sub    %edx,%eax
  8002c7:	eb f3                	jmp    8002bc <strncmp+0x38>

008002c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002d2:	8a 10                	mov    (%eax),%dl
  8002d4:	84 d2                	test   %dl,%dl
  8002d6:	74 18                	je     8002f0 <strchr+0x27>
		if (*s == c)
  8002d8:	38 ca                	cmp    %cl,%dl
  8002da:	75 06                	jne    8002e2 <strchr+0x19>
  8002dc:	eb 17                	jmp    8002f5 <strchr+0x2c>
  8002de:	38 ca                	cmp    %cl,%dl
  8002e0:	74 13                	je     8002f5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002e2:	40                   	inc    %eax
  8002e3:	8a 10                	mov    (%eax),%dl
  8002e5:	84 d2                	test   %dl,%dl
  8002e7:	75 f5                	jne    8002de <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8002e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ee:	eb 05                	jmp    8002f5 <strchr+0x2c>
  8002f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800300:	8a 10                	mov    (%eax),%dl
  800302:	84 d2                	test   %dl,%dl
  800304:	74 11                	je     800317 <strfind+0x20>
		if (*s == c)
  800306:	38 ca                	cmp    %cl,%dl
  800308:	75 06                	jne    800310 <strfind+0x19>
  80030a:	eb 0b                	jmp    800317 <strfind+0x20>
  80030c:	38 ca                	cmp    %cl,%dl
  80030e:	74 07                	je     800317 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800310:	40                   	inc    %eax
  800311:	8a 10                	mov    (%eax),%dl
  800313:	84 d2                	test   %dl,%dl
  800315:	75 f5                	jne    80030c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
  800325:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800328:	85 c9                	test   %ecx,%ecx
  80032a:	74 30                	je     80035c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80032c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800332:	75 25                	jne    800359 <memset+0x40>
  800334:	f6 c1 03             	test   $0x3,%cl
  800337:	75 20                	jne    800359 <memset+0x40>
		c &= 0xFF;
  800339:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80033c:	89 d3                	mov    %edx,%ebx
  80033e:	c1 e3 08             	shl    $0x8,%ebx
  800341:	89 d6                	mov    %edx,%esi
  800343:	c1 e6 18             	shl    $0x18,%esi
  800346:	89 d0                	mov    %edx,%eax
  800348:	c1 e0 10             	shl    $0x10,%eax
  80034b:	09 f0                	or     %esi,%eax
  80034d:	09 d0                	or     %edx,%eax
  80034f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800351:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800354:	fc                   	cld    
  800355:	f3 ab                	rep stos %eax,%es:(%edi)
  800357:	eb 03                	jmp    80035c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800359:	fc                   	cld    
  80035a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80035c:	89 f8                	mov    %edi,%eax
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	c9                   	leave  
  800362:	c3                   	ret    

00800363 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800371:	39 c6                	cmp    %eax,%esi
  800373:	73 34                	jae    8003a9 <memmove+0x46>
  800375:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800378:	39 d0                	cmp    %edx,%eax
  80037a:	73 2d                	jae    8003a9 <memmove+0x46>
		s += n;
		d += n;
  80037c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80037f:	f6 c2 03             	test   $0x3,%dl
  800382:	75 1b                	jne    80039f <memmove+0x3c>
  800384:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80038a:	75 13                	jne    80039f <memmove+0x3c>
  80038c:	f6 c1 03             	test   $0x3,%cl
  80038f:	75 0e                	jne    80039f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800391:	83 ef 04             	sub    $0x4,%edi
  800394:	8d 72 fc             	lea    -0x4(%edx),%esi
  800397:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80039a:	fd                   	std    
  80039b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80039d:	eb 07                	jmp    8003a6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80039f:	4f                   	dec    %edi
  8003a0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8003a3:	fd                   	std    
  8003a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8003a6:	fc                   	cld    
  8003a7:	eb 20                	jmp    8003c9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8003af:	75 13                	jne    8003c4 <memmove+0x61>
  8003b1:	a8 03                	test   $0x3,%al
  8003b3:	75 0f                	jne    8003c4 <memmove+0x61>
  8003b5:	f6 c1 03             	test   $0x3,%cl
  8003b8:	75 0a                	jne    8003c4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8003ba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8003bd:	89 c7                	mov    %eax,%edi
  8003bf:	fc                   	cld    
  8003c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003c2:	eb 05                	jmp    8003c9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8003c4:	89 c7                	mov    %eax,%edi
  8003c6:	fc                   	cld    
  8003c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8003d0:	ff 75 10             	pushl  0x10(%ebp)
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	e8 85 ff ff ff       	call   800363 <memmove>
}
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ec:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003ef:	85 ff                	test   %edi,%edi
  8003f1:	74 32                	je     800425 <memcmp+0x45>
		if (*s1 != *s2)
  8003f3:	8a 03                	mov    (%ebx),%al
  8003f5:	8a 0e                	mov    (%esi),%cl
  8003f7:	38 c8                	cmp    %cl,%al
  8003f9:	74 19                	je     800414 <memcmp+0x34>
  8003fb:	eb 0d                	jmp    80040a <memcmp+0x2a>
  8003fd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800401:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800405:	42                   	inc    %edx
  800406:	38 c8                	cmp    %cl,%al
  800408:	74 10                	je     80041a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80040a:	0f b6 c0             	movzbl %al,%eax
  80040d:	0f b6 c9             	movzbl %cl,%ecx
  800410:	29 c8                	sub    %ecx,%eax
  800412:	eb 16                	jmp    80042a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800414:	4f                   	dec    %edi
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	39 fa                	cmp    %edi,%edx
  80041c:	75 df                	jne    8003fd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 05                	jmp    80042a <memcmp+0x4a>
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	c9                   	leave  
  80042e:	c3                   	ret    

0080042f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800435:	89 c2                	mov    %eax,%edx
  800437:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80043a:	39 d0                	cmp    %edx,%eax
  80043c:	73 12                	jae    800450 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80043e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800441:	38 08                	cmp    %cl,(%eax)
  800443:	75 06                	jne    80044b <memfind+0x1c>
  800445:	eb 09                	jmp    800450 <memfind+0x21>
  800447:	38 08                	cmp    %cl,(%eax)
  800449:	74 05                	je     800450 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80044b:	40                   	inc    %eax
  80044c:	39 c2                	cmp    %eax,%edx
  80044e:	77 f7                	ja     800447 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	8b 55 08             	mov    0x8(%ebp),%edx
  80045b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80045e:	eb 01                	jmp    800461 <strtol+0xf>
		s++;
  800460:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800461:	8a 02                	mov    (%edx),%al
  800463:	3c 20                	cmp    $0x20,%al
  800465:	74 f9                	je     800460 <strtol+0xe>
  800467:	3c 09                	cmp    $0x9,%al
  800469:	74 f5                	je     800460 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80046b:	3c 2b                	cmp    $0x2b,%al
  80046d:	75 08                	jne    800477 <strtol+0x25>
		s++;
  80046f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800470:	bf 00 00 00 00       	mov    $0x0,%edi
  800475:	eb 13                	jmp    80048a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800477:	3c 2d                	cmp    $0x2d,%al
  800479:	75 0a                	jne    800485 <strtol+0x33>
		s++, neg = 1;
  80047b:	8d 52 01             	lea    0x1(%edx),%edx
  80047e:	bf 01 00 00 00       	mov    $0x1,%edi
  800483:	eb 05                	jmp    80048a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800485:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80048a:	85 db                	test   %ebx,%ebx
  80048c:	74 05                	je     800493 <strtol+0x41>
  80048e:	83 fb 10             	cmp    $0x10,%ebx
  800491:	75 28                	jne    8004bb <strtol+0x69>
  800493:	8a 02                	mov    (%edx),%al
  800495:	3c 30                	cmp    $0x30,%al
  800497:	75 10                	jne    8004a9 <strtol+0x57>
  800499:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80049d:	75 0a                	jne    8004a9 <strtol+0x57>
		s += 2, base = 16;
  80049f:	83 c2 02             	add    $0x2,%edx
  8004a2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8004a7:	eb 12                	jmp    8004bb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	75 0e                	jne    8004bb <strtol+0x69>
  8004ad:	3c 30                	cmp    $0x30,%al
  8004af:	75 05                	jne    8004b6 <strtol+0x64>
		s++, base = 8;
  8004b1:	42                   	inc    %edx
  8004b2:	b3 08                	mov    $0x8,%bl
  8004b4:	eb 05                	jmp    8004bb <strtol+0x69>
	else if (base == 0)
		base = 10;
  8004b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8004c2:	8a 0a                	mov    (%edx),%cl
  8004c4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8004c7:	80 fb 09             	cmp    $0x9,%bl
  8004ca:	77 08                	ja     8004d4 <strtol+0x82>
			dig = *s - '0';
  8004cc:	0f be c9             	movsbl %cl,%ecx
  8004cf:	83 e9 30             	sub    $0x30,%ecx
  8004d2:	eb 1e                	jmp    8004f2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8004d4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8004d7:	80 fb 19             	cmp    $0x19,%bl
  8004da:	77 08                	ja     8004e4 <strtol+0x92>
			dig = *s - 'a' + 10;
  8004dc:	0f be c9             	movsbl %cl,%ecx
  8004df:	83 e9 57             	sub    $0x57,%ecx
  8004e2:	eb 0e                	jmp    8004f2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8004e4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8004e7:	80 fb 19             	cmp    $0x19,%bl
  8004ea:	77 13                	ja     8004ff <strtol+0xad>
			dig = *s - 'A' + 10;
  8004ec:	0f be c9             	movsbl %cl,%ecx
  8004ef:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8004f2:	39 f1                	cmp    %esi,%ecx
  8004f4:	7d 0d                	jge    800503 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8004f6:	42                   	inc    %edx
  8004f7:	0f af c6             	imul   %esi,%eax
  8004fa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8004fd:	eb c3                	jmp    8004c2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8004ff:	89 c1                	mov    %eax,%ecx
  800501:	eb 02                	jmp    800505 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800503:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800509:	74 05                	je     800510 <strtol+0xbe>
		*endptr = (char *) s;
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800510:	85 ff                	test   %edi,%edi
  800512:	74 04                	je     800518 <strtol+0xc6>
  800514:	89 c8                	mov    %ecx,%eax
  800516:	f7 d8                	neg    %eax
}
  800518:	5b                   	pop    %ebx
  800519:	5e                   	pop    %esi
  80051a:	5f                   	pop    %edi
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    
  80051d:	00 00                	add    %al,(%eax)
	...

00800520 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	57                   	push   %edi
  800524:	56                   	push   %esi
  800525:	53                   	push   %ebx
  800526:	83 ec 1c             	sub    $0x1c,%esp
  800529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80052f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800531:	8b 75 14             	mov    0x14(%ebp),%esi
  800534:	8b 7d 10             	mov    0x10(%ebp),%edi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053d:	cd 30                	int    $0x30
  80053f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	74 1c                	je     800563 <syscall+0x43>
  800547:	85 c0                	test   %eax,%eax
  800549:	7e 18                	jle    800563 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  80054b:	83 ec 0c             	sub    $0xc,%esp
  80054e:	50                   	push   %eax
  80054f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800552:	68 2f 1e 80 00       	push   $0x801e2f
  800557:	6a 42                	push   $0x42
  800559:	68 4c 1e 80 00       	push   $0x801e4c
  80055e:	e8 b5 0e 00 00       	call   801418 <_panic>

	return ret;
}
  800563:	89 d0                	mov    %edx,%eax
  800565:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800568:	5b                   	pop    %ebx
  800569:	5e                   	pop    %esi
  80056a:	5f                   	pop    %edi
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800573:	6a 00                	push   $0x0
  800575:	6a 00                	push   $0x0
  800577:	6a 00                	push   $0x0
  800579:	ff 75 0c             	pushl  0xc(%ebp)
  80057c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	b8 00 00 00 00       	mov    $0x0,%eax
  800589:	e8 92 ff ff ff       	call   800520 <syscall>
  80058e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <sys_cgetc>:

int
sys_cgetc(void)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800599:	6a 00                	push   $0x0
  80059b:	6a 00                	push   $0x0
  80059d:	6a 00                	push   $0x0
  80059f:	6a 00                	push   $0x0
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8005b0:	e8 6b ff ff ff       	call   800520 <syscall>
}
  8005b5:	c9                   	leave  
  8005b6:	c3                   	ret    

008005b7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8005b7:	55                   	push   %ebp
  8005b8:	89 e5                	mov    %esp,%ebp
  8005ba:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8005bd:	6a 00                	push   $0x0
  8005bf:	6a 00                	push   $0x0
  8005c1:	6a 00                	push   $0x0
  8005c3:	6a 00                	push   $0x0
  8005c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c8:	ba 01 00 00 00       	mov    $0x1,%edx
  8005cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8005d2:	e8 49 ff ff ff       	call   800520 <syscall>
}
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    

008005d9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8005df:	6a 00                	push   $0x0
  8005e1:	6a 00                	push   $0x0
  8005e3:	6a 00                	push   $0x0
  8005e5:	6a 00                	push   $0x0
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8005f6:	e8 25 ff ff ff       	call   800520 <syscall>
}
  8005fb:	c9                   	leave  
  8005fc:	c3                   	ret    

008005fd <sys_yield>:

void
sys_yield(void)
{
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800603:	6a 00                	push   $0x0
  800605:	6a 00                	push   $0x0
  800607:	6a 00                	push   $0x0
  800609:	6a 00                	push   $0x0
  80060b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800610:	ba 00 00 00 00       	mov    $0x0,%edx
  800615:	b8 0b 00 00 00       	mov    $0xb,%eax
  80061a:	e8 01 ff ff ff       	call   800520 <syscall>
  80061f:	83 c4 10             	add    $0x10,%esp
}
  800622:	c9                   	leave  
  800623:	c3                   	ret    

00800624 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80062a:	6a 00                	push   $0x0
  80062c:	6a 00                	push   $0x0
  80062e:	ff 75 10             	pushl  0x10(%ebp)
  800631:	ff 75 0c             	pushl  0xc(%ebp)
  800634:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800637:	ba 01 00 00 00       	mov    $0x1,%edx
  80063c:	b8 04 00 00 00       	mov    $0x4,%eax
  800641:	e8 da fe ff ff       	call   800520 <syscall>
}
  800646:	c9                   	leave  
  800647:	c3                   	ret    

00800648 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80064e:	ff 75 18             	pushl  0x18(%ebp)
  800651:	ff 75 14             	pushl  0x14(%ebp)
  800654:	ff 75 10             	pushl  0x10(%ebp)
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065d:	ba 01 00 00 00       	mov    $0x1,%edx
  800662:	b8 05 00 00 00       	mov    $0x5,%eax
  800667:	e8 b4 fe ff ff       	call   800520 <syscall>
}
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800674:	6a 00                	push   $0x0
  800676:	6a 00                	push   $0x0
  800678:	6a 00                	push   $0x0
  80067a:	ff 75 0c             	pushl  0xc(%ebp)
  80067d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800680:	ba 01 00 00 00       	mov    $0x1,%edx
  800685:	b8 06 00 00 00       	mov    $0x6,%eax
  80068a:	e8 91 fe ff ff       	call   800520 <syscall>
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800697:	6a 00                	push   $0x0
  800699:	6a 00                	push   $0x0
  80069b:	6a 00                	push   $0x0
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a3:	ba 01 00 00 00       	mov    $0x1,%edx
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ad:	e8 6e fe ff ff       	call   800520 <syscall>
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8006ba:	6a 00                	push   $0x0
  8006bc:	6a 00                	push   $0x0
  8006be:	6a 00                	push   $0x0
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c6:	ba 01 00 00 00       	mov    $0x1,%edx
  8006cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8006d0:	e8 4b fe ff ff       	call   800520 <syscall>
}
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8006dd:	6a 00                	push   $0x0
  8006df:	6a 00                	push   $0x0
  8006e1:	6a 00                	push   $0x0
  8006e3:	ff 75 0c             	pushl  0xc(%ebp)
  8006e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8006ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f3:	e8 28 fe ff ff       	call   800520 <syscall>
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    

008006fa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800700:	6a 00                	push   $0x0
  800702:	ff 75 14             	pushl  0x14(%ebp)
  800705:	ff 75 10             	pushl  0x10(%ebp)
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070e:	ba 00 00 00 00       	mov    $0x0,%edx
  800713:	b8 0c 00 00 00       	mov    $0xc,%eax
  800718:	e8 03 fe ff ff       	call   800520 <syscall>
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800725:	6a 00                	push   $0x0
  800727:	6a 00                	push   $0x0
  800729:	6a 00                	push   $0x0
  80072b:	6a 00                	push   $0x0
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800730:	ba 01 00 00 00       	mov    $0x1,%edx
  800735:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073a:	e8 e1 fd ff ff       	call   800520 <syscall>
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800747:	6a 00                	push   $0x0
  800749:	6a 00                	push   $0x0
  80074b:	6a 00                	push   $0x0
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	ba 00 00 00 00       	mov    $0x0,%edx
  800758:	b8 0e 00 00 00       	mov    $0xe,%eax
  80075d:	e8 be fd ff ff       	call   800520 <syscall>
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	05 00 00 00 30       	add    $0x30000000,%eax
  80076f:	c1 e8 0c             	shr    $0xc,%eax
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 e5 ff ff ff       	call   800764 <fd2num>
  80077f:	83 c4 04             	add    $0x4,%esp
  800782:	05 20 00 0d 00       	add    $0xd0020,%eax
  800787:	c1 e0 0c             	shl    $0xc,%eax
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800793:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800798:	a8 01                	test   $0x1,%al
  80079a:	74 34                	je     8007d0 <fd_alloc+0x44>
  80079c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8007a1:	a8 01                	test   $0x1,%al
  8007a3:	74 32                	je     8007d7 <fd_alloc+0x4b>
  8007a5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8007aa:	89 c1                	mov    %eax,%ecx
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	c1 ea 16             	shr    $0x16,%edx
  8007b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007b8:	f6 c2 01             	test   $0x1,%dl
  8007bb:	74 1f                	je     8007dc <fd_alloc+0x50>
  8007bd:	89 c2                	mov    %eax,%edx
  8007bf:	c1 ea 0c             	shr    $0xc,%edx
  8007c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007c9:	f6 c2 01             	test   $0x1,%dl
  8007cc:	75 17                	jne    8007e5 <fd_alloc+0x59>
  8007ce:	eb 0c                	jmp    8007dc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8007d0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8007d5:	eb 05                	jmp    8007dc <fd_alloc+0x50>
  8007d7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8007dc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 17                	jmp    8007fc <fd_alloc+0x70>
  8007e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007ef:	75 b9                	jne    8007aa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8007f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800805:	83 f8 1f             	cmp    $0x1f,%eax
  800808:	77 36                	ja     800840 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80080a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80080f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800812:	89 c2                	mov    %eax,%edx
  800814:	c1 ea 16             	shr    $0x16,%edx
  800817:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80081e:	f6 c2 01             	test   $0x1,%dl
  800821:	74 24                	je     800847 <fd_lookup+0x48>
  800823:	89 c2                	mov    %eax,%edx
  800825:	c1 ea 0c             	shr    $0xc,%edx
  800828:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80082f:	f6 c2 01             	test   $0x1,%dl
  800832:	74 1a                	je     80084e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	89 02                	mov    %eax,(%edx)
	return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	eb 13                	jmp    800853 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800845:	eb 0c                	jmp    800853 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb 05                	jmp    800853 <fd_lookup+0x54>
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800862:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800868:	74 0d                	je     800877 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	eb 14                	jmp    800885 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800871:	39 0a                	cmp    %ecx,(%edx)
  800873:	75 10                	jne    800885 <dev_lookup+0x30>
  800875:	eb 05                	jmp    80087c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800877:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80087c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
  800883:	eb 31                	jmp    8008b6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800885:	40                   	inc    %eax
  800886:	8b 14 85 d8 1e 80 00 	mov    0x801ed8(,%eax,4),%edx
  80088d:	85 d2                	test   %edx,%edx
  80088f:	75 e0                	jne    800871 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800891:	a1 04 40 80 00       	mov    0x804004,%eax
  800896:	8b 40 48             	mov    0x48(%eax),%eax
  800899:	83 ec 04             	sub    $0x4,%esp
  80089c:	51                   	push   %ecx
  80089d:	50                   	push   %eax
  80089e:	68 5c 1e 80 00       	push   $0x801e5c
  8008a3:	e8 48 0c 00 00       	call   8014f0 <cprintf>
	*dev = 0;
  8008a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 20             	sub    $0x20,%esp
  8008c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c6:	8a 45 0c             	mov    0xc(%ebp),%al
  8008c9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008cc:	56                   	push   %esi
  8008cd:	e8 92 fe ff ff       	call   800764 <fd2num>
  8008d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008d5:	89 14 24             	mov    %edx,(%esp)
  8008d8:	50                   	push   %eax
  8008d9:	e8 21 ff ff ff       	call   8007ff <fd_lookup>
  8008de:	89 c3                	mov    %eax,%ebx
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	78 05                	js     8008ec <fd_close+0x31>
	    || fd != fd2)
  8008e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008ea:	74 0d                	je     8008f9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8008ec:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8008f0:	75 48                	jne    80093a <fd_close+0x7f>
  8008f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008f7:	eb 41                	jmp    80093a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	ff 36                	pushl  (%esi)
  800902:	e8 4e ff ff ff       	call   800855 <dev_lookup>
  800907:	89 c3                	mov    %eax,%ebx
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	85 c0                	test   %eax,%eax
  80090e:	78 1c                	js     80092c <fd_close+0x71>
		if (dev->dev_close)
  800910:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800913:	8b 40 10             	mov    0x10(%eax),%eax
  800916:	85 c0                	test   %eax,%eax
  800918:	74 0d                	je     800927 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	56                   	push   %esi
  80091e:	ff d0                	call   *%eax
  800920:	89 c3                	mov    %eax,%ebx
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	eb 05                	jmp    80092c <fd_close+0x71>
		else
			r = 0;
  800927:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	56                   	push   %esi
  800930:	6a 00                	push   $0x0
  800932:	e8 37 fd ff ff       	call   80066e <sys_page_unmap>
	return r;
  800937:	83 c4 10             	add    $0x10,%esp
}
  80093a:	89 d8                	mov    %ebx,%eax
  80093c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094c:	50                   	push   %eax
  80094d:	ff 75 08             	pushl  0x8(%ebp)
  800950:	e8 aa fe ff ff       	call   8007ff <fd_lookup>
  800955:	83 c4 08             	add    $0x8,%esp
  800958:	85 c0                	test   %eax,%eax
  80095a:	78 10                	js     80096c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	6a 01                	push   $0x1
  800961:	ff 75 f4             	pushl  -0xc(%ebp)
  800964:	e8 52 ff ff ff       	call   8008bb <fd_close>
  800969:	83 c4 10             	add    $0x10,%esp
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <close_all>:

void
close_all(void)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800975:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80097a:	83 ec 0c             	sub    $0xc,%esp
  80097d:	53                   	push   %ebx
  80097e:	e8 c0 ff ff ff       	call   800943 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800983:	43                   	inc    %ebx
  800984:	83 c4 10             	add    $0x10,%esp
  800987:	83 fb 20             	cmp    $0x20,%ebx
  80098a:	75 ee                	jne    80097a <close_all+0xc>
		close(i);
}
  80098c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	83 ec 2c             	sub    $0x2c,%esp
  80099a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80099d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009a0:	50                   	push   %eax
  8009a1:	ff 75 08             	pushl  0x8(%ebp)
  8009a4:	e8 56 fe ff ff       	call   8007ff <fd_lookup>
  8009a9:	89 c3                	mov    %eax,%ebx
  8009ab:	83 c4 08             	add    $0x8,%esp
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	0f 88 c0 00 00 00    	js     800a76 <dup+0xe5>
		return r;
	close(newfdnum);
  8009b6:	83 ec 0c             	sub    $0xc,%esp
  8009b9:	57                   	push   %edi
  8009ba:	e8 84 ff ff ff       	call   800943 <close>

	newfd = INDEX2FD(newfdnum);
  8009bf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8009c5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8009c8:	83 c4 04             	add    $0x4,%esp
  8009cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009ce:	e8 a1 fd ff ff       	call   800774 <fd2data>
  8009d3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009d5:	89 34 24             	mov    %esi,(%esp)
  8009d8:	e8 97 fd ff ff       	call   800774 <fd2data>
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009e3:	89 d8                	mov    %ebx,%eax
  8009e5:	c1 e8 16             	shr    $0x16,%eax
  8009e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009ef:	a8 01                	test   $0x1,%al
  8009f1:	74 37                	je     800a2a <dup+0x99>
  8009f3:	89 d8                	mov    %ebx,%eax
  8009f5:	c1 e8 0c             	shr    $0xc,%eax
  8009f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009ff:	f6 c2 01             	test   $0x1,%dl
  800a02:	74 26                	je     800a2a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a0b:	83 ec 0c             	sub    $0xc,%esp
  800a0e:	25 07 0e 00 00       	and    $0xe07,%eax
  800a13:	50                   	push   %eax
  800a14:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a17:	6a 00                	push   $0x0
  800a19:	53                   	push   %ebx
  800a1a:	6a 00                	push   $0x0
  800a1c:	e8 27 fc ff ff       	call   800648 <sys_page_map>
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	83 c4 20             	add    $0x20,%esp
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 2d                	js     800a57 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a2d:	89 c2                	mov    %eax,%edx
  800a2f:	c1 ea 0c             	shr    $0xc,%edx
  800a32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a42:	52                   	push   %edx
  800a43:	56                   	push   %esi
  800a44:	6a 00                	push   $0x0
  800a46:	50                   	push   %eax
  800a47:	6a 00                	push   $0x0
  800a49:	e8 fa fb ff ff       	call   800648 <sys_page_map>
  800a4e:	89 c3                	mov    %eax,%ebx
  800a50:	83 c4 20             	add    $0x20,%esp
  800a53:	85 c0                	test   %eax,%eax
  800a55:	79 1d                	jns    800a74 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	56                   	push   %esi
  800a5b:	6a 00                	push   $0x0
  800a5d:	e8 0c fc ff ff       	call   80066e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a62:	83 c4 08             	add    $0x8,%esp
  800a65:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a68:	6a 00                	push   $0x0
  800a6a:	e8 ff fb ff ff       	call   80066e <sys_page_unmap>
	return r;
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	eb 02                	jmp    800a76 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800a74:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a76:	89 d8                	mov    %ebx,%eax
  800a78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	83 ec 14             	sub    $0x14,%esp
  800a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a8d:	50                   	push   %eax
  800a8e:	53                   	push   %ebx
  800a8f:	e8 6b fd ff ff       	call   8007ff <fd_lookup>
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	85 c0                	test   %eax,%eax
  800a99:	78 67                	js     800b02 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa5:	ff 30                	pushl  (%eax)
  800aa7:	e8 a9 fd ff ff       	call   800855 <dev_lookup>
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	78 4f                	js     800b02 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab6:	8b 50 08             	mov    0x8(%eax),%edx
  800ab9:	83 e2 03             	and    $0x3,%edx
  800abc:	83 fa 01             	cmp    $0x1,%edx
  800abf:	75 21                	jne    800ae2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ac1:	a1 04 40 80 00       	mov    0x804004,%eax
  800ac6:	8b 40 48             	mov    0x48(%eax),%eax
  800ac9:	83 ec 04             	sub    $0x4,%esp
  800acc:	53                   	push   %ebx
  800acd:	50                   	push   %eax
  800ace:	68 9d 1e 80 00       	push   $0x801e9d
  800ad3:	e8 18 0a 00 00       	call   8014f0 <cprintf>
		return -E_INVAL;
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae0:	eb 20                	jmp    800b02 <read+0x82>
	}
	if (!dev->dev_read)
  800ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae5:	8b 52 08             	mov    0x8(%edx),%edx
  800ae8:	85 d2                	test   %edx,%edx
  800aea:	74 11                	je     800afd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800aec:	83 ec 04             	sub    $0x4,%esp
  800aef:	ff 75 10             	pushl  0x10(%ebp)
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	50                   	push   %eax
  800af6:	ff d2                	call   *%edx
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	eb 05                	jmp    800b02 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800afd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 0c             	sub    $0xc,%esp
  800b10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b13:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b16:	85 f6                	test   %esi,%esi
  800b18:	74 31                	je     800b4b <readn+0x44>
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b24:	83 ec 04             	sub    $0x4,%esp
  800b27:	89 f2                	mov    %esi,%edx
  800b29:	29 c2                	sub    %eax,%edx
  800b2b:	52                   	push   %edx
  800b2c:	03 45 0c             	add    0xc(%ebp),%eax
  800b2f:	50                   	push   %eax
  800b30:	57                   	push   %edi
  800b31:	e8 4a ff ff ff       	call   800a80 <read>
		if (m < 0)
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	78 17                	js     800b54 <readn+0x4d>
			return m;
		if (m == 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	74 11                	je     800b52 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b41:	01 c3                	add    %eax,%ebx
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	39 f3                	cmp    %esi,%ebx
  800b47:	72 db                	jb     800b24 <readn+0x1d>
  800b49:	eb 09                	jmp    800b54 <readn+0x4d>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	eb 02                	jmp    800b54 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800b52:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 14             	sub    $0x14,%esp
  800b63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b69:	50                   	push   %eax
  800b6a:	53                   	push   %ebx
  800b6b:	e8 8f fc ff ff       	call   8007ff <fd_lookup>
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	85 c0                	test   %eax,%eax
  800b75:	78 62                	js     800bd9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b77:	83 ec 08             	sub    $0x8,%esp
  800b7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b7d:	50                   	push   %eax
  800b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b81:	ff 30                	pushl  (%eax)
  800b83:	e8 cd fc ff ff       	call   800855 <dev_lookup>
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	78 4a                	js     800bd9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b92:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b96:	75 21                	jne    800bb9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b98:	a1 04 40 80 00       	mov    0x804004,%eax
  800b9d:	8b 40 48             	mov    0x48(%eax),%eax
  800ba0:	83 ec 04             	sub    $0x4,%esp
  800ba3:	53                   	push   %ebx
  800ba4:	50                   	push   %eax
  800ba5:	68 b9 1e 80 00       	push   $0x801eb9
  800baa:	e8 41 09 00 00       	call   8014f0 <cprintf>
		return -E_INVAL;
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bb7:	eb 20                	jmp    800bd9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bbc:	8b 52 0c             	mov    0xc(%edx),%edx
  800bbf:	85 d2                	test   %edx,%edx
  800bc1:	74 11                	je     800bd4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bc3:	83 ec 04             	sub    $0x4,%esp
  800bc6:	ff 75 10             	pushl  0x10(%ebp)
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	50                   	push   %eax
  800bcd:	ff d2                	call   *%edx
  800bcf:	83 c4 10             	add    $0x10,%esp
  800bd2:	eb 05                	jmp    800bd9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800bd4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <seek>:

int
seek(int fdnum, off_t offset)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800be4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800be7:	50                   	push   %eax
  800be8:	ff 75 08             	pushl  0x8(%ebp)
  800beb:	e8 0f fc ff ff       	call   8007ff <fd_lookup>
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	78 0e                	js     800c05 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 14             	sub    $0x14,%esp
  800c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c14:	50                   	push   %eax
  800c15:	53                   	push   %ebx
  800c16:	e8 e4 fb ff ff       	call   8007ff <fd_lookup>
  800c1b:	83 c4 08             	add    $0x8,%esp
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	78 5f                	js     800c81 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c28:	50                   	push   %eax
  800c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2c:	ff 30                	pushl  (%eax)
  800c2e:	e8 22 fc ff ff       	call   800855 <dev_lookup>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	85 c0                	test   %eax,%eax
  800c38:	78 47                	js     800c81 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c41:	75 21                	jne    800c64 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c43:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c48:	8b 40 48             	mov    0x48(%eax),%eax
  800c4b:	83 ec 04             	sub    $0x4,%esp
  800c4e:	53                   	push   %ebx
  800c4f:	50                   	push   %eax
  800c50:	68 7c 1e 80 00       	push   $0x801e7c
  800c55:	e8 96 08 00 00       	call   8014f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c62:	eb 1d                	jmp    800c81 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c67:	8b 52 18             	mov    0x18(%edx),%edx
  800c6a:	85 d2                	test   %edx,%edx
  800c6c:	74 0e                	je     800c7c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c6e:	83 ec 08             	sub    $0x8,%esp
  800c71:	ff 75 0c             	pushl  0xc(%ebp)
  800c74:	50                   	push   %eax
  800c75:	ff d2                	call   *%edx
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	eb 05                	jmp    800c81 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 14             	sub    $0x14,%esp
  800c8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c93:	50                   	push   %eax
  800c94:	ff 75 08             	pushl  0x8(%ebp)
  800c97:	e8 63 fb ff ff       	call   8007ff <fd_lookup>
  800c9c:	83 c4 08             	add    $0x8,%esp
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	78 52                	js     800cf5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca3:	83 ec 08             	sub    $0x8,%esp
  800ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca9:	50                   	push   %eax
  800caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cad:	ff 30                	pushl  (%eax)
  800caf:	e8 a1 fb ff ff       	call   800855 <dev_lookup>
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	78 3a                	js     800cf5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cc2:	74 2c                	je     800cf0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cc4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cc7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cce:	00 00 00 
	stat->st_isdir = 0;
  800cd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cd8:	00 00 00 
	stat->st_dev = dev;
  800cdb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ce1:	83 ec 08             	sub    $0x8,%esp
  800ce4:	53                   	push   %ebx
  800ce5:	ff 75 f0             	pushl  -0x10(%ebp)
  800ce8:	ff 50 14             	call   *0x14(%eax)
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	eb 05                	jmp    800cf5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cf0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cff:	83 ec 08             	sub    $0x8,%esp
  800d02:	6a 00                	push   $0x0
  800d04:	ff 75 08             	pushl  0x8(%ebp)
  800d07:	e8 78 01 00 00       	call   800e84 <open>
  800d0c:	89 c3                	mov    %eax,%ebx
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	85 c0                	test   %eax,%eax
  800d13:	78 1b                	js     800d30 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d15:	83 ec 08             	sub    $0x8,%esp
  800d18:	ff 75 0c             	pushl  0xc(%ebp)
  800d1b:	50                   	push   %eax
  800d1c:	e8 65 ff ff ff       	call   800c86 <fstat>
  800d21:	89 c6                	mov    %eax,%esi
	close(fd);
  800d23:	89 1c 24             	mov    %ebx,(%esp)
  800d26:	e8 18 fc ff ff       	call   800943 <close>
	return r;
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	89 f3                	mov    %esi,%ebx
}
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    
  800d39:	00 00                	add    %al,(%eax)
	...

00800d3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800d45:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d4c:	75 12                	jne    800d60 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	6a 01                	push   $0x1
  800d53:	e8 c6 0d 00 00       	call   801b1e <ipc_find_env>
  800d58:	a3 00 40 80 00       	mov    %eax,0x804000
  800d5d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d60:	6a 07                	push   $0x7
  800d62:	68 00 50 80 00       	push   $0x805000
  800d67:	53                   	push   %ebx
  800d68:	ff 35 00 40 80 00    	pushl  0x804000
  800d6e:	e8 56 0d 00 00       	call   801ac9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800d73:	83 c4 0c             	add    $0xc,%esp
  800d76:	6a 00                	push   $0x0
  800d78:	56                   	push   %esi
  800d79:	6a 00                	push   $0x0
  800d7b:	e8 d4 0c 00 00       	call   801a54 <ipc_recv>
}
  800d80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	8b 40 0c             	mov    0xc(%eax),%eax
  800d97:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	b8 05 00 00 00       	mov    $0x5,%eax
  800da6:	e8 91 ff ff ff       	call   800d3c <fsipc>
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 2c                	js     800ddb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800daf:	83 ec 08             	sub    $0x8,%esp
  800db2:	68 00 50 80 00       	push   $0x805000
  800db7:	53                   	push   %ebx
  800db8:	e8 e5 f3 ff ff       	call   8001a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dbd:	a1 80 50 80 00       	mov    0x805080,%eax
  800dc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dc8:	a1 84 50 80 00       	mov    0x805084,%eax
  800dcd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfb:	e8 3c ff ff ff       	call   800d3c <fsipc>
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e20:	b8 03 00 00 00       	mov    $0x3,%eax
  800e25:	e8 12 ff ff ff       	call   800d3c <fsipc>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 4b                	js     800e7b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e30:	39 c6                	cmp    %eax,%esi
  800e32:	73 16                	jae    800e4a <devfile_read+0x48>
  800e34:	68 e8 1e 80 00       	push   $0x801ee8
  800e39:	68 ef 1e 80 00       	push   $0x801eef
  800e3e:	6a 7d                	push   $0x7d
  800e40:	68 04 1f 80 00       	push   $0x801f04
  800e45:	e8 ce 05 00 00       	call   801418 <_panic>
	assert(r <= PGSIZE);
  800e4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e4f:	7e 16                	jle    800e67 <devfile_read+0x65>
  800e51:	68 0f 1f 80 00       	push   $0x801f0f
  800e56:	68 ef 1e 80 00       	push   $0x801eef
  800e5b:	6a 7e                	push   $0x7e
  800e5d:	68 04 1f 80 00       	push   $0x801f04
  800e62:	e8 b1 05 00 00       	call   801418 <_panic>
	memmove(buf, &fsipcbuf, r);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	50                   	push   %eax
  800e6b:	68 00 50 80 00       	push   $0x805000
  800e70:	ff 75 0c             	pushl  0xc(%ebp)
  800e73:	e8 eb f4 ff ff       	call   800363 <memmove>
	return r;
  800e78:	83 c4 10             	add    $0x10,%esp
}
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 1c             	sub    $0x1c,%esp
  800e8c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e8f:	56                   	push   %esi
  800e90:	e8 bb f2 ff ff       	call   800150 <strlen>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e9d:	7f 65                	jg     800f04 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea5:	50                   	push   %eax
  800ea6:	e8 e1 f8 ff ff       	call   80078c <fd_alloc>
  800eab:	89 c3                	mov    %eax,%ebx
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 55                	js     800f09 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	56                   	push   %esi
  800eb8:	68 00 50 80 00       	push   $0x805000
  800ebd:	e8 e0 f2 ff ff       	call   8001a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800eca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ecd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed2:	e8 65 fe ff ff       	call   800d3c <fsipc>
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 12                	jns    800ef2 <open+0x6e>
		fd_close(fd, 0);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	6a 00                	push   $0x0
  800ee5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee8:	e8 ce f9 ff ff       	call   8008bb <fd_close>
		return r;
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	eb 17                	jmp    800f09 <open+0x85>
	}

	return fd2num(fd);
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef8:	e8 67 f8 ff ff       	call   800764 <fd2num>
  800efd:	89 c3                	mov    %eax,%ebx
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	eb 05                	jmp    800f09 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f04:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    
	...

00800f14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	ff 75 08             	pushl  0x8(%ebp)
  800f22:	e8 4d f8 ff ff       	call   800774 <fd2data>
  800f27:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800f29:	83 c4 08             	add    $0x8,%esp
  800f2c:	68 1b 1f 80 00       	push   $0x801f1b
  800f31:	56                   	push   %esi
  800f32:	e8 6b f2 ff ff       	call   8001a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f37:	8b 43 04             	mov    0x4(%ebx),%eax
  800f3a:	2b 03                	sub    (%ebx),%eax
  800f3c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800f42:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800f49:	00 00 00 
	stat->st_dev = &devpipe;
  800f4c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800f53:	30 80 00 
	return 0;
}
  800f56:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    

00800f62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	53                   	push   %ebx
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f6c:	53                   	push   %ebx
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 fa f6 ff ff       	call   80066e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f74:	89 1c 24             	mov    %ebx,(%esp)
  800f77:	e8 f8 f7 ff ff       	call   800774 <fd2data>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	50                   	push   %eax
  800f80:	6a 00                	push   $0x0
  800f82:	e8 e7 f6 ff ff       	call   80066e <sys_page_unmap>
}
  800f87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 1c             	sub    $0x1c,%esp
  800f95:	89 c7                	mov    %eax,%edi
  800f97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f9a:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	57                   	push   %edi
  800fa6:	e8 d1 0b 00 00       	call   801b7c <pageref>
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	83 c4 04             	add    $0x4,%esp
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	e8 c4 0b 00 00       	call   801b7c <pageref>
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	39 c6                	cmp    %eax,%esi
  800fbd:	0f 94 c0             	sete   %al
  800fc0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800fc3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fc9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800fcc:	39 cb                	cmp    %ecx,%ebx
  800fce:	75 08                	jne    800fd8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800fd8:	83 f8 01             	cmp    $0x1,%eax
  800fdb:	75 bd                	jne    800f9a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fdd:	8b 42 58             	mov    0x58(%edx),%eax
  800fe0:	6a 01                	push   $0x1
  800fe2:	50                   	push   %eax
  800fe3:	53                   	push   %ebx
  800fe4:	68 22 1f 80 00       	push   $0x801f22
  800fe9:	e8 02 05 00 00       	call   8014f0 <cprintf>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	eb a7                	jmp    800f9a <_pipeisclosed+0xe>

00800ff3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 28             	sub    $0x28,%esp
  800ffc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fff:	56                   	push   %esi
  801000:	e8 6f f7 ff ff       	call   800774 <fd2data>
  801005:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80100e:	75 4a                	jne    80105a <devpipe_write+0x67>
  801010:	bf 00 00 00 00       	mov    $0x0,%edi
  801015:	eb 56                	jmp    80106d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801017:	89 da                	mov    %ebx,%edx
  801019:	89 f0                	mov    %esi,%eax
  80101b:	e8 6c ff ff ff       	call   800f8c <_pipeisclosed>
  801020:	85 c0                	test   %eax,%eax
  801022:	75 4d                	jne    801071 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801024:	e8 d4 f5 ff ff       	call   8005fd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801029:	8b 43 04             	mov    0x4(%ebx),%eax
  80102c:	8b 13                	mov    (%ebx),%edx
  80102e:	83 c2 20             	add    $0x20,%edx
  801031:	39 d0                	cmp    %edx,%eax
  801033:	73 e2                	jae    801017 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801035:	89 c2                	mov    %eax,%edx
  801037:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80103d:	79 05                	jns    801044 <devpipe_write+0x51>
  80103f:	4a                   	dec    %edx
  801040:	83 ca e0             	or     $0xffffffe0,%edx
  801043:	42                   	inc    %edx
  801044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801047:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80104a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80104e:	40                   	inc    %eax
  80104f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801052:	47                   	inc    %edi
  801053:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801056:	77 07                	ja     80105f <devpipe_write+0x6c>
  801058:	eb 13                	jmp    80106d <devpipe_write+0x7a>
  80105a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80105f:	8b 43 04             	mov    0x4(%ebx),%eax
  801062:	8b 13                	mov    (%ebx),%edx
  801064:	83 c2 20             	add    $0x20,%edx
  801067:	39 d0                	cmp    %edx,%eax
  801069:	73 ac                	jae    801017 <devpipe_write+0x24>
  80106b:	eb c8                	jmp    801035 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80106d:	89 f8                	mov    %edi,%eax
  80106f:	eb 05                	jmp    801076 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801071:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 18             	sub    $0x18,%esp
  801087:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80108a:	57                   	push   %edi
  80108b:	e8 e4 f6 ff ff       	call   800774 <fd2data>
  801090:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801099:	75 44                	jne    8010df <devpipe_read+0x61>
  80109b:	be 00 00 00 00       	mov    $0x0,%esi
  8010a0:	eb 4f                	jmp    8010f1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8010a2:	89 f0                	mov    %esi,%eax
  8010a4:	eb 54                	jmp    8010fa <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010a6:	89 da                	mov    %ebx,%edx
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	e8 dd fe ff ff       	call   800f8c <_pipeisclosed>
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	75 42                	jne    8010f5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010b3:	e8 45 f5 ff ff       	call   8005fd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010b8:	8b 03                	mov    (%ebx),%eax
  8010ba:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010bd:	74 e7                	je     8010a6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010bf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8010c4:	79 05                	jns    8010cb <devpipe_read+0x4d>
  8010c6:	48                   	dec    %eax
  8010c7:	83 c8 e0             	or     $0xffffffe0,%eax
  8010ca:	40                   	inc    %eax
  8010cb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8010cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8010d5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010d7:	46                   	inc    %esi
  8010d8:	39 75 10             	cmp    %esi,0x10(%ebp)
  8010db:	77 07                	ja     8010e4 <devpipe_read+0x66>
  8010dd:	eb 12                	jmp    8010f1 <devpipe_read+0x73>
  8010df:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8010e4:	8b 03                	mov    (%ebx),%eax
  8010e6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010e9:	75 d4                	jne    8010bf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010eb:	85 f6                	test   %esi,%esi
  8010ed:	75 b3                	jne    8010a2 <devpipe_read+0x24>
  8010ef:	eb b5                	jmp    8010a6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010f1:	89 f0                	mov    %esi,%eax
  8010f3:	eb 05                	jmp    8010fa <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 28             	sub    $0x28,%esp
  80110b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80110e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801111:	50                   	push   %eax
  801112:	e8 75 f6 ff ff       	call   80078c <fd_alloc>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	0f 88 24 01 00 00    	js     801248 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	68 07 04 00 00       	push   $0x407
  80112c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112f:	6a 00                	push   $0x0
  801131:	e8 ee f4 ff ff       	call   800624 <sys_page_alloc>
  801136:	89 c3                	mov    %eax,%ebx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	0f 88 05 01 00 00    	js     801248 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801143:	83 ec 0c             	sub    $0xc,%esp
  801146:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801149:	50                   	push   %eax
  80114a:	e8 3d f6 ff ff       	call   80078c <fd_alloc>
  80114f:	89 c3                	mov    %eax,%ebx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	0f 88 dc 00 00 00    	js     801238 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	68 07 04 00 00       	push   $0x407
  801164:	ff 75 e0             	pushl  -0x20(%ebp)
  801167:	6a 00                	push   $0x0
  801169:	e8 b6 f4 ff ff       	call   800624 <sys_page_alloc>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	0f 88 bd 00 00 00    	js     801238 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801181:	e8 ee f5 ff ff       	call   800774 <fd2data>
  801186:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801188:	83 c4 0c             	add    $0xc,%esp
  80118b:	68 07 04 00 00       	push   $0x407
  801190:	50                   	push   %eax
  801191:	6a 00                	push   $0x0
  801193:	e8 8c f4 ff ff       	call   800624 <sys_page_alloc>
  801198:	89 c3                	mov    %eax,%ebx
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	0f 88 83 00 00 00    	js     801228 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ab:	e8 c4 f5 ff ff       	call   800774 <fd2data>
  8011b0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011b7:	50                   	push   %eax
  8011b8:	6a 00                	push   $0x0
  8011ba:	56                   	push   %esi
  8011bb:	6a 00                	push   $0x0
  8011bd:	e8 86 f4 ff ff       	call   800648 <sys_page_map>
  8011c2:	89 c3                	mov    %eax,%ebx
  8011c4:	83 c4 20             	add    $0x20,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 4f                	js     80121a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011cb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011e9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fb:	e8 64 f5 ff ff       	call   800764 <fd2num>
  801200:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801202:	83 c4 04             	add    $0x4,%esp
  801205:	ff 75 e0             	pushl  -0x20(%ebp)
  801208:	e8 57 f5 ff ff       	call   800764 <fd2num>
  80120d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	bb 00 00 00 00       	mov    $0x0,%ebx
  801218:	eb 2e                	jmp    801248 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	56                   	push   %esi
  80121e:	6a 00                	push   $0x0
  801220:	e8 49 f4 ff ff       	call   80066e <sys_page_unmap>
  801225:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	ff 75 e0             	pushl  -0x20(%ebp)
  80122e:	6a 00                	push   $0x0
  801230:	e8 39 f4 ff ff       	call   80066e <sys_page_unmap>
  801235:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123e:	6a 00                	push   $0x0
  801240:	e8 29 f4 ff ff       	call   80066e <sys_page_unmap>
  801245:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801248:	89 d8                	mov    %ebx,%eax
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 9b f5 ff ff       	call   8007ff <fd_lookup>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 18                	js     801283 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	ff 75 f4             	pushl  -0xc(%ebp)
  801271:	e8 fe f4 ff ff       	call   800774 <fd2data>
	return _pipeisclosed(fd, p);
  801276:	89 c2                	mov    %eax,%edx
  801278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127b:	e8 0c fd ff ff       	call   800f8c <_pipeisclosed>
  801280:	83 c4 10             	add    $0x10,%esp
}
  801283:	c9                   	leave  
  801284:	c3                   	ret    
  801285:	00 00                	add    %al,(%eax)
	...

00801288 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801298:	68 3a 1f 80 00       	push   $0x801f3a
  80129d:	ff 75 0c             	pushl  0xc(%ebp)
  8012a0:	e8 fd ee ff ff       	call   8001a2 <strcpy>
	return 0;
}
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012bc:	74 45                	je     801303 <devcons_write+0x57>
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012c8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8012d3:	83 fb 7f             	cmp    $0x7f,%ebx
  8012d6:	76 05                	jbe    8012dd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8012d8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	03 45 0c             	add    0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	57                   	push   %edi
  8012e6:	e8 78 f0 ff ff       	call   800363 <memmove>
		sys_cputs(buf, m);
  8012eb:	83 c4 08             	add    $0x8,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	57                   	push   %edi
  8012f0:	e8 78 f2 ff ff       	call   80056d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012f5:	01 de                	add    %ebx,%esi
  8012f7:	89 f0                	mov    %esi,%eax
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012ff:	72 cd                	jb     8012ce <devcons_write+0x22>
  801301:	eb 05                	jmp    801308 <devcons_write+0x5c>
  801303:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801308:	89 f0                	mov    %esi,%eax
  80130a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801318:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80131c:	75 07                	jne    801325 <devcons_read+0x13>
  80131e:	eb 25                	jmp    801345 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801320:	e8 d8 f2 ff ff       	call   8005fd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801325:	e8 69 f2 ff ff       	call   800593 <sys_cgetc>
  80132a:	85 c0                	test   %eax,%eax
  80132c:	74 f2                	je     801320 <devcons_read+0xe>
  80132e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801330:	85 c0                	test   %eax,%eax
  801332:	78 1d                	js     801351 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801334:	83 f8 04             	cmp    $0x4,%eax
  801337:	74 13                	je     80134c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801339:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133c:	88 10                	mov    %dl,(%eax)
	return 1;
  80133e:	b8 01 00 00 00       	mov    $0x1,%eax
  801343:	eb 0c                	jmp    801351 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
  80134a:	eb 05                	jmp    801351 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80135f:	6a 01                	push   $0x1
  801361:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	e8 03 f2 ff ff       	call   80056d <sys_cputs>
  80136a:	83 c4 10             	add    $0x10,%esp
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <getchar>:

int
getchar(void)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801375:	6a 01                	push   $0x1
  801377:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	6a 00                	push   $0x0
  80137d:	e8 fe f6 ff ff       	call   800a80 <read>
	if (r < 0)
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 0f                	js     801398 <getchar+0x29>
		return r;
	if (r < 1)
  801389:	85 c0                	test   %eax,%eax
  80138b:	7e 06                	jle    801393 <getchar+0x24>
		return -E_EOF;
	return c;
  80138d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801391:	eb 05                	jmp    801398 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801393:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	e8 53 f4 ff ff       	call   8007ff <fd_lookup>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 11                	js     8013c4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013bc:	39 10                	cmp    %edx,(%eax)
  8013be:	0f 94 c0             	sete   %al
  8013c1:	0f b6 c0             	movzbl %al,%eax
}
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <opencons>:

int
opencons(void)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	e8 b7 f3 ff ff       	call   80078c <fd_alloc>
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 3a                	js     801416 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	68 07 04 00 00       	push   $0x407
  8013e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 36 f2 ff ff       	call   800624 <sys_page_alloc>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 21                	js     801416 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013f5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	50                   	push   %eax
  80140e:	e8 51 f3 ff ff       	call   800764 <fd2num>
  801413:	83 c4 10             	add    $0x10,%esp
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80141d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801420:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801426:	e8 ae f1 ff ff       	call   8005d9 <sys_getenvid>
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	ff 75 0c             	pushl  0xc(%ebp)
  801431:	ff 75 08             	pushl  0x8(%ebp)
  801434:	53                   	push   %ebx
  801435:	50                   	push   %eax
  801436:	68 48 1f 80 00       	push   $0x801f48
  80143b:	e8 b0 00 00 00       	call   8014f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801440:	83 c4 18             	add    $0x18,%esp
  801443:	56                   	push   %esi
  801444:	ff 75 10             	pushl  0x10(%ebp)
  801447:	e8 53 00 00 00       	call   80149f <vcprintf>
	cprintf("\n");
  80144c:	c7 04 24 33 1f 80 00 	movl   $0x801f33,(%esp)
  801453:	e8 98 00 00 00       	call   8014f0 <cprintf>
  801458:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80145b:	cc                   	int3   
  80145c:	eb fd                	jmp    80145b <_panic+0x43>
	...

00801460 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80146a:	8b 03                	mov    (%ebx),%eax
  80146c:	8b 55 08             	mov    0x8(%ebp),%edx
  80146f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801473:	40                   	inc    %eax
  801474:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801476:	3d ff 00 00 00       	cmp    $0xff,%eax
  80147b:	75 1a                	jne    801497 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	68 ff 00 00 00       	push   $0xff
  801485:	8d 43 08             	lea    0x8(%ebx),%eax
  801488:	50                   	push   %eax
  801489:	e8 df f0 ff ff       	call   80056d <sys_cputs>
		b->idx = 0;
  80148e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801494:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801497:	ff 43 04             	incl   0x4(%ebx)
}
  80149a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014af:	00 00 00 
	b.cnt = 0;
  8014b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014bc:	ff 75 0c             	pushl  0xc(%ebp)
  8014bf:	ff 75 08             	pushl  0x8(%ebp)
  8014c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	68 60 14 80 00       	push   $0x801460
  8014ce:	e8 82 01 00 00       	call   801655 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	e8 85 f0 ff ff       	call   80056d <sys_cputs>

	return b.cnt;
}
  8014e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014f9:	50                   	push   %eax
  8014fa:	ff 75 08             	pushl  0x8(%ebp)
  8014fd:	e8 9d ff ff ff       	call   80149f <vcprintf>
	va_end(ap);

	return cnt;
}
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	57                   	push   %edi
  801508:	56                   	push   %esi
  801509:	53                   	push   %ebx
  80150a:	83 ec 2c             	sub    $0x2c,%esp
  80150d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801510:	89 d6                	mov    %edx,%esi
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	8b 55 0c             	mov    0xc(%ebp),%edx
  801518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80151e:	8b 45 10             	mov    0x10(%ebp),%eax
  801521:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801524:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801527:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80152a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801531:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  801534:	72 0c                	jb     801542 <printnum+0x3e>
  801536:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801539:	76 07                	jbe    801542 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80153b:	4b                   	dec    %ebx
  80153c:	85 db                	test   %ebx,%ebx
  80153e:	7f 31                	jg     801571 <printnum+0x6d>
  801540:	eb 3f                	jmp    801581 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	57                   	push   %edi
  801546:	4b                   	dec    %ebx
  801547:	53                   	push   %ebx
  801548:	50                   	push   %eax
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154f:	ff 75 d0             	pushl  -0x30(%ebp)
  801552:	ff 75 dc             	pushl  -0x24(%ebp)
  801555:	ff 75 d8             	pushl  -0x28(%ebp)
  801558:	e8 63 06 00 00       	call   801bc0 <__udivdi3>
  80155d:	83 c4 18             	add    $0x18,%esp
  801560:	52                   	push   %edx
  801561:	50                   	push   %eax
  801562:	89 f2                	mov    %esi,%edx
  801564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801567:	e8 98 ff ff ff       	call   801504 <printnum>
  80156c:	83 c4 20             	add    $0x20,%esp
  80156f:	eb 10                	jmp    801581 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	56                   	push   %esi
  801575:	57                   	push   %edi
  801576:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801579:	4b                   	dec    %ebx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 db                	test   %ebx,%ebx
  80157f:	7f f0                	jg     801571 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	56                   	push   %esi
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	ff 75 d4             	pushl  -0x2c(%ebp)
  80158b:	ff 75 d0             	pushl  -0x30(%ebp)
  80158e:	ff 75 dc             	pushl  -0x24(%ebp)
  801591:	ff 75 d8             	pushl  -0x28(%ebp)
  801594:	e8 43 07 00 00       	call   801cdc <__umoddi3>
  801599:	83 c4 14             	add    $0x14,%esp
  80159c:	0f be 80 6b 1f 80 00 	movsbl 0x801f6b(%eax),%eax
  8015a3:	50                   	push   %eax
  8015a4:	ff 55 e4             	call   *-0x1c(%ebp)
  8015a7:	83 c4 10             	add    $0x10,%esp
}
  8015aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5f                   	pop    %edi
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015b5:	83 fa 01             	cmp    $0x1,%edx
  8015b8:	7e 0e                	jle    8015c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8015ba:	8b 10                	mov    (%eax),%edx
  8015bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015bf:	89 08                	mov    %ecx,(%eax)
  8015c1:	8b 02                	mov    (%edx),%eax
  8015c3:	8b 52 04             	mov    0x4(%edx),%edx
  8015c6:	eb 22                	jmp    8015ea <getuint+0x38>
	else if (lflag)
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	74 10                	je     8015dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015cc:	8b 10                	mov    (%eax),%edx
  8015ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015d1:	89 08                	mov    %ecx,(%eax)
  8015d3:	8b 02                	mov    (%edx),%eax
  8015d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015da:	eb 0e                	jmp    8015ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015dc:	8b 10                	mov    (%eax),%edx
  8015de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015e1:	89 08                	mov    %ecx,(%eax)
  8015e3:	8b 02                	mov    (%edx),%eax
  8015e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015ef:	83 fa 01             	cmp    $0x1,%edx
  8015f2:	7e 0e                	jle    801602 <getint+0x16>
		return va_arg(*ap, long long);
  8015f4:	8b 10                	mov    (%eax),%edx
  8015f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015f9:	89 08                	mov    %ecx,(%eax)
  8015fb:	8b 02                	mov    (%edx),%eax
  8015fd:	8b 52 04             	mov    0x4(%edx),%edx
  801600:	eb 1a                	jmp    80161c <getint+0x30>
	else if (lflag)
  801602:	85 d2                	test   %edx,%edx
  801604:	74 0c                	je     801612 <getint+0x26>
		return va_arg(*ap, long);
  801606:	8b 10                	mov    (%eax),%edx
  801608:	8d 4a 04             	lea    0x4(%edx),%ecx
  80160b:	89 08                	mov    %ecx,(%eax)
  80160d:	8b 02                	mov    (%edx),%eax
  80160f:	99                   	cltd   
  801610:	eb 0a                	jmp    80161c <getint+0x30>
	else
		return va_arg(*ap, int);
  801612:	8b 10                	mov    (%eax),%edx
  801614:	8d 4a 04             	lea    0x4(%edx),%ecx
  801617:	89 08                	mov    %ecx,(%eax)
  801619:	8b 02                	mov    (%edx),%eax
  80161b:	99                   	cltd   
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801624:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801627:	8b 10                	mov    (%eax),%edx
  801629:	3b 50 04             	cmp    0x4(%eax),%edx
  80162c:	73 08                	jae    801636 <sprintputch+0x18>
		*b->buf++ = ch;
  80162e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801631:	88 0a                	mov    %cl,(%edx)
  801633:	42                   	inc    %edx
  801634:	89 10                	mov    %edx,(%eax)
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80163e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801641:	50                   	push   %eax
  801642:	ff 75 10             	pushl  0x10(%ebp)
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 05 00 00 00       	call   801655 <vprintfmt>
	va_end(ap);
  801650:	83 c4 10             	add    $0x10,%esp
}
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	57                   	push   %edi
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	83 ec 2c             	sub    $0x2c,%esp
  80165e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801661:	8b 75 10             	mov    0x10(%ebp),%esi
  801664:	eb 13                	jmp    801679 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801666:	85 c0                	test   %eax,%eax
  801668:	0f 84 6d 03 00 00    	je     8019db <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	57                   	push   %edi
  801672:	50                   	push   %eax
  801673:	ff 55 08             	call   *0x8(%ebp)
  801676:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801679:	0f b6 06             	movzbl (%esi),%eax
  80167c:	46                   	inc    %esi
  80167d:	83 f8 25             	cmp    $0x25,%eax
  801680:	75 e4                	jne    801666 <vprintfmt+0x11>
  801682:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  801686:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80168d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801694:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80169b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016a0:	eb 28                	jmp    8016ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8016a4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8016a8:	eb 20                	jmp    8016ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016aa:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016ac:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8016b0:	eb 18                	jmp    8016ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8016b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8016bb:	eb 0d                	jmp    8016ca <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8016bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016c3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ca:	8a 06                	mov    (%esi),%al
  8016cc:	0f b6 d0             	movzbl %al,%edx
  8016cf:	8d 5e 01             	lea    0x1(%esi),%ebx
  8016d2:	83 e8 23             	sub    $0x23,%eax
  8016d5:	3c 55                	cmp    $0x55,%al
  8016d7:	0f 87 e0 02 00 00    	ja     8019bd <vprintfmt+0x368>
  8016dd:	0f b6 c0             	movzbl %al,%eax
  8016e0:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016e7:	83 ea 30             	sub    $0x30,%edx
  8016ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8016ed:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8016f0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8016f3:	83 fa 09             	cmp    $0x9,%edx
  8016f6:	77 44                	ja     80173c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f8:	89 de                	mov    %ebx,%esi
  8016fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8016fe:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801701:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801705:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801708:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80170b:	83 fb 09             	cmp    $0x9,%ebx
  80170e:	76 ed                	jbe    8016fd <vprintfmt+0xa8>
  801710:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801713:	eb 29                	jmp    80173e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801715:	8b 45 14             	mov    0x14(%ebp),%eax
  801718:	8d 50 04             	lea    0x4(%eax),%edx
  80171b:	89 55 14             	mov    %edx,0x14(%ebp)
  80171e:	8b 00                	mov    (%eax),%eax
  801720:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801723:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801725:	eb 17                	jmp    80173e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  801727:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80172b:	78 85                	js     8016b2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172d:	89 de                	mov    %ebx,%esi
  80172f:	eb 99                	jmp    8016ca <vprintfmt+0x75>
  801731:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801733:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80173a:	eb 8e                	jmp    8016ca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80173e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801742:	79 86                	jns    8016ca <vprintfmt+0x75>
  801744:	e9 74 ff ff ff       	jmp    8016bd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801749:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174a:	89 de                	mov    %ebx,%esi
  80174c:	e9 79 ff ff ff       	jmp    8016ca <vprintfmt+0x75>
  801751:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801754:	8b 45 14             	mov    0x14(%ebp),%eax
  801757:	8d 50 04             	lea    0x4(%eax),%edx
  80175a:	89 55 14             	mov    %edx,0x14(%ebp)
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	57                   	push   %edi
  801761:	ff 30                	pushl  (%eax)
  801763:	ff 55 08             	call   *0x8(%ebp)
			break;
  801766:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801769:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80176c:	e9 08 ff ff ff       	jmp    801679 <vprintfmt+0x24>
  801771:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  801774:	8b 45 14             	mov    0x14(%ebp),%eax
  801777:	8d 50 04             	lea    0x4(%eax),%edx
  80177a:	89 55 14             	mov    %edx,0x14(%ebp)
  80177d:	8b 00                	mov    (%eax),%eax
  80177f:	85 c0                	test   %eax,%eax
  801781:	79 02                	jns    801785 <vprintfmt+0x130>
  801783:	f7 d8                	neg    %eax
  801785:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801787:	83 f8 0f             	cmp    $0xf,%eax
  80178a:	7f 0b                	jg     801797 <vprintfmt+0x142>
  80178c:	8b 04 85 00 22 80 00 	mov    0x802200(,%eax,4),%eax
  801793:	85 c0                	test   %eax,%eax
  801795:	75 1a                	jne    8017b1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  801797:	52                   	push   %edx
  801798:	68 83 1f 80 00       	push   $0x801f83
  80179d:	57                   	push   %edi
  80179e:	ff 75 08             	pushl  0x8(%ebp)
  8017a1:	e8 92 fe ff ff       	call   801638 <printfmt>
  8017a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017ac:	e9 c8 fe ff ff       	jmp    801679 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8017b1:	50                   	push   %eax
  8017b2:	68 01 1f 80 00       	push   $0x801f01
  8017b7:	57                   	push   %edi
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 78 fe ff ff       	call   801638 <printfmt>
  8017c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8017c6:	e9 ae fe ff ff       	jmp    801679 <vprintfmt+0x24>
  8017cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017ce:	89 de                	mov    %ebx,%esi
  8017d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8017d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d9:	8d 50 04             	lea    0x4(%eax),%edx
  8017dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8017df:	8b 00                	mov    (%eax),%eax
  8017e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	75 07                	jne    8017ef <vprintfmt+0x19a>
				p = "(null)";
  8017e8:	c7 45 d0 7c 1f 80 00 	movl   $0x801f7c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8017ef:	85 db                	test   %ebx,%ebx
  8017f1:	7e 42                	jle    801835 <vprintfmt+0x1e0>
  8017f3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8017f7:	74 3c                	je     801835 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	51                   	push   %ecx
  8017fd:	ff 75 d0             	pushl  -0x30(%ebp)
  801800:	e8 6b e9 ff ff       	call   800170 <strnlen>
  801805:	29 c3                	sub    %eax,%ebx
  801807:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 db                	test   %ebx,%ebx
  80180f:	7e 24                	jle    801835 <vprintfmt+0x1e0>
					putch(padc, putdat);
  801811:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  801815:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801818:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	57                   	push   %edi
  80181f:	53                   	push   %ebx
  801820:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801823:	4e                   	dec    %esi
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	85 f6                	test   %esi,%esi
  801829:	7f f0                	jg     80181b <vprintfmt+0x1c6>
  80182b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80182e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801835:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801838:	0f be 02             	movsbl (%edx),%eax
  80183b:	85 c0                	test   %eax,%eax
  80183d:	75 47                	jne    801886 <vprintfmt+0x231>
  80183f:	eb 37                	jmp    801878 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801841:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801845:	74 16                	je     80185d <vprintfmt+0x208>
  801847:	8d 50 e0             	lea    -0x20(%eax),%edx
  80184a:	83 fa 5e             	cmp    $0x5e,%edx
  80184d:	76 0e                	jbe    80185d <vprintfmt+0x208>
					putch('?', putdat);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	57                   	push   %edi
  801853:	6a 3f                	push   $0x3f
  801855:	ff 55 08             	call   *0x8(%ebp)
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	eb 0b                	jmp    801868 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	57                   	push   %edi
  801861:	50                   	push   %eax
  801862:	ff 55 08             	call   *0x8(%ebp)
  801865:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801868:	ff 4d e4             	decl   -0x1c(%ebp)
  80186b:	0f be 03             	movsbl (%ebx),%eax
  80186e:	85 c0                	test   %eax,%eax
  801870:	74 03                	je     801875 <vprintfmt+0x220>
  801872:	43                   	inc    %ebx
  801873:	eb 1b                	jmp    801890 <vprintfmt+0x23b>
  801875:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801878:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80187c:	7f 1e                	jg     80189c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801881:	e9 f3 fd ff ff       	jmp    801679 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801886:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801889:	43                   	inc    %ebx
  80188a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80188d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801890:	85 f6                	test   %esi,%esi
  801892:	78 ad                	js     801841 <vprintfmt+0x1ec>
  801894:	4e                   	dec    %esi
  801895:	79 aa                	jns    801841 <vprintfmt+0x1ec>
  801897:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80189a:	eb dc                	jmp    801878 <vprintfmt+0x223>
  80189c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	57                   	push   %edi
  8018a3:	6a 20                	push   $0x20
  8018a5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018a8:	4b                   	dec    %ebx
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	85 db                	test   %ebx,%ebx
  8018ae:	7f ef                	jg     80189f <vprintfmt+0x24a>
  8018b0:	e9 c4 fd ff ff       	jmp    801679 <vprintfmt+0x24>
  8018b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018b8:	89 ca                	mov    %ecx,%edx
  8018ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8018bd:	e8 2a fd ff ff       	call   8015ec <getint>
  8018c2:	89 c3                	mov    %eax,%ebx
  8018c4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8018c6:	85 d2                	test   %edx,%edx
  8018c8:	78 0a                	js     8018d4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018cf:	e9 b0 00 00 00       	jmp    801984 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	57                   	push   %edi
  8018d8:	6a 2d                	push   $0x2d
  8018da:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8018dd:	f7 db                	neg    %ebx
  8018df:	83 d6 00             	adc    $0x0,%esi
  8018e2:	f7 de                	neg    %esi
  8018e4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018ec:	e9 93 00 00 00       	jmp    801984 <vprintfmt+0x32f>
  8018f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018f4:	89 ca                	mov    %ecx,%edx
  8018f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f9:	e8 b4 fc ff ff       	call   8015b2 <getuint>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	89 d6                	mov    %edx,%esi
			base = 10;
  801902:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801907:	eb 7b                	jmp    801984 <vprintfmt+0x32f>
  801909:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80190c:	89 ca                	mov    %ecx,%edx
  80190e:	8d 45 14             	lea    0x14(%ebp),%eax
  801911:	e8 d6 fc ff ff       	call   8015ec <getint>
  801916:	89 c3                	mov    %eax,%ebx
  801918:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80191a:	85 d2                	test   %edx,%edx
  80191c:	78 07                	js     801925 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80191e:	b8 08 00 00 00       	mov    $0x8,%eax
  801923:	eb 5f                	jmp    801984 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	57                   	push   %edi
  801929:	6a 2d                	push   $0x2d
  80192b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80192e:	f7 db                	neg    %ebx
  801930:	83 d6 00             	adc    $0x0,%esi
  801933:	f7 de                	neg    %esi
  801935:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801938:	b8 08 00 00 00       	mov    $0x8,%eax
  80193d:	eb 45                	jmp    801984 <vprintfmt+0x32f>
  80193f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	57                   	push   %edi
  801946:	6a 30                	push   $0x30
  801948:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80194b:	83 c4 08             	add    $0x8,%esp
  80194e:	57                   	push   %edi
  80194f:	6a 78                	push   $0x78
  801951:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801954:	8b 45 14             	mov    0x14(%ebp),%eax
  801957:	8d 50 04             	lea    0x4(%eax),%edx
  80195a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80195d:	8b 18                	mov    (%eax),%ebx
  80195f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801964:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801967:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80196c:	eb 16                	jmp    801984 <vprintfmt+0x32f>
  80196e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801971:	89 ca                	mov    %ecx,%edx
  801973:	8d 45 14             	lea    0x14(%ebp),%eax
  801976:	e8 37 fc ff ff       	call   8015b2 <getuint>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	89 d6                	mov    %edx,%esi
			base = 16;
  80197f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80198b:	52                   	push   %edx
  80198c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80198f:	50                   	push   %eax
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	89 fa                	mov    %edi,%edx
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	e8 68 fb ff ff       	call   801504 <printnum>
			break;
  80199c:	83 c4 20             	add    $0x20,%esp
  80199f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019a2:	e9 d2 fc ff ff       	jmp    801679 <vprintfmt+0x24>
  8019a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	57                   	push   %edi
  8019ae:	52                   	push   %edx
  8019af:	ff 55 08             	call   *0x8(%ebp)
			break;
  8019b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019b8:	e9 bc fc ff ff       	jmp    801679 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	57                   	push   %edi
  8019c1:	6a 25                	push   $0x25
  8019c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	eb 02                	jmp    8019cd <vprintfmt+0x378>
  8019cb:	89 c6                	mov    %eax,%esi
  8019cd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8019d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8019d4:	75 f5                	jne    8019cb <vprintfmt+0x376>
  8019d6:	e9 9e fc ff ff       	jmp    801679 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8019db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5f                   	pop    %edi
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 18             	sub    $0x18,%esp
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	74 26                	je     801a2a <vsnprintf+0x47>
  801a04:	85 d2                	test   %edx,%edx
  801a06:	7e 29                	jle    801a31 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a08:	ff 75 14             	pushl  0x14(%ebp)
  801a0b:	ff 75 10             	pushl  0x10(%ebp)
  801a0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	68 1e 16 80 00       	push   $0x80161e
  801a17:	e8 39 fc ff ff       	call   801655 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb 0c                	jmp    801a36 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a2f:	eb 05                	jmp    801a36 <vsnprintf+0x53>
  801a31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a3e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a41:	50                   	push   %eax
  801a42:	ff 75 10             	pushl  0x10(%ebp)
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	ff 75 08             	pushl  0x8(%ebp)
  801a4b:	e8 93 ff ff ff       	call   8019e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    
	...

00801a54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a62:	85 c0                	test   %eax,%eax
  801a64:	74 0e                	je     801a74 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	50                   	push   %eax
  801a6a:	e8 b0 ec ff ff       	call   80071f <sys_ipc_recv>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	eb 10                	jmp    801a84 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	68 00 00 c0 ee       	push   $0xeec00000
  801a7c:	e8 9e ec ff ff       	call   80071f <sys_ipc_recv>
  801a81:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a84:	85 c0                	test   %eax,%eax
  801a86:	75 26                	jne    801aae <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a88:	85 f6                	test   %esi,%esi
  801a8a:	74 0a                	je     801a96 <ipc_recv+0x42>
  801a8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a91:	8b 40 74             	mov    0x74(%eax),%eax
  801a94:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a96:	85 db                	test   %ebx,%ebx
  801a98:	74 0a                	je     801aa4 <ipc_recv+0x50>
  801a9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9f:	8b 40 78             	mov    0x78(%eax),%eax
  801aa2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801aa4:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa9:	8b 40 70             	mov    0x70(%eax),%eax
  801aac:	eb 14                	jmp    801ac2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801aae:	85 f6                	test   %esi,%esi
  801ab0:	74 06                	je     801ab8 <ipc_recv+0x64>
  801ab2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ab8:	85 db                	test   %ebx,%ebx
  801aba:	74 06                	je     801ac2 <ipc_recv+0x6e>
  801abc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ac2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac5:	5b                   	pop    %ebx
  801ac6:	5e                   	pop    %esi
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	57                   	push   %edi
  801acd:	56                   	push   %esi
  801ace:	53                   	push   %ebx
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ad8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801adb:	85 db                	test   %ebx,%ebx
  801add:	75 25                	jne    801b04 <ipc_send+0x3b>
  801adf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ae4:	eb 1e                	jmp    801b04 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ae6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae9:	75 07                	jne    801af2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aeb:	e8 0d eb ff ff       	call   8005fd <sys_yield>
  801af0:	eb 12                	jmp    801b04 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801af2:	50                   	push   %eax
  801af3:	68 60 22 80 00       	push   $0x802260
  801af8:	6a 43                	push   $0x43
  801afa:	68 73 22 80 00       	push   $0x802273
  801aff:	e8 14 f9 ff ff       	call   801418 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	57                   	push   %edi
  801b07:	ff 75 08             	pushl  0x8(%ebp)
  801b0a:	e8 eb eb ff ff       	call   8006fa <sys_ipc_try_send>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	75 d0                	jne    801ae6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b25:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b2b:	74 22                	je     801b4f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b32:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	c1 e2 07             	shl    $0x7,%edx
  801b3e:	29 ca                	sub    %ecx,%edx
  801b40:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b46:	8b 52 50             	mov    0x50(%edx),%edx
  801b49:	39 da                	cmp    %ebx,%edx
  801b4b:	75 1d                	jne    801b6a <ipc_find_env+0x4c>
  801b4d:	eb 05                	jmp    801b54 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b5b:	c1 e0 07             	shl    $0x7,%eax
  801b5e:	29 d0                	sub    %edx,%eax
  801b60:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b65:	8b 40 40             	mov    0x40(%eax),%eax
  801b68:	eb 0c                	jmp    801b76 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6a:	40                   	inc    %eax
  801b6b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b70:	75 c0                	jne    801b32 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b72:	66 b8 00 00          	mov    $0x0,%ax
}
  801b76:	5b                   	pop    %ebx
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    
  801b79:	00 00                	add    %al,(%eax)
	...

00801b7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	c1 ea 16             	shr    $0x16,%edx
  801b87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b8e:	f6 c2 01             	test   $0x1,%dl
  801b91:	74 1e                	je     801bb1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b93:	c1 e8 0c             	shr    $0xc,%eax
  801b96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b9d:	a8 01                	test   $0x1,%al
  801b9f:	74 17                	je     801bb8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba1:	c1 e8 0c             	shr    $0xc,%eax
  801ba4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bab:	ef 
  801bac:	0f b7 c0             	movzwl %ax,%eax
  801baf:	eb 0c                	jmp    801bbd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb6:	eb 05                	jmp    801bbd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    
	...

00801bc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	83 ec 10             	sub    $0x10,%esp
  801bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bce:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bd4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bd7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	75 2e                	jne    801c0c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bde:	39 f1                	cmp    %esi,%ecx
  801be0:	77 5a                	ja     801c3c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801be2:	85 c9                	test   %ecx,%ecx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f1                	div    %ecx
  801bef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bf9:	89 f8                	mov    %edi,%eax
  801bfb:	f7 f1                	div    %ecx
  801bfd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    
  801c0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c0c:	39 f0                	cmp    %esi,%eax
  801c0e:	77 1c                	ja     801c2c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c10:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c13:	83 f7 1f             	xor    $0x1f,%edi
  801c16:	75 3c                	jne    801c54 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c18:	39 f0                	cmp    %esi,%eax
  801c1a:	0f 82 90 00 00 00    	jb     801cb0 <__udivdi3+0xf0>
  801c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c23:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c26:	0f 86 84 00 00 00    	jbe    801cb0 <__udivdi3+0xf0>
  801c2c:	31 f6                	xor    %esi,%esi
  801c2e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c30:	89 f8                	mov    %edi,%eax
  801c32:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    
  801c3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	89 f8                	mov    %edi,%eax
  801c40:	f7 f1                	div    %ecx
  801c42:	89 c7                	mov    %eax,%edi
  801c44:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c46:	89 f8                	mov    %edi,%eax
  801c48:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	5e                   	pop    %esi
  801c4e:	5f                   	pop    %edi
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    
  801c51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c54:	89 f9                	mov    %edi,%ecx
  801c56:	d3 e0                	shl    %cl,%eax
  801c58:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c5b:	b8 20 00 00 00       	mov    $0x20,%eax
  801c60:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c65:	88 c1                	mov    %al,%cl
  801c67:	d3 ea                	shr    %cl,%edx
  801c69:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c6c:	09 ca                	or     %ecx,%edx
  801c6e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c74:	89 f9                	mov    %edi,%ecx
  801c76:	d3 e2                	shl    %cl,%edx
  801c78:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c7b:	89 f2                	mov    %esi,%edx
  801c7d:	88 c1                	mov    %al,%cl
  801c7f:	d3 ea                	shr    %cl,%edx
  801c81:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c84:	89 f2                	mov    %esi,%edx
  801c86:	89 f9                	mov    %edi,%ecx
  801c88:	d3 e2                	shl    %cl,%edx
  801c8a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c8d:	88 c1                	mov    %al,%cl
  801c8f:	d3 ee                	shr    %cl,%esi
  801c91:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c93:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c96:	89 f0                	mov    %esi,%eax
  801c98:	89 ca                	mov    %ecx,%edx
  801c9a:	f7 75 ec             	divl   -0x14(%ebp)
  801c9d:	89 d1                	mov    %edx,%ecx
  801c9f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ca1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ca4:	39 d1                	cmp    %edx,%ecx
  801ca6:	72 28                	jb     801cd0 <__udivdi3+0x110>
  801ca8:	74 1a                	je     801cc4 <__udivdi3+0x104>
  801caa:	89 f7                	mov    %esi,%edi
  801cac:	31 f6                	xor    %esi,%esi
  801cae:	eb 80                	jmp    801c30 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cb0:	31 f6                	xor    %esi,%esi
  801cb2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cb7:	89 f8                	mov    %edi,%eax
  801cb9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    
  801cc2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cc7:	89 f9                	mov    %edi,%ecx
  801cc9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ccb:	39 c2                	cmp    %eax,%edx
  801ccd:	73 db                	jae    801caa <__udivdi3+0xea>
  801ccf:	90                   	nop
		{
		  q0--;
  801cd0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cd3:	31 f6                	xor    %esi,%esi
  801cd5:	e9 56 ff ff ff       	jmp    801c30 <__udivdi3+0x70>
	...

00801cdc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	57                   	push   %edi
  801ce0:	56                   	push   %esi
  801ce1:	83 ec 20             	sub    $0x20,%esp
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801cf0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cf9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cfb:	85 ff                	test   %edi,%edi
  801cfd:	75 15                	jne    801d14 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cff:	39 f1                	cmp    %esi,%ecx
  801d01:	0f 86 99 00 00 00    	jbe    801da0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d07:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d0d:	83 c4 20             	add    $0x20,%esp
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d14:	39 f7                	cmp    %esi,%edi
  801d16:	0f 87 a4 00 00 00    	ja     801dc0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d1c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d1f:	83 f0 1f             	xor    $0x1f,%eax
  801d22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d25:	0f 84 a1 00 00 00    	je     801dcc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d2b:	89 f8                	mov    %edi,%eax
  801d2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d30:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d32:	bf 20 00 00 00       	mov    $0x20,%edi
  801d37:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d3d:	89 f9                	mov    %edi,%ecx
  801d3f:	d3 ea                	shr    %cl,%edx
  801d41:	09 c2                	or     %eax,%edx
  801d43:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d51:	89 f2                	mov    %esi,%edx
  801d53:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d58:	d3 e0                	shl    %cl,%eax
  801d5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d60:	89 f9                	mov    %edi,%ecx
  801d62:	d3 e8                	shr    %cl,%eax
  801d64:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d66:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d68:	89 f2                	mov    %esi,%edx
  801d6a:	f7 75 f0             	divl   -0x10(%ebp)
  801d6d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d6f:	f7 65 f4             	mull   -0xc(%ebp)
  801d72:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d75:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d77:	39 d6                	cmp    %edx,%esi
  801d79:	72 71                	jb     801dec <__umoddi3+0x110>
  801d7b:	74 7f                	je     801dfc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d80:	29 c8                	sub    %ecx,%eax
  801d82:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d84:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 f2                	mov    %esi,%edx
  801d8b:	89 f9                	mov    %edi,%ecx
  801d8d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d8f:	09 d0                	or     %edx,%eax
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d96:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d98:	83 c4 20             	add    $0x20,%esp
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    
  801d9f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801da0:	85 c9                	test   %ecx,%ecx
  801da2:	75 0b                	jne    801daf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801da4:	b8 01 00 00 00       	mov    $0x1,%eax
  801da9:	31 d2                	xor    %edx,%edx
  801dab:	f7 f1                	div    %ecx
  801dad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801daf:	89 f0                	mov    %esi,%eax
  801db1:	31 d2                	xor    %edx,%edx
  801db3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db8:	f7 f1                	div    %ecx
  801dba:	e9 4a ff ff ff       	jmp    801d09 <__umoddi3+0x2d>
  801dbf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dc0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dc2:	83 c4 20             	add    $0x20,%esp
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    
  801dc9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dcc:	39 f7                	cmp    %esi,%edi
  801dce:	72 05                	jb     801dd5 <__umoddi3+0xf9>
  801dd0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801dd3:	77 0c                	ja     801de1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dd5:	89 f2                	mov    %esi,%edx
  801dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dda:	29 c8                	sub    %ecx,%eax
  801ddc:	19 fa                	sbb    %edi,%edx
  801dde:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801de4:	83 c4 20             	add    $0x20,%esp
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    
  801deb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801def:	89 c1                	mov    %eax,%ecx
  801df1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801df4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801df7:	eb 84                	jmp    801d7d <__umoddi3+0xa1>
  801df9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dfc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dff:	72 eb                	jb     801dec <__umoddi3+0x110>
  801e01:	89 f2                	mov    %esi,%edx
  801e03:	e9 75 ff ff ff       	jmp    801d7d <__umoddi3+0xa1>
