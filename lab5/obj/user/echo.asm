
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
  80004e:	68 40 1e 80 00       	push   $0x801e40
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
  800074:	68 43 1e 80 00       	push   $0x801e43
  800079:	6a 01                	push   $0x1
  80007b:	e8 04 0b 00 00       	call   800b84 <write>
  800080:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800083:	83 ec 0c             	sub    $0xc,%esp
  800086:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800089:	e8 c2 00 00 00       	call   800150 <strlen>
  80008e:	83 c4 0c             	add    $0xc,%esp
  800091:	50                   	push   %eax
  800092:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800095:	6a 01                	push   $0x1
  800097:	e8 e8 0a 00 00       	call   800b84 <write>
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
  8000af:	68 53 1f 80 00       	push   $0x801f53
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 c9 0a 00 00       	call   800b84 <write>
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
  80013a:	e8 57 08 00 00       	call   800996 <close_all>
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
  800552:	68 4f 1e 80 00       	push   $0x801e4f
  800557:	6a 42                	push   $0x42
  800559:	68 6c 1e 80 00       	push   $0x801e6c
  80055e:	e8 dd 0e 00 00       	call   801440 <_panic>

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

00800764 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  80076a:	6a 00                	push   $0x0
  80076c:	ff 75 14             	pushl  0x14(%ebp)
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	ba 00 00 00 00       	mov    $0x0,%edx
  80077d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800782:	e8 99 fd ff ff       	call   800520 <syscall>
  800787:	c9                   	leave  
  800788:	c3                   	ret    
  800789:	00 00                	add    %al,(%eax)
	...

0080078c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	05 00 00 00 30       	add    $0x30000000,%eax
  800797:	c1 e8 0c             	shr    $0xc,%eax
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80079f:	ff 75 08             	pushl  0x8(%ebp)
  8007a2:	e8 e5 ff ff ff       	call   80078c <fd2num>
  8007a7:	83 c4 04             	add    $0x4,%esp
  8007aa:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007af:	c1 e0 0c             	shl    $0xc,%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007bb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8007c0:	a8 01                	test   $0x1,%al
  8007c2:	74 34                	je     8007f8 <fd_alloc+0x44>
  8007c4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8007c9:	a8 01                	test   $0x1,%al
  8007cb:	74 32                	je     8007ff <fd_alloc+0x4b>
  8007cd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8007d2:	89 c1                	mov    %eax,%ecx
  8007d4:	89 c2                	mov    %eax,%edx
  8007d6:	c1 ea 16             	shr    $0x16,%edx
  8007d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007e0:	f6 c2 01             	test   $0x1,%dl
  8007e3:	74 1f                	je     800804 <fd_alloc+0x50>
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	c1 ea 0c             	shr    $0xc,%edx
  8007ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007f1:	f6 c2 01             	test   $0x1,%dl
  8007f4:	75 17                	jne    80080d <fd_alloc+0x59>
  8007f6:	eb 0c                	jmp    800804 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8007f8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8007fd:	eb 05                	jmp    800804 <fd_alloc+0x50>
  8007ff:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800804:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 17                	jmp    800824 <fd_alloc+0x70>
  80080d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800812:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800817:	75 b9                	jne    8007d2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800819:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80081f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800824:	5b                   	pop    %ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80082d:	83 f8 1f             	cmp    $0x1f,%eax
  800830:	77 36                	ja     800868 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800832:	05 00 00 0d 00       	add    $0xd0000,%eax
  800837:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80083a:	89 c2                	mov    %eax,%edx
  80083c:	c1 ea 16             	shr    $0x16,%edx
  80083f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800846:	f6 c2 01             	test   $0x1,%dl
  800849:	74 24                	je     80086f <fd_lookup+0x48>
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	c1 ea 0c             	shr    $0xc,%edx
  800850:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800857:	f6 c2 01             	test   $0x1,%dl
  80085a:	74 1a                	je     800876 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 02                	mov    %eax,(%edx)
	return 0;
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 13                	jmp    80087b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086d:	eb 0c                	jmp    80087b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80086f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800874:	eb 05                	jmp    80087b <fd_lookup+0x54>
  800876:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80088a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800890:	74 0d                	je     80089f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 14                	jmp    8008ad <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800899:	39 0a                	cmp    %ecx,(%edx)
  80089b:	75 10                	jne    8008ad <dev_lookup+0x30>
  80089d:	eb 05                	jmp    8008a4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80089f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8008a4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 31                	jmp    8008de <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008ad:	40                   	inc    %eax
  8008ae:	8b 14 85 f8 1e 80 00 	mov    0x801ef8(,%eax,4),%edx
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	75 e0                	jne    800899 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8008be:	8b 40 48             	mov    0x48(%eax),%eax
  8008c1:	83 ec 04             	sub    $0x4,%esp
  8008c4:	51                   	push   %ecx
  8008c5:	50                   	push   %eax
  8008c6:	68 7c 1e 80 00       	push   $0x801e7c
  8008cb:	e8 48 0c 00 00       	call   801518 <cprintf>
	*dev = 0;
  8008d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	83 ec 20             	sub    $0x20,%esp
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8a 45 0c             	mov    0xc(%ebp),%al
  8008f1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008f4:	56                   	push   %esi
  8008f5:	e8 92 fe ff ff       	call   80078c <fd2num>
  8008fa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008fd:	89 14 24             	mov    %edx,(%esp)
  800900:	50                   	push   %eax
  800901:	e8 21 ff ff ff       	call   800827 <fd_lookup>
  800906:	89 c3                	mov    %eax,%ebx
  800908:	83 c4 08             	add    $0x8,%esp
  80090b:	85 c0                	test   %eax,%eax
  80090d:	78 05                	js     800914 <fd_close+0x31>
	    || fd != fd2)
  80090f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800912:	74 0d                	je     800921 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800914:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800918:	75 48                	jne    800962 <fd_close+0x7f>
  80091a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80091f:	eb 41                	jmp    800962 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800921:	83 ec 08             	sub    $0x8,%esp
  800924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800927:	50                   	push   %eax
  800928:	ff 36                	pushl  (%esi)
  80092a:	e8 4e ff ff ff       	call   80087d <dev_lookup>
  80092f:	89 c3                	mov    %eax,%ebx
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	85 c0                	test   %eax,%eax
  800936:	78 1c                	js     800954 <fd_close+0x71>
		if (dev->dev_close)
  800938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093b:	8b 40 10             	mov    0x10(%eax),%eax
  80093e:	85 c0                	test   %eax,%eax
  800940:	74 0d                	je     80094f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	56                   	push   %esi
  800946:	ff d0                	call   *%eax
  800948:	89 c3                	mov    %eax,%ebx
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 05                	jmp    800954 <fd_close+0x71>
		else
			r = 0;
  80094f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	56                   	push   %esi
  800958:	6a 00                	push   $0x0
  80095a:	e8 0f fd ff ff       	call   80066e <sys_page_unmap>
	return r;
  80095f:	83 c4 10             	add    $0x10,%esp
}
  800962:	89 d8                	mov    %ebx,%eax
  800964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800971:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800974:	50                   	push   %eax
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 aa fe ff ff       	call   800827 <fd_lookup>
  80097d:	83 c4 08             	add    $0x8,%esp
  800980:	85 c0                	test   %eax,%eax
  800982:	78 10                	js     800994 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	6a 01                	push   $0x1
  800989:	ff 75 f4             	pushl  -0xc(%ebp)
  80098c:	e8 52 ff ff ff       	call   8008e3 <fd_close>
  800991:	83 c4 10             	add    $0x10,%esp
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <close_all>:

void
close_all(void)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80099d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009a2:	83 ec 0c             	sub    $0xc,%esp
  8009a5:	53                   	push   %ebx
  8009a6:	e8 c0 ff ff ff       	call   80096b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ab:	43                   	inc    %ebx
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	83 fb 20             	cmp    $0x20,%ebx
  8009b2:	75 ee                	jne    8009a2 <close_all+0xc>
		close(i);
}
  8009b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 2c             	sub    $0x2c,%esp
  8009c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009c8:	50                   	push   %eax
  8009c9:	ff 75 08             	pushl  0x8(%ebp)
  8009cc:	e8 56 fe ff ff       	call   800827 <fd_lookup>
  8009d1:	89 c3                	mov    %eax,%ebx
  8009d3:	83 c4 08             	add    $0x8,%esp
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	0f 88 c0 00 00 00    	js     800a9e <dup+0xe5>
		return r;
	close(newfdnum);
  8009de:	83 ec 0c             	sub    $0xc,%esp
  8009e1:	57                   	push   %edi
  8009e2:	e8 84 ff ff ff       	call   80096b <close>

	newfd = INDEX2FD(newfdnum);
  8009e7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8009ed:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8009f0:	83 c4 04             	add    $0x4,%esp
  8009f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009f6:	e8 a1 fd ff ff       	call   80079c <fd2data>
  8009fb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009fd:	89 34 24             	mov    %esi,(%esp)
  800a00:	e8 97 fd ff ff       	call   80079c <fd2data>
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	c1 e8 16             	shr    $0x16,%eax
  800a10:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a17:	a8 01                	test   $0x1,%al
  800a19:	74 37                	je     800a52 <dup+0x99>
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	c1 e8 0c             	shr    $0xc,%eax
  800a20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a27:	f6 c2 01             	test   $0x1,%dl
  800a2a:	74 26                	je     800a52 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a33:	83 ec 0c             	sub    $0xc,%esp
  800a36:	25 07 0e 00 00       	and    $0xe07,%eax
  800a3b:	50                   	push   %eax
  800a3c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a3f:	6a 00                	push   $0x0
  800a41:	53                   	push   %ebx
  800a42:	6a 00                	push   $0x0
  800a44:	e8 ff fb ff ff       	call   800648 <sys_page_map>
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	83 c4 20             	add    $0x20,%esp
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	78 2d                	js     800a7f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	c1 ea 0c             	shr    $0xc,%edx
  800a5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a61:	83 ec 0c             	sub    $0xc,%esp
  800a64:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a6a:	52                   	push   %edx
  800a6b:	56                   	push   %esi
  800a6c:	6a 00                	push   $0x0
  800a6e:	50                   	push   %eax
  800a6f:	6a 00                	push   $0x0
  800a71:	e8 d2 fb ff ff       	call   800648 <sys_page_map>
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	83 c4 20             	add    $0x20,%esp
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	79 1d                	jns    800a9c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a7f:	83 ec 08             	sub    $0x8,%esp
  800a82:	56                   	push   %esi
  800a83:	6a 00                	push   $0x0
  800a85:	e8 e4 fb ff ff       	call   80066e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a8a:	83 c4 08             	add    $0x8,%esp
  800a8d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a90:	6a 00                	push   $0x0
  800a92:	e8 d7 fb ff ff       	call   80066e <sys_page_unmap>
	return r;
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	eb 02                	jmp    800a9e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800a9c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a9e:	89 d8                	mov    %ebx,%eax
  800aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	53                   	push   %ebx
  800aac:	83 ec 14             	sub    $0x14,%esp
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab5:	50                   	push   %eax
  800ab6:	53                   	push   %ebx
  800ab7:	e8 6b fd ff ff       	call   800827 <fd_lookup>
  800abc:	83 c4 08             	add    $0x8,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 67                	js     800b2a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acd:	ff 30                	pushl  (%eax)
  800acf:	e8 a9 fd ff ff       	call   80087d <dev_lookup>
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	78 4f                	js     800b2a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ade:	8b 50 08             	mov    0x8(%eax),%edx
  800ae1:	83 e2 03             	and    $0x3,%edx
  800ae4:	83 fa 01             	cmp    $0x1,%edx
  800ae7:	75 21                	jne    800b0a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ae9:	a1 04 40 80 00       	mov    0x804004,%eax
  800aee:	8b 40 48             	mov    0x48(%eax),%eax
  800af1:	83 ec 04             	sub    $0x4,%esp
  800af4:	53                   	push   %ebx
  800af5:	50                   	push   %eax
  800af6:	68 bd 1e 80 00       	push   $0x801ebd
  800afb:	e8 18 0a 00 00       	call   801518 <cprintf>
		return -E_INVAL;
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b08:	eb 20                	jmp    800b2a <read+0x82>
	}
	if (!dev->dev_read)
  800b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0d:	8b 52 08             	mov    0x8(%edx),%edx
  800b10:	85 d2                	test   %edx,%edx
  800b12:	74 11                	je     800b25 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b14:	83 ec 04             	sub    $0x4,%esp
  800b17:	ff 75 10             	pushl  0x10(%ebp)
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	50                   	push   %eax
  800b1e:	ff d2                	call   *%edx
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	eb 05                	jmp    800b2a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b25:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b3e:	85 f6                	test   %esi,%esi
  800b40:	74 31                	je     800b73 <readn+0x44>
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b4c:	83 ec 04             	sub    $0x4,%esp
  800b4f:	89 f2                	mov    %esi,%edx
  800b51:	29 c2                	sub    %eax,%edx
  800b53:	52                   	push   %edx
  800b54:	03 45 0c             	add    0xc(%ebp),%eax
  800b57:	50                   	push   %eax
  800b58:	57                   	push   %edi
  800b59:	e8 4a ff ff ff       	call   800aa8 <read>
		if (m < 0)
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	78 17                	js     800b7c <readn+0x4d>
			return m;
		if (m == 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	74 11                	je     800b7a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b69:	01 c3                	add    %eax,%ebx
  800b6b:	89 d8                	mov    %ebx,%eax
  800b6d:	39 f3                	cmp    %esi,%ebx
  800b6f:	72 db                	jb     800b4c <readn+0x1d>
  800b71:	eb 09                	jmp    800b7c <readn+0x4d>
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
  800b78:	eb 02                	jmp    800b7c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800b7a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	83 ec 14             	sub    $0x14,%esp
  800b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b91:	50                   	push   %eax
  800b92:	53                   	push   %ebx
  800b93:	e8 8f fc ff ff       	call   800827 <fd_lookup>
  800b98:	83 c4 08             	add    $0x8,%esp
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	78 62                	js     800c01 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba5:	50                   	push   %eax
  800ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba9:	ff 30                	pushl  (%eax)
  800bab:	e8 cd fc ff ff       	call   80087d <dev_lookup>
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	78 4a                	js     800c01 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bbe:	75 21                	jne    800be1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc5:	8b 40 48             	mov    0x48(%eax),%eax
  800bc8:	83 ec 04             	sub    $0x4,%esp
  800bcb:	53                   	push   %ebx
  800bcc:	50                   	push   %eax
  800bcd:	68 d9 1e 80 00       	push   $0x801ed9
  800bd2:	e8 41 09 00 00       	call   801518 <cprintf>
		return -E_INVAL;
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bdf:	eb 20                	jmp    800c01 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be4:	8b 52 0c             	mov    0xc(%edx),%edx
  800be7:	85 d2                	test   %edx,%edx
  800be9:	74 11                	je     800bfc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800beb:	83 ec 04             	sub    $0x4,%esp
  800bee:	ff 75 10             	pushl  0x10(%ebp)
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	50                   	push   %eax
  800bf5:	ff d2                	call   *%edx
  800bf7:	83 c4 10             	add    $0x10,%esp
  800bfa:	eb 05                	jmp    800c01 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800bfc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c0c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c0f:	50                   	push   %eax
  800c10:	ff 75 08             	pushl  0x8(%ebp)
  800c13:	e8 0f fc ff ff       	call   800827 <fd_lookup>
  800c18:	83 c4 08             	add    $0x8,%esp
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	78 0e                	js     800c2d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c25:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	53                   	push   %ebx
  800c33:	83 ec 14             	sub    $0x14,%esp
  800c36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c3c:	50                   	push   %eax
  800c3d:	53                   	push   %ebx
  800c3e:	e8 e4 fb ff ff       	call   800827 <fd_lookup>
  800c43:	83 c4 08             	add    $0x8,%esp
  800c46:	85 c0                	test   %eax,%eax
  800c48:	78 5f                	js     800ca9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4a:	83 ec 08             	sub    $0x8,%esp
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	50                   	push   %eax
  800c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c54:	ff 30                	pushl  (%eax)
  800c56:	e8 22 fc ff ff       	call   80087d <dev_lookup>
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	78 47                	js     800ca9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c65:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c69:	75 21                	jne    800c8c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c6b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c70:	8b 40 48             	mov    0x48(%eax),%eax
  800c73:	83 ec 04             	sub    $0x4,%esp
  800c76:	53                   	push   %ebx
  800c77:	50                   	push   %eax
  800c78:	68 9c 1e 80 00       	push   $0x801e9c
  800c7d:	e8 96 08 00 00       	call   801518 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c8a:	eb 1d                	jmp    800ca9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800c8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c8f:	8b 52 18             	mov    0x18(%edx),%edx
  800c92:	85 d2                	test   %edx,%edx
  800c94:	74 0e                	je     800ca4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c96:	83 ec 08             	sub    $0x8,%esp
  800c99:	ff 75 0c             	pushl  0xc(%ebp)
  800c9c:	50                   	push   %eax
  800c9d:	ff d2                	call   *%edx
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	eb 05                	jmp    800ca9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800ca4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800ca9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 14             	sub    $0x14,%esp
  800cb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cbb:	50                   	push   %eax
  800cbc:	ff 75 08             	pushl  0x8(%ebp)
  800cbf:	e8 63 fb ff ff       	call   800827 <fd_lookup>
  800cc4:	83 c4 08             	add    $0x8,%esp
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	78 52                	js     800d1d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccb:	83 ec 08             	sub    $0x8,%esp
  800cce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cd1:	50                   	push   %eax
  800cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd5:	ff 30                	pushl  (%eax)
  800cd7:	e8 a1 fb ff ff       	call   80087d <dev_lookup>
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 3a                	js     800d1d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cea:	74 2c                	je     800d18 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cf6:	00 00 00 
	stat->st_isdir = 0;
  800cf9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d00:	00 00 00 
	stat->st_dev = dev;
  800d03:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d09:	83 ec 08             	sub    $0x8,%esp
  800d0c:	53                   	push   %ebx
  800d0d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d10:	ff 50 14             	call   *0x14(%eax)
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	eb 05                	jmp    800d1d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d18:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d27:	83 ec 08             	sub    $0x8,%esp
  800d2a:	6a 00                	push   $0x0
  800d2c:	ff 75 08             	pushl  0x8(%ebp)
  800d2f:	e8 78 01 00 00       	call   800eac <open>
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	78 1b                	js     800d58 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d3d:	83 ec 08             	sub    $0x8,%esp
  800d40:	ff 75 0c             	pushl  0xc(%ebp)
  800d43:	50                   	push   %eax
  800d44:	e8 65 ff ff ff       	call   800cae <fstat>
  800d49:	89 c6                	mov    %eax,%esi
	close(fd);
  800d4b:	89 1c 24             	mov    %ebx,(%esp)
  800d4e:	e8 18 fc ff ff       	call   80096b <close>
	return r;
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	89 f3                	mov    %esi,%ebx
}
  800d58:	89 d8                	mov    %ebx,%eax
  800d5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    
  800d61:	00 00                	add    %al,(%eax)
	...

00800d64 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	89 c3                	mov    %eax,%ebx
  800d6b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800d6d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d74:	75 12                	jne    800d88 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	6a 01                	push   $0x1
  800d7b:	e8 c6 0d 00 00       	call   801b46 <ipc_find_env>
  800d80:	a3 00 40 80 00       	mov    %eax,0x804000
  800d85:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d88:	6a 07                	push   $0x7
  800d8a:	68 00 50 80 00       	push   $0x805000
  800d8f:	53                   	push   %ebx
  800d90:	ff 35 00 40 80 00    	pushl  0x804000
  800d96:	e8 56 0d 00 00       	call   801af1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800d9b:	83 c4 0c             	add    $0xc,%esp
  800d9e:	6a 00                	push   $0x0
  800da0:	56                   	push   %esi
  800da1:	6a 00                	push   $0x0
  800da3:	e8 d4 0c 00 00       	call   801a7c <ipc_recv>
}
  800da8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	53                   	push   %ebx
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dce:	e8 91 ff ff ff       	call   800d64 <fsipc>
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 2c                	js     800e03 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd7:	83 ec 08             	sub    $0x8,%esp
  800dda:	68 00 50 80 00       	push   $0x805000
  800ddf:	53                   	push   %ebx
  800de0:	e8 bd f3 ff ff       	call   8001a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800de5:	a1 80 50 80 00       	mov    0x805080,%eax
  800dea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800df0:	a1 84 50 80 00       	mov    0x805084,%eax
  800df5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 40 0c             	mov    0xc(%eax),%eax
  800e14:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e19:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e23:	e8 3c ff ff ff       	call   800d64 <fsipc>
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	8b 40 0c             	mov    0xc(%eax),%eax
  800e38:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e3d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 03 00 00 00       	mov    $0x3,%eax
  800e4d:	e8 12 ff ff ff       	call   800d64 <fsipc>
  800e52:	89 c3                	mov    %eax,%ebx
  800e54:	85 c0                	test   %eax,%eax
  800e56:	78 4b                	js     800ea3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e58:	39 c6                	cmp    %eax,%esi
  800e5a:	73 16                	jae    800e72 <devfile_read+0x48>
  800e5c:	68 08 1f 80 00       	push   $0x801f08
  800e61:	68 0f 1f 80 00       	push   $0x801f0f
  800e66:	6a 7d                	push   $0x7d
  800e68:	68 24 1f 80 00       	push   $0x801f24
  800e6d:	e8 ce 05 00 00       	call   801440 <_panic>
	assert(r <= PGSIZE);
  800e72:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e77:	7e 16                	jle    800e8f <devfile_read+0x65>
  800e79:	68 2f 1f 80 00       	push   $0x801f2f
  800e7e:	68 0f 1f 80 00       	push   $0x801f0f
  800e83:	6a 7e                	push   $0x7e
  800e85:	68 24 1f 80 00       	push   $0x801f24
  800e8a:	e8 b1 05 00 00       	call   801440 <_panic>
	memmove(buf, &fsipcbuf, r);
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	50                   	push   %eax
  800e93:	68 00 50 80 00       	push   $0x805000
  800e98:	ff 75 0c             	pushl  0xc(%ebp)
  800e9b:	e8 c3 f4 ff ff       	call   800363 <memmove>
	return r;
  800ea0:	83 c4 10             	add    $0x10,%esp
}
  800ea3:	89 d8                	mov    %ebx,%eax
  800ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 1c             	sub    $0x1c,%esp
  800eb4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800eb7:	56                   	push   %esi
  800eb8:	e8 93 f2 ff ff       	call   800150 <strlen>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ec5:	7f 65                	jg     800f2c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecd:	50                   	push   %eax
  800ece:	e8 e1 f8 ff ff       	call   8007b4 <fd_alloc>
  800ed3:	89 c3                	mov    %eax,%ebx
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 55                	js     800f31 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	56                   	push   %esi
  800ee0:	68 00 50 80 00       	push   $0x805000
  800ee5:	e8 b8 f2 ff ff       	call   8001a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  800efa:	e8 65 fe ff ff       	call   800d64 <fsipc>
  800eff:	89 c3                	mov    %eax,%ebx
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	79 12                	jns    800f1a <open+0x6e>
		fd_close(fd, 0);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	6a 00                	push   $0x0
  800f0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f10:	e8 ce f9 ff ff       	call   8008e3 <fd_close>
		return r;
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	eb 17                	jmp    800f31 <open+0x85>
	}

	return fd2num(fd);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f20:	e8 67 f8 ff ff       	call   80078c <fd2num>
  800f25:	89 c3                	mov    %eax,%ebx
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	eb 05                	jmp    800f31 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f2c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    
	...

00800f3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	ff 75 08             	pushl  0x8(%ebp)
  800f4a:	e8 4d f8 ff ff       	call   80079c <fd2data>
  800f4f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	68 3b 1f 80 00       	push   $0x801f3b
  800f59:	56                   	push   %esi
  800f5a:	e8 43 f2 ff ff       	call   8001a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f5f:	8b 43 04             	mov    0x4(%ebx),%eax
  800f62:	2b 03                	sub    (%ebx),%eax
  800f64:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800f6a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800f71:	00 00 00 
	stat->st_dev = &devpipe;
  800f74:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800f7b:	30 80 00 
	return 0;
}
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	e8 d2 f6 ff ff       	call   80066e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f9c:	89 1c 24             	mov    %ebx,(%esp)
  800f9f:	e8 f8 f7 ff ff       	call   80079c <fd2data>
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	50                   	push   %eax
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 bf f6 ff ff       	call   80066e <sys_page_unmap>
}
  800faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 1c             	sub    $0x1c,%esp
  800fbd:	89 c7                	mov    %eax,%edi
  800fbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800fc2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	57                   	push   %edi
  800fce:	e8 d1 0b 00 00       	call   801ba4 <pageref>
  800fd3:	89 c6                	mov    %eax,%esi
  800fd5:	83 c4 04             	add    $0x4,%esp
  800fd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdb:	e8 c4 0b 00 00       	call   801ba4 <pageref>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	39 c6                	cmp    %eax,%esi
  800fe5:	0f 94 c0             	sete   %al
  800fe8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800feb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ff4:	39 cb                	cmp    %ecx,%ebx
  800ff6:	75 08                	jne    801000 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801000:	83 f8 01             	cmp    $0x1,%eax
  801003:	75 bd                	jne    800fc2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801005:	8b 42 58             	mov    0x58(%edx),%eax
  801008:	6a 01                	push   $0x1
  80100a:	50                   	push   %eax
  80100b:	53                   	push   %ebx
  80100c:	68 42 1f 80 00       	push   $0x801f42
  801011:	e8 02 05 00 00       	call   801518 <cprintf>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	eb a7                	jmp    800fc2 <_pipeisclosed+0xe>

0080101b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 28             	sub    $0x28,%esp
  801024:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801027:	56                   	push   %esi
  801028:	e8 6f f7 ff ff       	call   80079c <fd2data>
  80102d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801036:	75 4a                	jne    801082 <devpipe_write+0x67>
  801038:	bf 00 00 00 00       	mov    $0x0,%edi
  80103d:	eb 56                	jmp    801095 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80103f:	89 da                	mov    %ebx,%edx
  801041:	89 f0                	mov    %esi,%eax
  801043:	e8 6c ff ff ff       	call   800fb4 <_pipeisclosed>
  801048:	85 c0                	test   %eax,%eax
  80104a:	75 4d                	jne    801099 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80104c:	e8 ac f5 ff ff       	call   8005fd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801051:	8b 43 04             	mov    0x4(%ebx),%eax
  801054:	8b 13                	mov    (%ebx),%edx
  801056:	83 c2 20             	add    $0x20,%edx
  801059:	39 d0                	cmp    %edx,%eax
  80105b:	73 e2                	jae    80103f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80105d:	89 c2                	mov    %eax,%edx
  80105f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801065:	79 05                	jns    80106c <devpipe_write+0x51>
  801067:	4a                   	dec    %edx
  801068:	83 ca e0             	or     $0xffffffe0,%edx
  80106b:	42                   	inc    %edx
  80106c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801072:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801076:	40                   	inc    %eax
  801077:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80107a:	47                   	inc    %edi
  80107b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80107e:	77 07                	ja     801087 <devpipe_write+0x6c>
  801080:	eb 13                	jmp    801095 <devpipe_write+0x7a>
  801082:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801087:	8b 43 04             	mov    0x4(%ebx),%eax
  80108a:	8b 13                	mov    (%ebx),%edx
  80108c:	83 c2 20             	add    $0x20,%edx
  80108f:	39 d0                	cmp    %edx,%eax
  801091:	73 ac                	jae    80103f <devpipe_write+0x24>
  801093:	eb c8                	jmp    80105d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801095:	89 f8                	mov    %edi,%eax
  801097:	eb 05                	jmp    80109e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 18             	sub    $0x18,%esp
  8010af:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010b2:	57                   	push   %edi
  8010b3:	e8 e4 f6 ff ff       	call   80079c <fd2data>
  8010b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c1:	75 44                	jne    801107 <devpipe_read+0x61>
  8010c3:	be 00 00 00 00       	mov    $0x0,%esi
  8010c8:	eb 4f                	jmp    801119 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8010ca:	89 f0                	mov    %esi,%eax
  8010cc:	eb 54                	jmp    801122 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010ce:	89 da                	mov    %ebx,%edx
  8010d0:	89 f8                	mov    %edi,%eax
  8010d2:	e8 dd fe ff ff       	call   800fb4 <_pipeisclosed>
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	75 42                	jne    80111d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010db:	e8 1d f5 ff ff       	call   8005fd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010e0:	8b 03                	mov    (%ebx),%eax
  8010e2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010e5:	74 e7                	je     8010ce <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010e7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8010ec:	79 05                	jns    8010f3 <devpipe_read+0x4d>
  8010ee:	48                   	dec    %eax
  8010ef:	83 c8 e0             	or     $0xffffffe0,%eax
  8010f2:	40                   	inc    %eax
  8010f3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8010f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fa:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8010fd:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ff:	46                   	inc    %esi
  801100:	39 75 10             	cmp    %esi,0x10(%ebp)
  801103:	77 07                	ja     80110c <devpipe_read+0x66>
  801105:	eb 12                	jmp    801119 <devpipe_read+0x73>
  801107:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80110c:	8b 03                	mov    (%ebx),%eax
  80110e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801111:	75 d4                	jne    8010e7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801113:	85 f6                	test   %esi,%esi
  801115:	75 b3                	jne    8010ca <devpipe_read+0x24>
  801117:	eb b5                	jmp    8010ce <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801119:	89 f0                	mov    %esi,%eax
  80111b:	eb 05                	jmp    801122 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	83 ec 28             	sub    $0x28,%esp
  801133:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801136:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	e8 75 f6 ff ff       	call   8007b4 <fd_alloc>
  80113f:	89 c3                	mov    %eax,%ebx
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	0f 88 24 01 00 00    	js     801270 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	68 07 04 00 00       	push   $0x407
  801154:	ff 75 e4             	pushl  -0x1c(%ebp)
  801157:	6a 00                	push   $0x0
  801159:	e8 c6 f4 ff ff       	call   800624 <sys_page_alloc>
  80115e:	89 c3                	mov    %eax,%ebx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	0f 88 05 01 00 00    	js     801270 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801171:	50                   	push   %eax
  801172:	e8 3d f6 ff ff       	call   8007b4 <fd_alloc>
  801177:	89 c3                	mov    %eax,%ebx
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	0f 88 dc 00 00 00    	js     801260 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	68 07 04 00 00       	push   $0x407
  80118c:	ff 75 e0             	pushl  -0x20(%ebp)
  80118f:	6a 00                	push   $0x0
  801191:	e8 8e f4 ff ff       	call   800624 <sys_page_alloc>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	0f 88 bd 00 00 00    	js     801260 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a9:	e8 ee f5 ff ff       	call   80079c <fd2data>
  8011ae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b0:	83 c4 0c             	add    $0xc,%esp
  8011b3:	68 07 04 00 00       	push   $0x407
  8011b8:	50                   	push   %eax
  8011b9:	6a 00                	push   $0x0
  8011bb:	e8 64 f4 ff ff       	call   800624 <sys_page_alloc>
  8011c0:	89 c3                	mov    %eax,%ebx
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	0f 88 83 00 00 00    	js     801250 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d3:	e8 c4 f5 ff ff       	call   80079c <fd2data>
  8011d8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011df:	50                   	push   %eax
  8011e0:	6a 00                	push   $0x0
  8011e2:	56                   	push   %esi
  8011e3:	6a 00                	push   $0x0
  8011e5:	e8 5e f4 ff ff       	call   800648 <sys_page_map>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 20             	add    $0x20,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 4f                	js     801242 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801201:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801208:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80120e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801211:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801213:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801216:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	ff 75 e4             	pushl  -0x1c(%ebp)
  801223:	e8 64 f5 ff ff       	call   80078c <fd2num>
  801228:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80122a:	83 c4 04             	add    $0x4,%esp
  80122d:	ff 75 e0             	pushl  -0x20(%ebp)
  801230:	e8 57 f5 ff ff       	call   80078c <fd2num>
  801235:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801240:	eb 2e                	jmp    801270 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	56                   	push   %esi
  801246:	6a 00                	push   $0x0
  801248:	e8 21 f4 ff ff       	call   80066e <sys_page_unmap>
  80124d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	ff 75 e0             	pushl  -0x20(%ebp)
  801256:	6a 00                	push   $0x0
  801258:	e8 11 f4 ff ff       	call   80066e <sys_page_unmap>
  80125d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	ff 75 e4             	pushl  -0x1c(%ebp)
  801266:	6a 00                	push   $0x0
  801268:	e8 01 f4 ff ff       	call   80066e <sys_page_unmap>
  80126d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801270:	89 d8                	mov    %ebx,%eax
  801272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801280:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	ff 75 08             	pushl  0x8(%ebp)
  801287:	e8 9b f5 ff ff       	call   800827 <fd_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 18                	js     8012ab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	ff 75 f4             	pushl  -0xc(%ebp)
  801299:	e8 fe f4 ff ff       	call   80079c <fd2data>
	return _pipeisclosed(fd, p);
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a3:	e8 0c fd ff ff       	call   800fb4 <_pipeisclosed>
  8012a8:	83 c4 10             	add    $0x10,%esp
}
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    
  8012ad:	00 00                	add    %al,(%eax)
	...

008012b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012c0:	68 5a 1f 80 00       	push   $0x801f5a
  8012c5:	ff 75 0c             	pushl  0xc(%ebp)
  8012c8:	e8 d5 ee ff ff       	call   8001a2 <strcpy>
	return 0;
}
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012e4:	74 45                	je     80132b <devcons_write+0x57>
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012f0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8012fb:	83 fb 7f             	cmp    $0x7f,%ebx
  8012fe:	76 05                	jbe    801305 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801300:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801305:	83 ec 04             	sub    $0x4,%esp
  801308:	53                   	push   %ebx
  801309:	03 45 0c             	add    0xc(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	57                   	push   %edi
  80130e:	e8 50 f0 ff ff       	call   800363 <memmove>
		sys_cputs(buf, m);
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	53                   	push   %ebx
  801317:	57                   	push   %edi
  801318:	e8 50 f2 ff ff       	call   80056d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80131d:	01 de                	add    %ebx,%esi
  80131f:	89 f0                	mov    %esi,%eax
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	3b 75 10             	cmp    0x10(%ebp),%esi
  801327:	72 cd                	jb     8012f6 <devcons_write+0x22>
  801329:	eb 05                	jmp    801330 <devcons_write+0x5c>
  80132b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801330:	89 f0                	mov    %esi,%eax
  801332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801340:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801344:	75 07                	jne    80134d <devcons_read+0x13>
  801346:	eb 25                	jmp    80136d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801348:	e8 b0 f2 ff ff       	call   8005fd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80134d:	e8 41 f2 ff ff       	call   800593 <sys_cgetc>
  801352:	85 c0                	test   %eax,%eax
  801354:	74 f2                	je     801348 <devcons_read+0xe>
  801356:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 1d                	js     801379 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80135c:	83 f8 04             	cmp    $0x4,%eax
  80135f:	74 13                	je     801374 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	88 10                	mov    %dl,(%eax)
	return 1;
  801366:	b8 01 00 00 00       	mov    $0x1,%eax
  80136b:	eb 0c                	jmp    801379 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 05                	jmp    801379 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801374:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801387:	6a 01                	push   $0x1
  801389:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	e8 db f1 ff ff       	call   80056d <sys_cputs>
  801392:	83 c4 10             	add    $0x10,%esp
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <getchar>:

int
getchar(void)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80139d:	6a 01                	push   $0x1
  80139f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 fe f6 ff ff       	call   800aa8 <read>
	if (r < 0)
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 0f                	js     8013c0 <getchar+0x29>
		return r;
	if (r < 1)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	7e 06                	jle    8013bb <getchar+0x24>
		return -E_EOF;
	return c;
  8013b5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013b9:	eb 05                	jmp    8013c0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013bb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 08             	pushl  0x8(%ebp)
  8013cf:	e8 53 f4 ff ff       	call   800827 <fd_lookup>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 11                	js     8013ec <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013e4:	39 10                	cmp    %edx,(%eax)
  8013e6:	0f 94 c0             	sete   %al
  8013e9:	0f b6 c0             	movzbl %al,%eax
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <opencons>:

int
opencons(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	e8 b7 f3 ff ff       	call   8007b4 <fd_alloc>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 3a                	js     80143e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801404:	83 ec 04             	sub    $0x4,%esp
  801407:	68 07 04 00 00       	push   $0x407
  80140c:	ff 75 f4             	pushl  -0xc(%ebp)
  80140f:	6a 00                	push   $0x0
  801411:	e8 0e f2 ff ff       	call   800624 <sys_page_alloc>
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 21                	js     80143e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80141d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801423:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801426:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	50                   	push   %eax
  801436:	e8 51 f3 ff ff       	call   80078c <fd2num>
  80143b:	83 c4 10             	add    $0x10,%esp
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801445:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801448:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80144e:	e8 86 f1 ff ff       	call   8005d9 <sys_getenvid>
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	ff 75 0c             	pushl  0xc(%ebp)
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	53                   	push   %ebx
  80145d:	50                   	push   %eax
  80145e:	68 68 1f 80 00       	push   $0x801f68
  801463:	e8 b0 00 00 00       	call   801518 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801468:	83 c4 18             	add    $0x18,%esp
  80146b:	56                   	push   %esi
  80146c:	ff 75 10             	pushl  0x10(%ebp)
  80146f:	e8 53 00 00 00       	call   8014c7 <vcprintf>
	cprintf("\n");
  801474:	c7 04 24 53 1f 80 00 	movl   $0x801f53,(%esp)
  80147b:	e8 98 00 00 00       	call   801518 <cprintf>
  801480:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801483:	cc                   	int3   
  801484:	eb fd                	jmp    801483 <_panic+0x43>
	...

00801488 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801492:	8b 03                	mov    (%ebx),%eax
  801494:	8b 55 08             	mov    0x8(%ebp),%edx
  801497:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80149b:	40                   	inc    %eax
  80149c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80149e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014a3:	75 1a                	jne    8014bf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	68 ff 00 00 00       	push   $0xff
  8014ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8014b0:	50                   	push   %eax
  8014b1:	e8 b7 f0 ff ff       	call   80056d <sys_cputs>
		b->idx = 0;
  8014b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014bf:	ff 43 04             	incl   0x4(%ebx)
}
  8014c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014d7:	00 00 00 
	b.cnt = 0;
  8014da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	68 88 14 80 00       	push   $0x801488
  8014f6:	e8 82 01 00 00       	call   80167d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801504:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	e8 5d f0 ff ff       	call   80056d <sys_cputs>

	return b.cnt;
}
  801510:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80151e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801521:	50                   	push   %eax
  801522:	ff 75 08             	pushl  0x8(%ebp)
  801525:	e8 9d ff ff ff       	call   8014c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 2c             	sub    $0x2c,%esp
  801535:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801538:	89 d6                	mov    %edx,%esi
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801543:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801546:	8b 45 10             	mov    0x10(%ebp),%eax
  801549:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80154c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80154f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801552:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801559:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80155c:	72 0c                	jb     80156a <printnum+0x3e>
  80155e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801561:	76 07                	jbe    80156a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801563:	4b                   	dec    %ebx
  801564:	85 db                	test   %ebx,%ebx
  801566:	7f 31                	jg     801599 <printnum+0x6d>
  801568:	eb 3f                	jmp    8015a9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	57                   	push   %edi
  80156e:	4b                   	dec    %ebx
  80156f:	53                   	push   %ebx
  801570:	50                   	push   %eax
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	ff 75 d4             	pushl  -0x2c(%ebp)
  801577:	ff 75 d0             	pushl  -0x30(%ebp)
  80157a:	ff 75 dc             	pushl  -0x24(%ebp)
  80157d:	ff 75 d8             	pushl  -0x28(%ebp)
  801580:	e8 63 06 00 00       	call   801be8 <__udivdi3>
  801585:	83 c4 18             	add    $0x18,%esp
  801588:	52                   	push   %edx
  801589:	50                   	push   %eax
  80158a:	89 f2                	mov    %esi,%edx
  80158c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158f:	e8 98 ff ff ff       	call   80152c <printnum>
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	eb 10                	jmp    8015a9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	56                   	push   %esi
  80159d:	57                   	push   %edi
  80159e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015a1:	4b                   	dec    %ebx
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 db                	test   %ebx,%ebx
  8015a7:	7f f0                	jg     801599 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	56                   	push   %esi
  8015ad:	83 ec 04             	sub    $0x4,%esp
  8015b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8015b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8015b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8015bc:	e8 43 07 00 00       	call   801d04 <__umoddi3>
  8015c1:	83 c4 14             	add    $0x14,%esp
  8015c4:	0f be 80 8b 1f 80 00 	movsbl 0x801f8b(%eax),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 55 e4             	call   *-0x1c(%ebp)
  8015cf:	83 c4 10             	add    $0x10,%esp
}
  8015d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015dd:	83 fa 01             	cmp    $0x1,%edx
  8015e0:	7e 0e                	jle    8015f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8015e2:	8b 10                	mov    (%eax),%edx
  8015e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015e7:	89 08                	mov    %ecx,(%eax)
  8015e9:	8b 02                	mov    (%edx),%eax
  8015eb:	8b 52 04             	mov    0x4(%edx),%edx
  8015ee:	eb 22                	jmp    801612 <getuint+0x38>
	else if (lflag)
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	74 10                	je     801604 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015f4:	8b 10                	mov    (%eax),%edx
  8015f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015f9:	89 08                	mov    %ecx,(%eax)
  8015fb:	8b 02                	mov    (%edx),%eax
  8015fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801602:	eb 0e                	jmp    801612 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801604:	8b 10                	mov    (%eax),%edx
  801606:	8d 4a 04             	lea    0x4(%edx),%ecx
  801609:	89 08                	mov    %ecx,(%eax)
  80160b:	8b 02                	mov    (%edx),%eax
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801617:	83 fa 01             	cmp    $0x1,%edx
  80161a:	7e 0e                	jle    80162a <getint+0x16>
		return va_arg(*ap, long long);
  80161c:	8b 10                	mov    (%eax),%edx
  80161e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801621:	89 08                	mov    %ecx,(%eax)
  801623:	8b 02                	mov    (%edx),%eax
  801625:	8b 52 04             	mov    0x4(%edx),%edx
  801628:	eb 1a                	jmp    801644 <getint+0x30>
	else if (lflag)
  80162a:	85 d2                	test   %edx,%edx
  80162c:	74 0c                	je     80163a <getint+0x26>
		return va_arg(*ap, long);
  80162e:	8b 10                	mov    (%eax),%edx
  801630:	8d 4a 04             	lea    0x4(%edx),%ecx
  801633:	89 08                	mov    %ecx,(%eax)
  801635:	8b 02                	mov    (%edx),%eax
  801637:	99                   	cltd   
  801638:	eb 0a                	jmp    801644 <getint+0x30>
	else
		return va_arg(*ap, int);
  80163a:	8b 10                	mov    (%eax),%edx
  80163c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80163f:	89 08                	mov    %ecx,(%eax)
  801641:	8b 02                	mov    (%edx),%eax
  801643:	99                   	cltd   
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80164c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80164f:	8b 10                	mov    (%eax),%edx
  801651:	3b 50 04             	cmp    0x4(%eax),%edx
  801654:	73 08                	jae    80165e <sprintputch+0x18>
		*b->buf++ = ch;
  801656:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801659:	88 0a                	mov    %cl,(%edx)
  80165b:	42                   	inc    %edx
  80165c:	89 10                	mov    %edx,(%eax)
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801666:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801669:	50                   	push   %eax
  80166a:	ff 75 10             	pushl  0x10(%ebp)
  80166d:	ff 75 0c             	pushl  0xc(%ebp)
  801670:	ff 75 08             	pushl  0x8(%ebp)
  801673:	e8 05 00 00 00       	call   80167d <vprintfmt>
	va_end(ap);
  801678:	83 c4 10             	add    $0x10,%esp
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	57                   	push   %edi
  801681:	56                   	push   %esi
  801682:	53                   	push   %ebx
  801683:	83 ec 2c             	sub    $0x2c,%esp
  801686:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801689:	8b 75 10             	mov    0x10(%ebp),%esi
  80168c:	eb 13                	jmp    8016a1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80168e:	85 c0                	test   %eax,%eax
  801690:	0f 84 6d 03 00 00    	je     801a03 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	57                   	push   %edi
  80169a:	50                   	push   %eax
  80169b:	ff 55 08             	call   *0x8(%ebp)
  80169e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a1:	0f b6 06             	movzbl (%esi),%eax
  8016a4:	46                   	inc    %esi
  8016a5:	83 f8 25             	cmp    $0x25,%eax
  8016a8:	75 e4                	jne    80168e <vprintfmt+0x11>
  8016aa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8016ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8016b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8016bc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8016c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c8:	eb 28                	jmp    8016f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ca:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8016cc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8016d0:	eb 20                	jmp    8016f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016d2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016d4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8016d8:	eb 18                	jmp    8016f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016da:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8016dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8016e3:	eb 0d                	jmp    8016f2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8016e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f2:	8a 06                	mov    (%esi),%al
  8016f4:	0f b6 d0             	movzbl %al,%edx
  8016f7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8016fa:	83 e8 23             	sub    $0x23,%eax
  8016fd:	3c 55                	cmp    $0x55,%al
  8016ff:	0f 87 e0 02 00 00    	ja     8019e5 <vprintfmt+0x368>
  801705:	0f b6 c0             	movzbl %al,%eax
  801708:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80170f:	83 ea 30             	sub    $0x30,%edx
  801712:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801715:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801718:	8d 50 d0             	lea    -0x30(%eax),%edx
  80171b:	83 fa 09             	cmp    $0x9,%edx
  80171e:	77 44                	ja     801764 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801720:	89 de                	mov    %ebx,%esi
  801722:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801725:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801726:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801729:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80172d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801730:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801733:	83 fb 09             	cmp    $0x9,%ebx
  801736:	76 ed                	jbe    801725 <vprintfmt+0xa8>
  801738:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80173b:	eb 29                	jmp    801766 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80173d:	8b 45 14             	mov    0x14(%ebp),%eax
  801740:	8d 50 04             	lea    0x4(%eax),%edx
  801743:	89 55 14             	mov    %edx,0x14(%ebp)
  801746:	8b 00                	mov    (%eax),%eax
  801748:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80174d:	eb 17                	jmp    801766 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80174f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801753:	78 85                	js     8016da <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801755:	89 de                	mov    %ebx,%esi
  801757:	eb 99                	jmp    8016f2 <vprintfmt+0x75>
  801759:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80175b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801762:	eb 8e                	jmp    8016f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801764:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801766:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80176a:	79 86                	jns    8016f2 <vprintfmt+0x75>
  80176c:	e9 74 ff ff ff       	jmp    8016e5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801771:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801772:	89 de                	mov    %ebx,%esi
  801774:	e9 79 ff ff ff       	jmp    8016f2 <vprintfmt+0x75>
  801779:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80177c:	8b 45 14             	mov    0x14(%ebp),%eax
  80177f:	8d 50 04             	lea    0x4(%eax),%edx
  801782:	89 55 14             	mov    %edx,0x14(%ebp)
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	57                   	push   %edi
  801789:	ff 30                	pushl  (%eax)
  80178b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80178e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801791:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801794:	e9 08 ff ff ff       	jmp    8016a1 <vprintfmt+0x24>
  801799:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80179c:	8b 45 14             	mov    0x14(%ebp),%eax
  80179f:	8d 50 04             	lea    0x4(%eax),%edx
  8017a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017a5:	8b 00                	mov    (%eax),%eax
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	79 02                	jns    8017ad <vprintfmt+0x130>
  8017ab:	f7 d8                	neg    %eax
  8017ad:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017af:	83 f8 0f             	cmp    $0xf,%eax
  8017b2:	7f 0b                	jg     8017bf <vprintfmt+0x142>
  8017b4:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	75 1a                	jne    8017d9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8017bf:	52                   	push   %edx
  8017c0:	68 a3 1f 80 00       	push   $0x801fa3
  8017c5:	57                   	push   %edi
  8017c6:	ff 75 08             	pushl  0x8(%ebp)
  8017c9:	e8 92 fe ff ff       	call   801660 <printfmt>
  8017ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017d4:	e9 c8 fe ff ff       	jmp    8016a1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8017d9:	50                   	push   %eax
  8017da:	68 21 1f 80 00       	push   $0x801f21
  8017df:	57                   	push   %edi
  8017e0:	ff 75 08             	pushl  0x8(%ebp)
  8017e3:	e8 78 fe ff ff       	call   801660 <printfmt>
  8017e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8017ee:	e9 ae fe ff ff       	jmp    8016a1 <vprintfmt+0x24>
  8017f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017f6:	89 de                	mov    %ebx,%esi
  8017f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8017fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801801:	8d 50 04             	lea    0x4(%eax),%edx
  801804:	89 55 14             	mov    %edx,0x14(%ebp)
  801807:	8b 00                	mov    (%eax),%eax
  801809:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80180c:	85 c0                	test   %eax,%eax
  80180e:	75 07                	jne    801817 <vprintfmt+0x19a>
				p = "(null)";
  801810:	c7 45 d0 9c 1f 80 00 	movl   $0x801f9c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801817:	85 db                	test   %ebx,%ebx
  801819:	7e 42                	jle    80185d <vprintfmt+0x1e0>
  80181b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80181f:	74 3c                	je     80185d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	51                   	push   %ecx
  801825:	ff 75 d0             	pushl  -0x30(%ebp)
  801828:	e8 43 e9 ff ff       	call   800170 <strnlen>
  80182d:	29 c3                	sub    %eax,%ebx
  80182f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 db                	test   %ebx,%ebx
  801837:	7e 24                	jle    80185d <vprintfmt+0x1e0>
					putch(padc, putdat);
  801839:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80183d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801840:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	57                   	push   %edi
  801847:	53                   	push   %ebx
  801848:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80184b:	4e                   	dec    %esi
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 f6                	test   %esi,%esi
  801851:	7f f0                	jg     801843 <vprintfmt+0x1c6>
  801853:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801856:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80185d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801860:	0f be 02             	movsbl (%edx),%eax
  801863:	85 c0                	test   %eax,%eax
  801865:	75 47                	jne    8018ae <vprintfmt+0x231>
  801867:	eb 37                	jmp    8018a0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  801869:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80186d:	74 16                	je     801885 <vprintfmt+0x208>
  80186f:	8d 50 e0             	lea    -0x20(%eax),%edx
  801872:	83 fa 5e             	cmp    $0x5e,%edx
  801875:	76 0e                	jbe    801885 <vprintfmt+0x208>
					putch('?', putdat);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	57                   	push   %edi
  80187b:	6a 3f                	push   $0x3f
  80187d:	ff 55 08             	call   *0x8(%ebp)
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	eb 0b                	jmp    801890 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	57                   	push   %edi
  801889:	50                   	push   %eax
  80188a:	ff 55 08             	call   *0x8(%ebp)
  80188d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801890:	ff 4d e4             	decl   -0x1c(%ebp)
  801893:	0f be 03             	movsbl (%ebx),%eax
  801896:	85 c0                	test   %eax,%eax
  801898:	74 03                	je     80189d <vprintfmt+0x220>
  80189a:	43                   	inc    %ebx
  80189b:	eb 1b                	jmp    8018b8 <vprintfmt+0x23b>
  80189d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018a4:	7f 1e                	jg     8018c4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8018a9:	e9 f3 fd ff ff       	jmp    8016a1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8018b1:	43                   	inc    %ebx
  8018b2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8018b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8018b8:	85 f6                	test   %esi,%esi
  8018ba:	78 ad                	js     801869 <vprintfmt+0x1ec>
  8018bc:	4e                   	dec    %esi
  8018bd:	79 aa                	jns    801869 <vprintfmt+0x1ec>
  8018bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8018c2:	eb dc                	jmp    8018a0 <vprintfmt+0x223>
  8018c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	57                   	push   %edi
  8018cb:	6a 20                	push   $0x20
  8018cd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018d0:	4b                   	dec    %ebx
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 db                	test   %ebx,%ebx
  8018d6:	7f ef                	jg     8018c7 <vprintfmt+0x24a>
  8018d8:	e9 c4 fd ff ff       	jmp    8016a1 <vprintfmt+0x24>
  8018dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018e0:	89 ca                	mov    %ecx,%edx
  8018e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e5:	e8 2a fd ff ff       	call   801614 <getint>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8018ee:	85 d2                	test   %edx,%edx
  8018f0:	78 0a                	js     8018fc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018f7:	e9 b0 00 00 00       	jmp    8019ac <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	57                   	push   %edi
  801900:	6a 2d                	push   $0x2d
  801902:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801905:	f7 db                	neg    %ebx
  801907:	83 d6 00             	adc    $0x0,%esi
  80190a:	f7 de                	neg    %esi
  80190c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80190f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801914:	e9 93 00 00 00       	jmp    8019ac <vprintfmt+0x32f>
  801919:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80191c:	89 ca                	mov    %ecx,%edx
  80191e:	8d 45 14             	lea    0x14(%ebp),%eax
  801921:	e8 b4 fc ff ff       	call   8015da <getuint>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	89 d6                	mov    %edx,%esi
			base = 10;
  80192a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80192f:	eb 7b                	jmp    8019ac <vprintfmt+0x32f>
  801931:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801934:	89 ca                	mov    %ecx,%edx
  801936:	8d 45 14             	lea    0x14(%ebp),%eax
  801939:	e8 d6 fc ff ff       	call   801614 <getint>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801942:	85 d2                	test   %edx,%edx
  801944:	78 07                	js     80194d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801946:	b8 08 00 00 00       	mov    $0x8,%eax
  80194b:	eb 5f                	jmp    8019ac <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	57                   	push   %edi
  801951:	6a 2d                	push   $0x2d
  801953:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801956:	f7 db                	neg    %ebx
  801958:	83 d6 00             	adc    $0x0,%esi
  80195b:	f7 de                	neg    %esi
  80195d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	eb 45                	jmp    8019ac <vprintfmt+0x32f>
  801967:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	57                   	push   %edi
  80196e:	6a 30                	push   $0x30
  801970:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801973:	83 c4 08             	add    $0x8,%esp
  801976:	57                   	push   %edi
  801977:	6a 78                	push   $0x78
  801979:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80197c:	8b 45 14             	mov    0x14(%ebp),%eax
  80197f:	8d 50 04             	lea    0x4(%eax),%edx
  801982:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801985:	8b 18                	mov    (%eax),%ebx
  801987:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80198c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80198f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801994:	eb 16                	jmp    8019ac <vprintfmt+0x32f>
  801996:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801999:	89 ca                	mov    %ecx,%edx
  80199b:	8d 45 14             	lea    0x14(%ebp),%eax
  80199e:	e8 37 fc ff ff       	call   8015da <getuint>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	89 d6                	mov    %edx,%esi
			base = 16;
  8019a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8019b3:	52                   	push   %edx
  8019b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b7:	50                   	push   %eax
  8019b8:	56                   	push   %esi
  8019b9:	53                   	push   %ebx
  8019ba:	89 fa                	mov    %edi,%edx
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	e8 68 fb ff ff       	call   80152c <printnum>
			break;
  8019c4:	83 c4 20             	add    $0x20,%esp
  8019c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019ca:	e9 d2 fc ff ff       	jmp    8016a1 <vprintfmt+0x24>
  8019cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	57                   	push   %edi
  8019d6:	52                   	push   %edx
  8019d7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8019da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019e0:	e9 bc fc ff ff       	jmp    8016a1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	57                   	push   %edi
  8019e9:	6a 25                	push   $0x25
  8019eb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	eb 02                	jmp    8019f5 <vprintfmt+0x378>
  8019f3:	89 c6                	mov    %eax,%esi
  8019f5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8019f8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8019fc:	75 f5                	jne    8019f3 <vprintfmt+0x376>
  8019fe:	e9 9e fc ff ff       	jmp    8016a1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 18             	sub    $0x18,%esp
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a1a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a1e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	74 26                	je     801a52 <vsnprintf+0x47>
  801a2c:	85 d2                	test   %edx,%edx
  801a2e:	7e 29                	jle    801a59 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a30:	ff 75 14             	pushl  0x14(%ebp)
  801a33:	ff 75 10             	pushl  0x10(%ebp)
  801a36:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a39:	50                   	push   %eax
  801a3a:	68 46 16 80 00       	push   $0x801646
  801a3f:	e8 39 fc ff ff       	call   80167d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	eb 0c                	jmp    801a5e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a57:	eb 05                	jmp    801a5e <vsnprintf+0x53>
  801a59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a69:	50                   	push   %eax
  801a6a:	ff 75 10             	pushl  0x10(%ebp)
  801a6d:	ff 75 0c             	pushl  0xc(%ebp)
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 93 ff ff ff       	call   801a0b <vsnprintf>
	va_end(ap);

	return rc;
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    
	...

00801a7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	8b 75 08             	mov    0x8(%ebp),%esi
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	74 0e                	je     801a9c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	50                   	push   %eax
  801a92:	e8 88 ec ff ff       	call   80071f <sys_ipc_recv>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	eb 10                	jmp    801aac <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	68 00 00 c0 ee       	push   $0xeec00000
  801aa4:	e8 76 ec ff ff       	call   80071f <sys_ipc_recv>
  801aa9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801aac:	85 c0                	test   %eax,%eax
  801aae:	75 26                	jne    801ad6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 0a                	je     801abe <ipc_recv+0x42>
  801ab4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab9:	8b 40 74             	mov    0x74(%eax),%eax
  801abc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	74 0a                	je     801acc <ipc_recv+0x50>
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 40 78             	mov    0x78(%eax),%eax
  801aca:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 70             	mov    0x70(%eax),%eax
  801ad4:	eb 14                	jmp    801aea <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ad6:	85 f6                	test   %esi,%esi
  801ad8:	74 06                	je     801ae0 <ipc_recv+0x64>
  801ada:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ae0:	85 db                	test   %ebx,%ebx
  801ae2:	74 06                	je     801aea <ipc_recv+0x6e>
  801ae4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b00:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b03:	85 db                	test   %ebx,%ebx
  801b05:	75 25                	jne    801b2c <ipc_send+0x3b>
  801b07:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b0c:	eb 1e                	jmp    801b2c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b0e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b11:	75 07                	jne    801b1a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b13:	e8 e5 ea ff ff       	call   8005fd <sys_yield>
  801b18:	eb 12                	jmp    801b2c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b1a:	50                   	push   %eax
  801b1b:	68 80 22 80 00       	push   $0x802280
  801b20:	6a 43                	push   $0x43
  801b22:	68 93 22 80 00       	push   $0x802293
  801b27:	e8 14 f9 ff ff       	call   801440 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b2c:	56                   	push   %esi
  801b2d:	53                   	push   %ebx
  801b2e:	57                   	push   %edi
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	e8 c3 eb ff ff       	call   8006fa <sys_ipc_try_send>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	75 d0                	jne    801b0e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b4d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b53:	74 22                	je     801b77 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b55:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b5a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	c1 e2 07             	shl    $0x7,%edx
  801b66:	29 ca                	sub    %ecx,%edx
  801b68:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b6e:	8b 52 50             	mov    0x50(%edx),%edx
  801b71:	39 da                	cmp    %ebx,%edx
  801b73:	75 1d                	jne    801b92 <ipc_find_env+0x4c>
  801b75:	eb 05                	jmp    801b7c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b83:	c1 e0 07             	shl    $0x7,%eax
  801b86:	29 d0                	sub    %edx,%eax
  801b88:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b8d:	8b 40 40             	mov    0x40(%eax),%eax
  801b90:	eb 0c                	jmp    801b9e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b92:	40                   	inc    %eax
  801b93:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b98:	75 c0                	jne    801b5a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b9a:	66 b8 00 00          	mov    $0x0,%ax
}
  801b9e:	5b                   	pop    %ebx
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    
  801ba1:	00 00                	add    %al,(%eax)
	...

00801ba4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	c1 ea 16             	shr    $0x16,%edx
  801baf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bb6:	f6 c2 01             	test   $0x1,%dl
  801bb9:	74 1e                	je     801bd9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bbb:	c1 e8 0c             	shr    $0xc,%eax
  801bbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bc5:	a8 01                	test   $0x1,%al
  801bc7:	74 17                	je     801be0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc9:	c1 e8 0c             	shr    $0xc,%eax
  801bcc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bd3:	ef 
  801bd4:	0f b7 c0             	movzwl %ax,%eax
  801bd7:	eb 0c                	jmp    801be5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bde:	eb 05                	jmp    801be5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    
	...

00801be8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	83 ec 10             	sub    $0x10,%esp
  801bf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bf3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bf6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801bf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bfc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bff:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c02:	85 c0                	test   %eax,%eax
  801c04:	75 2e                	jne    801c34 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c06:	39 f1                	cmp    %esi,%ecx
  801c08:	77 5a                	ja     801c64 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c0a:	85 c9                	test   %ecx,%ecx
  801c0c:	75 0b                	jne    801c19 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c13:	31 d2                	xor    %edx,%edx
  801c15:	f7 f1                	div    %ecx
  801c17:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c19:	31 d2                	xor    %edx,%edx
  801c1b:	89 f0                	mov    %esi,%eax
  801c1d:	f7 f1                	div    %ecx
  801c1f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c21:	89 f8                	mov    %edi,%eax
  801c23:	f7 f1                	div    %ecx
  801c25:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c27:	89 f8                	mov    %edi,%eax
  801c29:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    
  801c32:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c34:	39 f0                	cmp    %esi,%eax
  801c36:	77 1c                	ja     801c54 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c38:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c3b:	83 f7 1f             	xor    $0x1f,%edi
  801c3e:	75 3c                	jne    801c7c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c40:	39 f0                	cmp    %esi,%eax
  801c42:	0f 82 90 00 00 00    	jb     801cd8 <__udivdi3+0xf0>
  801c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c4b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c4e:	0f 86 84 00 00 00    	jbe    801cd8 <__udivdi3+0xf0>
  801c54:	31 f6                	xor    %esi,%esi
  801c56:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c58:	89 f8                	mov    %edi,%eax
  801c5a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	5e                   	pop    %esi
  801c60:	5f                   	pop    %edi
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    
  801c63:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c64:	89 f2                	mov    %esi,%edx
  801c66:	89 f8                	mov    %edi,%eax
  801c68:	f7 f1                	div    %ecx
  801c6a:	89 c7                	mov    %eax,%edi
  801c6c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6e:	89 f8                	mov    %edi,%eax
  801c70:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    
  801c79:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c7c:	89 f9                	mov    %edi,%ecx
  801c7e:	d3 e0                	shl    %cl,%eax
  801c80:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c83:	b8 20 00 00 00       	mov    $0x20,%eax
  801c88:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c8d:	88 c1                	mov    %al,%cl
  801c8f:	d3 ea                	shr    %cl,%edx
  801c91:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c94:	09 ca                	or     %ecx,%edx
  801c96:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c9c:	89 f9                	mov    %edi,%ecx
  801c9e:	d3 e2                	shl    %cl,%edx
  801ca0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801ca3:	89 f2                	mov    %esi,%edx
  801ca5:	88 c1                	mov    %al,%cl
  801ca7:	d3 ea                	shr    %cl,%edx
  801ca9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	89 f9                	mov    %edi,%ecx
  801cb0:	d3 e2                	shl    %cl,%edx
  801cb2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801cb5:	88 c1                	mov    %al,%cl
  801cb7:	d3 ee                	shr    %cl,%esi
  801cb9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cbb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	89 ca                	mov    %ecx,%edx
  801cc2:	f7 75 ec             	divl   -0x14(%ebp)
  801cc5:	89 d1                	mov    %edx,%ecx
  801cc7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cc9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ccc:	39 d1                	cmp    %edx,%ecx
  801cce:	72 28                	jb     801cf8 <__udivdi3+0x110>
  801cd0:	74 1a                	je     801cec <__udivdi3+0x104>
  801cd2:	89 f7                	mov    %esi,%edi
  801cd4:	31 f6                	xor    %esi,%esi
  801cd6:	eb 80                	jmp    801c58 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cd8:	31 f6                	xor    %esi,%esi
  801cda:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    
  801cea:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cef:	89 f9                	mov    %edi,%ecx
  801cf1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cf3:	39 c2                	cmp    %eax,%edx
  801cf5:	73 db                	jae    801cd2 <__udivdi3+0xea>
  801cf7:	90                   	nop
		{
		  q0--;
  801cf8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cfb:	31 f6                	xor    %esi,%esi
  801cfd:	e9 56 ff ff ff       	jmp    801c58 <__udivdi3+0x70>
	...

00801d04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	57                   	push   %edi
  801d08:	56                   	push   %esi
  801d09:	83 ec 20             	sub    $0x20,%esp
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d12:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d15:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d21:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d23:	85 ff                	test   %edi,%edi
  801d25:	75 15                	jne    801d3c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d27:	39 f1                	cmp    %esi,%ecx
  801d29:	0f 86 99 00 00 00    	jbe    801dc8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d2f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d31:	89 d0                	mov    %edx,%eax
  801d33:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d35:	83 c4 20             	add    $0x20,%esp
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	0f 87 a4 00 00 00    	ja     801de8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d44:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d47:	83 f0 1f             	xor    $0x1f,%eax
  801d4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d4d:	0f 84 a1 00 00 00    	je     801df4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d53:	89 f8                	mov    %edi,%eax
  801d55:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d58:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d5a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d5f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	09 c2                	or     %eax,%edx
  801d6b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d74:	d3 e0                	shl    %cl,%eax
  801d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d79:	89 f2                	mov    %esi,%edx
  801d7b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d80:	d3 e0                	shl    %cl,%eax
  801d82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d88:	89 f9                	mov    %edi,%ecx
  801d8a:	d3 e8                	shr    %cl,%eax
  801d8c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d8e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	f7 75 f0             	divl   -0x10(%ebp)
  801d95:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d97:	f7 65 f4             	mull   -0xc(%ebp)
  801d9a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d9d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d9f:	39 d6                	cmp    %edx,%esi
  801da1:	72 71                	jb     801e14 <__umoddi3+0x110>
  801da3:	74 7f                	je     801e24 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da8:	29 c8                	sub    %ecx,%eax
  801daa:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dac:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801daf:	d3 e8                	shr    %cl,%eax
  801db1:	89 f2                	mov    %esi,%edx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801db7:	09 d0                	or     %edx,%eax
  801db9:	89 f2                	mov    %esi,%edx
  801dbb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dbe:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dc0:	83 c4 20             	add    $0x20,%esp
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    
  801dc7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dc8:	85 c9                	test   %ecx,%ecx
  801dca:	75 0b                	jne    801dd7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd1:	31 d2                	xor    %edx,%edx
  801dd3:	f7 f1                	div    %ecx
  801dd5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	31 d2                	xor    %edx,%edx
  801ddb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de0:	f7 f1                	div    %ecx
  801de2:	e9 4a ff ff ff       	jmp    801d31 <__umoddi3+0x2d>
  801de7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801de8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dea:	83 c4 20             	add    $0x20,%esp
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	c9                   	leave  
  801df0:	c3                   	ret    
  801df1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df4:	39 f7                	cmp    %esi,%edi
  801df6:	72 05                	jb     801dfd <__umoddi3+0xf9>
  801df8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801dfb:	77 0c                	ja     801e09 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dfd:	89 f2                	mov    %esi,%edx
  801dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e02:	29 c8                	sub    %ecx,%eax
  801e04:	19 fa                	sbb    %edi,%edx
  801e06:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e0c:	83 c4 20             	add    $0x20,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    
  801e13:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e14:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e17:	89 c1                	mov    %eax,%ecx
  801e19:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e1c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e1f:	eb 84                	jmp    801da5 <__umoddi3+0xa1>
  801e21:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e24:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e27:	72 eb                	jb     801e14 <__umoddi3+0x110>
  801e29:	89 f2                	mov    %esi,%edx
  801e2b:	e9 75 ff ff ff       	jmp    801da5 <__umoddi3+0xa1>
