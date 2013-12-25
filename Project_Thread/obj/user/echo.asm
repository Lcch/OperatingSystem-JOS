
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
  80004e:	68 60 1e 80 00       	push   $0x801e60
  800053:	ff 76 04             	pushl  0x4(%esi)
  800056:	e8 fc 01 00 00       	call   800257 <strcmp>
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
  800074:	68 63 1e 80 00       	push   $0x801e63
  800079:	6a 01                	push   $0x1
  80007b:	e8 44 0b 00 00       	call   800bc4 <write>
  800080:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800083:	83 ec 0c             	sub    $0xc,%esp
  800086:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800089:	e8 be 00 00 00       	call   80014c <strlen>
  80008e:	83 c4 0c             	add    $0xc,%esp
  800091:	50                   	push   %eax
  800092:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800095:	6a 01                	push   $0x1
  800097:	e8 28 0b 00 00       	call   800bc4 <write>
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
  8000af:	68 73 1f 80 00       	push   $0x801f73
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 09 0b 00 00       	call   800bc4 <write>
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
  8000ef:	e8 e1 04 00 00       	call   8005d5 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	89 c2                	mov    %eax,%edx
  8000fb:	c1 e2 07             	shl    $0x7,%edx
  8000fe:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800105:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 f6                	test   %esi,%esi
  80010c:	7e 07                	jle    800115 <libmain+0x31>
		binaryname = argv[0];
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	53                   	push   %ebx
  800119:	56                   	push   %esi
  80011a:	e8 15 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0c 00 00 00       	call   800130 <exit>
  800124:	83 c4 10             	add    $0x10,%esp
}
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    
	...

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800136:	e8 9b 08 00 00       	call   8009d6 <close_all>
	sys_env_destroy(0);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	6a 00                	push   $0x0
  800140:	e8 6e 04 00 00       	call   8005b3 <sys_env_destroy>
  800145:	83 c4 10             	add    $0x10,%esp
}
  800148:	c9                   	leave  
  800149:	c3                   	ret    
	...

0080014c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800152:	80 3a 00             	cmpb   $0x0,(%edx)
  800155:	74 0e                	je     800165 <strlen+0x19>
  800157:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80015c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80015d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800161:	75 f9                	jne    80015c <strlen+0x10>
  800163:	eb 05                	jmp    80016a <strlen+0x1e>
  800165:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800175:	85 d2                	test   %edx,%edx
  800177:	74 17                	je     800190 <strnlen+0x24>
  800179:	80 39 00             	cmpb   $0x0,(%ecx)
  80017c:	74 19                	je     800197 <strnlen+0x2b>
  80017e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800183:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800184:	39 d0                	cmp    %edx,%eax
  800186:	74 14                	je     80019c <strnlen+0x30>
  800188:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80018c:	75 f5                	jne    800183 <strnlen+0x17>
  80018e:	eb 0c                	jmp    80019c <strnlen+0x30>
  800190:	b8 00 00 00 00       	mov    $0x0,%eax
  800195:	eb 05                	jmp    80019c <strnlen+0x30>
  800197:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ad:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001b0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001b3:	42                   	inc    %edx
  8001b4:	84 c9                	test   %cl,%cl
  8001b6:	75 f5                	jne    8001ad <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001b8:	5b                   	pop    %ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c2:	53                   	push   %ebx
  8001c3:	e8 84 ff ff ff       	call   80014c <strlen>
  8001c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001cb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ce:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 c7 ff ff ff       	call   80019e <strcpy>
	return dst;
}
  8001d7:	89 d8                	mov    %ebx,%eax
  8001d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    

008001de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001ec:	85 f6                	test   %esi,%esi
  8001ee:	74 15                	je     800205 <strncpy+0x27>
  8001f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8001f5:	8a 1a                	mov    (%edx),%bl
  8001f7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8001fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800200:	41                   	inc    %ecx
  800201:	39 ce                	cmp    %ecx,%esi
  800203:	77 f0                	ja     8001f5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800215:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800218:	85 f6                	test   %esi,%esi
  80021a:	74 32                	je     80024e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80021c:	83 fe 01             	cmp    $0x1,%esi
  80021f:	74 22                	je     800243 <strlcpy+0x3a>
  800221:	8a 0b                	mov    (%ebx),%cl
  800223:	84 c9                	test   %cl,%cl
  800225:	74 20                	je     800247 <strlcpy+0x3e>
  800227:	89 f8                	mov    %edi,%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80022e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800231:	88 08                	mov    %cl,(%eax)
  800233:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800234:	39 f2                	cmp    %esi,%edx
  800236:	74 11                	je     800249 <strlcpy+0x40>
  800238:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80023c:	42                   	inc    %edx
  80023d:	84 c9                	test   %cl,%cl
  80023f:	75 f0                	jne    800231 <strlcpy+0x28>
  800241:	eb 06                	jmp    800249 <strlcpy+0x40>
  800243:	89 f8                	mov    %edi,%eax
  800245:	eb 02                	jmp    800249 <strlcpy+0x40>
  800247:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800249:	c6 00 00             	movb   $0x0,(%eax)
  80024c:	eb 02                	jmp    800250 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80024e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800250:	29 f8                	sub    %edi,%eax
}
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800260:	8a 01                	mov    (%ecx),%al
  800262:	84 c0                	test   %al,%al
  800264:	74 10                	je     800276 <strcmp+0x1f>
  800266:	3a 02                	cmp    (%edx),%al
  800268:	75 0c                	jne    800276 <strcmp+0x1f>
		p++, q++;
  80026a:	41                   	inc    %ecx
  80026b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80026c:	8a 01                	mov    (%ecx),%al
  80026e:	84 c0                	test   %al,%al
  800270:	74 04                	je     800276 <strcmp+0x1f>
  800272:	3a 02                	cmp    (%edx),%al
  800274:	74 f4                	je     80026a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800276:	0f b6 c0             	movzbl %al,%eax
  800279:	0f b6 12             	movzbl (%edx),%edx
  80027c:	29 d0                	sub    %edx,%eax
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	53                   	push   %ebx
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80028d:	85 c0                	test   %eax,%eax
  80028f:	74 1b                	je     8002ac <strncmp+0x2c>
  800291:	8a 1a                	mov    (%edx),%bl
  800293:	84 db                	test   %bl,%bl
  800295:	74 24                	je     8002bb <strncmp+0x3b>
  800297:	3a 19                	cmp    (%ecx),%bl
  800299:	75 20                	jne    8002bb <strncmp+0x3b>
  80029b:	48                   	dec    %eax
  80029c:	74 15                	je     8002b3 <strncmp+0x33>
		n--, p++, q++;
  80029e:	42                   	inc    %edx
  80029f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8002a0:	8a 1a                	mov    (%edx),%bl
  8002a2:	84 db                	test   %bl,%bl
  8002a4:	74 15                	je     8002bb <strncmp+0x3b>
  8002a6:	3a 19                	cmp    (%ecx),%bl
  8002a8:	74 f1                	je     80029b <strncmp+0x1b>
  8002aa:	eb 0f                	jmp    8002bb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b1:	eb 05                	jmp    8002b8 <strncmp+0x38>
  8002b3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002b8:	5b                   	pop    %ebx
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002bb:	0f b6 02             	movzbl (%edx),%eax
  8002be:	0f b6 11             	movzbl (%ecx),%edx
  8002c1:	29 d0                	sub    %edx,%eax
  8002c3:	eb f3                	jmp    8002b8 <strncmp+0x38>

008002c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002ce:	8a 10                	mov    (%eax),%dl
  8002d0:	84 d2                	test   %dl,%dl
  8002d2:	74 18                	je     8002ec <strchr+0x27>
		if (*s == c)
  8002d4:	38 ca                	cmp    %cl,%dl
  8002d6:	75 06                	jne    8002de <strchr+0x19>
  8002d8:	eb 17                	jmp    8002f1 <strchr+0x2c>
  8002da:	38 ca                	cmp    %cl,%dl
  8002dc:	74 13                	je     8002f1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002de:	40                   	inc    %eax
  8002df:	8a 10                	mov    (%eax),%dl
  8002e1:	84 d2                	test   %dl,%dl
  8002e3:	75 f5                	jne    8002da <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	eb 05                	jmp    8002f1 <strchr+0x2c>
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002fc:	8a 10                	mov    (%eax),%dl
  8002fe:	84 d2                	test   %dl,%dl
  800300:	74 11                	je     800313 <strfind+0x20>
		if (*s == c)
  800302:	38 ca                	cmp    %cl,%dl
  800304:	75 06                	jne    80030c <strfind+0x19>
  800306:	eb 0b                	jmp    800313 <strfind+0x20>
  800308:	38 ca                	cmp    %cl,%dl
  80030a:	74 07                	je     800313 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80030c:	40                   	inc    %eax
  80030d:	8a 10                	mov    (%eax),%dl
  80030f:	84 d2                	test   %dl,%dl
  800311:	75 f5                	jne    800308 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800321:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800324:	85 c9                	test   %ecx,%ecx
  800326:	74 30                	je     800358 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800328:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80032e:	75 25                	jne    800355 <memset+0x40>
  800330:	f6 c1 03             	test   $0x3,%cl
  800333:	75 20                	jne    800355 <memset+0x40>
		c &= 0xFF;
  800335:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800338:	89 d3                	mov    %edx,%ebx
  80033a:	c1 e3 08             	shl    $0x8,%ebx
  80033d:	89 d6                	mov    %edx,%esi
  80033f:	c1 e6 18             	shl    $0x18,%esi
  800342:	89 d0                	mov    %edx,%eax
  800344:	c1 e0 10             	shl    $0x10,%eax
  800347:	09 f0                	or     %esi,%eax
  800349:	09 d0                	or     %edx,%eax
  80034b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80034d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800350:	fc                   	cld    
  800351:	f3 ab                	rep stos %eax,%es:(%edi)
  800353:	eb 03                	jmp    800358 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800355:	fc                   	cld    
  800356:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800358:	89 f8                	mov    %edi,%eax
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    

0080035f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80036d:	39 c6                	cmp    %eax,%esi
  80036f:	73 34                	jae    8003a5 <memmove+0x46>
  800371:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800374:	39 d0                	cmp    %edx,%eax
  800376:	73 2d                	jae    8003a5 <memmove+0x46>
		s += n;
		d += n;
  800378:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80037b:	f6 c2 03             	test   $0x3,%dl
  80037e:	75 1b                	jne    80039b <memmove+0x3c>
  800380:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800386:	75 13                	jne    80039b <memmove+0x3c>
  800388:	f6 c1 03             	test   $0x3,%cl
  80038b:	75 0e                	jne    80039b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80038d:	83 ef 04             	sub    $0x4,%edi
  800390:	8d 72 fc             	lea    -0x4(%edx),%esi
  800393:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800396:	fd                   	std    
  800397:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800399:	eb 07                	jmp    8003a2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80039b:	4f                   	dec    %edi
  80039c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80039f:	fd                   	std    
  8003a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8003a2:	fc                   	cld    
  8003a3:	eb 20                	jmp    8003c5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8003ab:	75 13                	jne    8003c0 <memmove+0x61>
  8003ad:	a8 03                	test   $0x3,%al
  8003af:	75 0f                	jne    8003c0 <memmove+0x61>
  8003b1:	f6 c1 03             	test   $0x3,%cl
  8003b4:	75 0a                	jne    8003c0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8003b6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8003b9:	89 c7                	mov    %eax,%edi
  8003bb:	fc                   	cld    
  8003bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003be:	eb 05                	jmp    8003c5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8003c0:	89 c7                	mov    %eax,%edi
  8003c2:	fc                   	cld    
  8003c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    

008003c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8003cc:	ff 75 10             	pushl  0x10(%ebp)
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	ff 75 08             	pushl  0x8(%ebp)
  8003d5:	e8 85 ff ff ff       	call   80035f <memmove>
}
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003eb:	85 ff                	test   %edi,%edi
  8003ed:	74 32                	je     800421 <memcmp+0x45>
		if (*s1 != *s2)
  8003ef:	8a 03                	mov    (%ebx),%al
  8003f1:	8a 0e                	mov    (%esi),%cl
  8003f3:	38 c8                	cmp    %cl,%al
  8003f5:	74 19                	je     800410 <memcmp+0x34>
  8003f7:	eb 0d                	jmp    800406 <memcmp+0x2a>
  8003f9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8003fd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800401:	42                   	inc    %edx
  800402:	38 c8                	cmp    %cl,%al
  800404:	74 10                	je     800416 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800406:	0f b6 c0             	movzbl %al,%eax
  800409:	0f b6 c9             	movzbl %cl,%ecx
  80040c:	29 c8                	sub    %ecx,%eax
  80040e:	eb 16                	jmp    800426 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800410:	4f                   	dec    %edi
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	39 fa                	cmp    %edi,%edx
  800418:	75 df                	jne    8003f9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 05                	jmp    800426 <memcmp+0x4a>
  800421:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800426:	5b                   	pop    %ebx
  800427:	5e                   	pop    %esi
  800428:	5f                   	pop    %edi
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800431:	89 c2                	mov    %eax,%edx
  800433:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800436:	39 d0                	cmp    %edx,%eax
  800438:	73 12                	jae    80044c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  80043a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80043d:	38 08                	cmp    %cl,(%eax)
  80043f:	75 06                	jne    800447 <memfind+0x1c>
  800441:	eb 09                	jmp    80044c <memfind+0x21>
  800443:	38 08                	cmp    %cl,(%eax)
  800445:	74 05                	je     80044c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800447:	40                   	inc    %eax
  800448:	39 c2                	cmp    %eax,%edx
  80044a:	77 f7                	ja     800443 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80045a:	eb 01                	jmp    80045d <strtol+0xf>
		s++;
  80045c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80045d:	8a 02                	mov    (%edx),%al
  80045f:	3c 20                	cmp    $0x20,%al
  800461:	74 f9                	je     80045c <strtol+0xe>
  800463:	3c 09                	cmp    $0x9,%al
  800465:	74 f5                	je     80045c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800467:	3c 2b                	cmp    $0x2b,%al
  800469:	75 08                	jne    800473 <strtol+0x25>
		s++;
  80046b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80046c:	bf 00 00 00 00       	mov    $0x0,%edi
  800471:	eb 13                	jmp    800486 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800473:	3c 2d                	cmp    $0x2d,%al
  800475:	75 0a                	jne    800481 <strtol+0x33>
		s++, neg = 1;
  800477:	8d 52 01             	lea    0x1(%edx),%edx
  80047a:	bf 01 00 00 00       	mov    $0x1,%edi
  80047f:	eb 05                	jmp    800486 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800481:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800486:	85 db                	test   %ebx,%ebx
  800488:	74 05                	je     80048f <strtol+0x41>
  80048a:	83 fb 10             	cmp    $0x10,%ebx
  80048d:	75 28                	jne    8004b7 <strtol+0x69>
  80048f:	8a 02                	mov    (%edx),%al
  800491:	3c 30                	cmp    $0x30,%al
  800493:	75 10                	jne    8004a5 <strtol+0x57>
  800495:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800499:	75 0a                	jne    8004a5 <strtol+0x57>
		s += 2, base = 16;
  80049b:	83 c2 02             	add    $0x2,%edx
  80049e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8004a3:	eb 12                	jmp    8004b7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	75 0e                	jne    8004b7 <strtol+0x69>
  8004a9:	3c 30                	cmp    $0x30,%al
  8004ab:	75 05                	jne    8004b2 <strtol+0x64>
		s++, base = 8;
  8004ad:	42                   	inc    %edx
  8004ae:	b3 08                	mov    $0x8,%bl
  8004b0:	eb 05                	jmp    8004b7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8004b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8004be:	8a 0a                	mov    (%edx),%cl
  8004c0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8004c3:	80 fb 09             	cmp    $0x9,%bl
  8004c6:	77 08                	ja     8004d0 <strtol+0x82>
			dig = *s - '0';
  8004c8:	0f be c9             	movsbl %cl,%ecx
  8004cb:	83 e9 30             	sub    $0x30,%ecx
  8004ce:	eb 1e                	jmp    8004ee <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8004d0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8004d3:	80 fb 19             	cmp    $0x19,%bl
  8004d6:	77 08                	ja     8004e0 <strtol+0x92>
			dig = *s - 'a' + 10;
  8004d8:	0f be c9             	movsbl %cl,%ecx
  8004db:	83 e9 57             	sub    $0x57,%ecx
  8004de:	eb 0e                	jmp    8004ee <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8004e0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8004e3:	80 fb 19             	cmp    $0x19,%bl
  8004e6:	77 13                	ja     8004fb <strtol+0xad>
			dig = *s - 'A' + 10;
  8004e8:	0f be c9             	movsbl %cl,%ecx
  8004eb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8004ee:	39 f1                	cmp    %esi,%ecx
  8004f0:	7d 0d                	jge    8004ff <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8004f2:	42                   	inc    %edx
  8004f3:	0f af c6             	imul   %esi,%eax
  8004f6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8004f9:	eb c3                	jmp    8004be <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8004fb:	89 c1                	mov    %eax,%ecx
  8004fd:	eb 02                	jmp    800501 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004ff:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800501:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800505:	74 05                	je     80050c <strtol+0xbe>
		*endptr = (char *) s;
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80050c:	85 ff                	test   %edi,%edi
  80050e:	74 04                	je     800514 <strtol+0xc6>
  800510:	89 c8                	mov    %ecx,%eax
  800512:	f7 d8                	neg    %eax
}
  800514:	5b                   	pop    %ebx
  800515:	5e                   	pop    %esi
  800516:	5f                   	pop    %edi
  800517:	c9                   	leave  
  800518:	c3                   	ret    
  800519:	00 00                	add    %al,(%eax)
	...

0080051c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	57                   	push   %edi
  800520:	56                   	push   %esi
  800521:	53                   	push   %ebx
  800522:	83 ec 1c             	sub    $0x1c,%esp
  800525:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800528:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80052b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052d:	8b 75 14             	mov    0x14(%ebp),%esi
  800530:	8b 7d 10             	mov    0x10(%ebp),%edi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800539:	cd 30                	int    $0x30
  80053b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80053d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800541:	74 1c                	je     80055f <syscall+0x43>
  800543:	85 c0                	test   %eax,%eax
  800545:	7e 18                	jle    80055f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800547:	83 ec 0c             	sub    $0xc,%esp
  80054a:	50                   	push   %eax
  80054b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80054e:	68 6f 1e 80 00       	push   $0x801e6f
  800553:	6a 42                	push   $0x42
  800555:	68 8c 1e 80 00       	push   $0x801e8c
  80055a:	e8 21 0f 00 00       	call   801480 <_panic>

	return ret;
}
  80055f:	89 d0                	mov    %edx,%eax
  800561:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800564:	5b                   	pop    %ebx
  800565:	5e                   	pop    %esi
  800566:	5f                   	pop    %edi
  800567:	c9                   	leave  
  800568:	c3                   	ret    

00800569 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80056f:	6a 00                	push   $0x0
  800571:	6a 00                	push   $0x0
  800573:	6a 00                	push   $0x0
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80057b:	ba 00 00 00 00       	mov    $0x0,%edx
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	e8 92 ff ff ff       	call   80051c <syscall>
  80058a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <sys_cgetc>:

int
sys_cgetc(void)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800595:	6a 00                	push   $0x0
  800597:	6a 00                	push   $0x0
  800599:	6a 00                	push   $0x0
  80059b:	6a 00                	push   $0x0
  80059d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8005ac:	e8 6b ff ff ff       	call   80051c <syscall>
}
  8005b1:	c9                   	leave  
  8005b2:	c3                   	ret    

008005b3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8005b9:	6a 00                	push   $0x0
  8005bb:	6a 00                	push   $0x0
  8005bd:	6a 00                	push   $0x0
  8005bf:	6a 00                	push   $0x0
  8005c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8005c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8005ce:	e8 49 ff ff ff       	call   80051c <syscall>
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8005db:	6a 00                	push   $0x0
  8005dd:	6a 00                	push   $0x0
  8005df:	6a 00                	push   $0x0
  8005e1:	6a 00                	push   $0x0
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8005f2:	e8 25 ff ff ff       	call   80051c <syscall>
}
  8005f7:	c9                   	leave  
  8005f8:	c3                   	ret    

008005f9 <sys_yield>:

void
sys_yield(void)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8005ff:	6a 00                	push   $0x0
  800601:	6a 00                	push   $0x0
  800603:	6a 00                	push   $0x0
  800605:	6a 00                	push   $0x0
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	ba 00 00 00 00       	mov    $0x0,%edx
  800611:	b8 0b 00 00 00       	mov    $0xb,%eax
  800616:	e8 01 ff ff ff       	call   80051c <syscall>
  80061b:	83 c4 10             	add    $0x10,%esp
}
  80061e:	c9                   	leave  
  80061f:	c3                   	ret    

00800620 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800626:	6a 00                	push   $0x0
  800628:	6a 00                	push   $0x0
  80062a:	ff 75 10             	pushl  0x10(%ebp)
  80062d:	ff 75 0c             	pushl  0xc(%ebp)
  800630:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800633:	ba 01 00 00 00       	mov    $0x1,%edx
  800638:	b8 04 00 00 00       	mov    $0x4,%eax
  80063d:	e8 da fe ff ff       	call   80051c <syscall>
}
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80064a:	ff 75 18             	pushl  0x18(%ebp)
  80064d:	ff 75 14             	pushl  0x14(%ebp)
  800650:	ff 75 10             	pushl  0x10(%ebp)
  800653:	ff 75 0c             	pushl  0xc(%ebp)
  800656:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800659:	ba 01 00 00 00       	mov    $0x1,%edx
  80065e:	b8 05 00 00 00       	mov    $0x5,%eax
  800663:	e8 b4 fe ff ff       	call   80051c <syscall>
}
  800668:	c9                   	leave  
  800669:	c3                   	ret    

0080066a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800670:	6a 00                	push   $0x0
  800672:	6a 00                	push   $0x0
  800674:	6a 00                	push   $0x0
  800676:	ff 75 0c             	pushl  0xc(%ebp)
  800679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067c:	ba 01 00 00 00       	mov    $0x1,%edx
  800681:	b8 06 00 00 00       	mov    $0x6,%eax
  800686:	e8 91 fe ff ff       	call   80051c <syscall>
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800693:	6a 00                	push   $0x0
  800695:	6a 00                	push   $0x0
  800697:	6a 00                	push   $0x0
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069f:	ba 01 00 00 00       	mov    $0x1,%edx
  8006a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a9:	e8 6e fe ff ff       	call   80051c <syscall>
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8006b6:	6a 00                	push   $0x0
  8006b8:	6a 00                	push   $0x0
  8006ba:	6a 00                	push   $0x0
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c2:	ba 01 00 00 00       	mov    $0x1,%edx
  8006c7:	b8 09 00 00 00       	mov    $0x9,%eax
  8006cc:	e8 4b fe ff ff       	call   80051c <syscall>
}
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8006d9:	6a 00                	push   $0x0
  8006db:	6a 00                	push   $0x0
  8006dd:	6a 00                	push   $0x0
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8006ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ef:	e8 28 fe ff ff       	call   80051c <syscall>
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8006fc:	6a 00                	push   $0x0
  8006fe:	ff 75 14             	pushl  0x14(%ebp)
  800701:	ff 75 10             	pushl  0x10(%ebp)
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	ba 00 00 00 00       	mov    $0x0,%edx
  80070f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800714:	e8 03 fe ff ff       	call   80051c <syscall>
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800721:	6a 00                	push   $0x0
  800723:	6a 00                	push   $0x0
  800725:	6a 00                	push   $0x0
  800727:	6a 00                	push   $0x0
  800729:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072c:	ba 01 00 00 00       	mov    $0x1,%edx
  800731:	b8 0d 00 00 00       	mov    $0xd,%eax
  800736:	e8 e1 fd ff ff       	call   80051c <syscall>
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800743:	6a 00                	push   $0x0
  800745:	6a 00                	push   $0x0
  800747:	6a 00                	push   $0x0
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074f:	ba 00 00 00 00       	mov    $0x0,%edx
  800754:	b8 0e 00 00 00       	mov    $0xe,%eax
  800759:	e8 be fd ff ff       	call   80051c <syscall>
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800766:	6a 00                	push   $0x0
  800768:	ff 75 14             	pushl  0x14(%ebp)
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	ff 75 0c             	pushl  0xc(%ebp)
  800771:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800774:	ba 00 00 00 00       	mov    $0x0,%edx
  800779:	b8 0f 00 00 00       	mov    $0xf,%eax
  80077e:	e8 99 fd ff ff       	call   80051c <syscall>
} 
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  80078b:	6a 00                	push   $0x0
  80078d:	6a 00                	push   $0x0
  80078f:	6a 00                	push   $0x0
  800791:	6a 00                	push   $0x0
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	ba 00 00 00 00       	mov    $0x0,%edx
  80079b:	b8 11 00 00 00       	mov    $0x11,%eax
  8007a0:	e8 77 fd ff ff       	call   80051c <syscall>
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  8007ad:	6a 00                	push   $0x0
  8007af:	6a 00                	push   $0x0
  8007b1:	6a 00                	push   $0x0
  8007b3:	6a 00                	push   $0x0
  8007b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c4:	e8 53 fd ff ff       	call   80051c <syscall>
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    
	...

008007cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8007d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 e5 ff ff ff       	call   8007cc <fd2num>
  8007e7:	83 c4 04             	add    $0x4,%esp
  8007ea:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007ef:	c1 e0 0c             	shl    $0xc,%eax
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007fb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800800:	a8 01                	test   $0x1,%al
  800802:	74 34                	je     800838 <fd_alloc+0x44>
  800804:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800809:	a8 01                	test   $0x1,%al
  80080b:	74 32                	je     80083f <fd_alloc+0x4b>
  80080d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800812:	89 c1                	mov    %eax,%ecx
  800814:	89 c2                	mov    %eax,%edx
  800816:	c1 ea 16             	shr    $0x16,%edx
  800819:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800820:	f6 c2 01             	test   $0x1,%dl
  800823:	74 1f                	je     800844 <fd_alloc+0x50>
  800825:	89 c2                	mov    %eax,%edx
  800827:	c1 ea 0c             	shr    $0xc,%edx
  80082a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800831:	f6 c2 01             	test   $0x1,%dl
  800834:	75 17                	jne    80084d <fd_alloc+0x59>
  800836:	eb 0c                	jmp    800844 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800838:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80083d:	eb 05                	jmp    800844 <fd_alloc+0x50>
  80083f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800844:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 17                	jmp    800864 <fd_alloc+0x70>
  80084d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800852:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800857:	75 b9                	jne    800812 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800859:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80085f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80086d:	83 f8 1f             	cmp    $0x1f,%eax
  800870:	77 36                	ja     8008a8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800872:	05 00 00 0d 00       	add    $0xd0000,%eax
  800877:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	c1 ea 16             	shr    $0x16,%edx
  80087f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800886:	f6 c2 01             	test   $0x1,%dl
  800889:	74 24                	je     8008af <fd_lookup+0x48>
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	c1 ea 0c             	shr    $0xc,%edx
  800890:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800897:	f6 c2 01             	test   $0x1,%dl
  80089a:	74 1a                	je     8008b6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 02                	mov    %eax,(%edx)
	return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	eb 13                	jmp    8008bb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ad:	eb 0c                	jmp    8008bb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b4:	eb 05                	jmp    8008bb <fd_lookup+0x54>
  8008b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 04             	sub    $0x4,%esp
  8008c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8008ca:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8008d0:	74 0d                	je     8008df <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb 14                	jmp    8008ed <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8008d9:	39 0a                	cmp    %ecx,(%edx)
  8008db:	75 10                	jne    8008ed <dev_lookup+0x30>
  8008dd:	eb 05                	jmp    8008e4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008df:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8008e4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 31                	jmp    80091e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008ed:	40                   	inc    %eax
  8008ee:	8b 14 85 18 1f 80 00 	mov    0x801f18(,%eax,4),%edx
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	75 e0                	jne    8008d9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8008fe:	8b 40 48             	mov    0x48(%eax),%eax
  800901:	83 ec 04             	sub    $0x4,%esp
  800904:	51                   	push   %ecx
  800905:	50                   	push   %eax
  800906:	68 9c 1e 80 00       	push   $0x801e9c
  80090b:	e8 48 0c 00 00       	call   801558 <cprintf>
	*dev = 0;
  800910:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	83 ec 20             	sub    $0x20,%esp
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8a 45 0c             	mov    0xc(%ebp),%al
  800931:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800934:	56                   	push   %esi
  800935:	e8 92 fe ff ff       	call   8007cc <fd2num>
  80093a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80093d:	89 14 24             	mov    %edx,(%esp)
  800940:	50                   	push   %eax
  800941:	e8 21 ff ff ff       	call   800867 <fd_lookup>
  800946:	89 c3                	mov    %eax,%ebx
  800948:	83 c4 08             	add    $0x8,%esp
  80094b:	85 c0                	test   %eax,%eax
  80094d:	78 05                	js     800954 <fd_close+0x31>
	    || fd != fd2)
  80094f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800952:	74 0d                	je     800961 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800954:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800958:	75 48                	jne    8009a2 <fd_close+0x7f>
  80095a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80095f:	eb 41                	jmp    8009a2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800967:	50                   	push   %eax
  800968:	ff 36                	pushl  (%esi)
  80096a:	e8 4e ff ff ff       	call   8008bd <dev_lookup>
  80096f:	89 c3                	mov    %eax,%ebx
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	85 c0                	test   %eax,%eax
  800976:	78 1c                	js     800994 <fd_close+0x71>
		if (dev->dev_close)
  800978:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097b:	8b 40 10             	mov    0x10(%eax),%eax
  80097e:	85 c0                	test   %eax,%eax
  800980:	74 0d                	je     80098f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800982:	83 ec 0c             	sub    $0xc,%esp
  800985:	56                   	push   %esi
  800986:	ff d0                	call   *%eax
  800988:	89 c3                	mov    %eax,%ebx
  80098a:	83 c4 10             	add    $0x10,%esp
  80098d:	eb 05                	jmp    800994 <fd_close+0x71>
		else
			r = 0;
  80098f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800994:	83 ec 08             	sub    $0x8,%esp
  800997:	56                   	push   %esi
  800998:	6a 00                	push   $0x0
  80099a:	e8 cb fc ff ff       	call   80066a <sys_page_unmap>
	return r;
  80099f:	83 c4 10             	add    $0x10,%esp
}
  8009a2:	89 d8                	mov    %ebx,%eax
  8009a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b4:	50                   	push   %eax
  8009b5:	ff 75 08             	pushl  0x8(%ebp)
  8009b8:	e8 aa fe ff ff       	call   800867 <fd_lookup>
  8009bd:	83 c4 08             	add    $0x8,%esp
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	78 10                	js     8009d4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8009c4:	83 ec 08             	sub    $0x8,%esp
  8009c7:	6a 01                	push   $0x1
  8009c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8009cc:	e8 52 ff ff ff       	call   800923 <fd_close>
  8009d1:	83 c4 10             	add    $0x10,%esp
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <close_all>:

void
close_all(void)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009e2:	83 ec 0c             	sub    $0xc,%esp
  8009e5:	53                   	push   %ebx
  8009e6:	e8 c0 ff ff ff       	call   8009ab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009eb:	43                   	inc    %ebx
  8009ec:	83 c4 10             	add    $0x10,%esp
  8009ef:	83 fb 20             	cmp    $0x20,%ebx
  8009f2:	75 ee                	jne    8009e2 <close_all+0xc>
		close(i);
}
  8009f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 2c             	sub    $0x2c,%esp
  800a02:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a08:	50                   	push   %eax
  800a09:	ff 75 08             	pushl  0x8(%ebp)
  800a0c:	e8 56 fe ff ff       	call   800867 <fd_lookup>
  800a11:	89 c3                	mov    %eax,%ebx
  800a13:	83 c4 08             	add    $0x8,%esp
  800a16:	85 c0                	test   %eax,%eax
  800a18:	0f 88 c0 00 00 00    	js     800ade <dup+0xe5>
		return r;
	close(newfdnum);
  800a1e:	83 ec 0c             	sub    $0xc,%esp
  800a21:	57                   	push   %edi
  800a22:	e8 84 ff ff ff       	call   8009ab <close>

	newfd = INDEX2FD(newfdnum);
  800a27:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a2d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a30:	83 c4 04             	add    $0x4,%esp
  800a33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a36:	e8 a1 fd ff ff       	call   8007dc <fd2data>
  800a3b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a3d:	89 34 24             	mov    %esi,(%esp)
  800a40:	e8 97 fd ff ff       	call   8007dc <fd2data>
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a4b:	89 d8                	mov    %ebx,%eax
  800a4d:	c1 e8 16             	shr    $0x16,%eax
  800a50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a57:	a8 01                	test   $0x1,%al
  800a59:	74 37                	je     800a92 <dup+0x99>
  800a5b:	89 d8                	mov    %ebx,%eax
  800a5d:	c1 e8 0c             	shr    $0xc,%eax
  800a60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a67:	f6 c2 01             	test   $0x1,%dl
  800a6a:	74 26                	je     800a92 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a73:	83 ec 0c             	sub    $0xc,%esp
  800a76:	25 07 0e 00 00       	and    $0xe07,%eax
  800a7b:	50                   	push   %eax
  800a7c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a7f:	6a 00                	push   $0x0
  800a81:	53                   	push   %ebx
  800a82:	6a 00                	push   $0x0
  800a84:	e8 bb fb ff ff       	call   800644 <sys_page_map>
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	83 c4 20             	add    $0x20,%esp
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	78 2d                	js     800abf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	c1 ea 0c             	shr    $0xc,%edx
  800a9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800aa1:	83 ec 0c             	sub    $0xc,%esp
  800aa4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800aaa:	52                   	push   %edx
  800aab:	56                   	push   %esi
  800aac:	6a 00                	push   $0x0
  800aae:	50                   	push   %eax
  800aaf:	6a 00                	push   $0x0
  800ab1:	e8 8e fb ff ff       	call   800644 <sys_page_map>
  800ab6:	89 c3                	mov    %eax,%ebx
  800ab8:	83 c4 20             	add    $0x20,%esp
  800abb:	85 c0                	test   %eax,%eax
  800abd:	79 1d                	jns    800adc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	56                   	push   %esi
  800ac3:	6a 00                	push   $0x0
  800ac5:	e8 a0 fb ff ff       	call   80066a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800aca:	83 c4 08             	add    $0x8,%esp
  800acd:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ad0:	6a 00                	push   $0x0
  800ad2:	e8 93 fb ff ff       	call   80066a <sys_page_unmap>
	return r;
  800ad7:	83 c4 10             	add    $0x10,%esp
  800ada:	eb 02                	jmp    800ade <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800adc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800ade:	89 d8                	mov    %ebx,%eax
  800ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 14             	sub    $0x14,%esp
  800aef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800af2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800af5:	50                   	push   %eax
  800af6:	53                   	push   %ebx
  800af7:	e8 6b fd ff ff       	call   800867 <fd_lookup>
  800afc:	83 c4 08             	add    $0x8,%esp
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 67                	js     800b6a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b09:	50                   	push   %eax
  800b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b0d:	ff 30                	pushl  (%eax)
  800b0f:	e8 a9 fd ff ff       	call   8008bd <dev_lookup>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 4f                	js     800b6a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1e:	8b 50 08             	mov    0x8(%eax),%edx
  800b21:	83 e2 03             	and    $0x3,%edx
  800b24:	83 fa 01             	cmp    $0x1,%edx
  800b27:	75 21                	jne    800b4a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b29:	a1 04 40 80 00       	mov    0x804004,%eax
  800b2e:	8b 40 48             	mov    0x48(%eax),%eax
  800b31:	83 ec 04             	sub    $0x4,%esp
  800b34:	53                   	push   %ebx
  800b35:	50                   	push   %eax
  800b36:	68 dd 1e 80 00       	push   $0x801edd
  800b3b:	e8 18 0a 00 00       	call   801558 <cprintf>
		return -E_INVAL;
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b48:	eb 20                	jmp    800b6a <read+0x82>
	}
	if (!dev->dev_read)
  800b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4d:	8b 52 08             	mov    0x8(%edx),%edx
  800b50:	85 d2                	test   %edx,%edx
  800b52:	74 11                	je     800b65 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b54:	83 ec 04             	sub    $0x4,%esp
  800b57:	ff 75 10             	pushl  0x10(%ebp)
  800b5a:	ff 75 0c             	pushl  0xc(%ebp)
  800b5d:	50                   	push   %eax
  800b5e:	ff d2                	call   *%edx
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	eb 05                	jmp    800b6a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b65:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b7e:	85 f6                	test   %esi,%esi
  800b80:	74 31                	je     800bb3 <readn+0x44>
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b8c:	83 ec 04             	sub    $0x4,%esp
  800b8f:	89 f2                	mov    %esi,%edx
  800b91:	29 c2                	sub    %eax,%edx
  800b93:	52                   	push   %edx
  800b94:	03 45 0c             	add    0xc(%ebp),%eax
  800b97:	50                   	push   %eax
  800b98:	57                   	push   %edi
  800b99:	e8 4a ff ff ff       	call   800ae8 <read>
		if (m < 0)
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	78 17                	js     800bbc <readn+0x4d>
			return m;
		if (m == 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	74 11                	je     800bba <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ba9:	01 c3                	add    %eax,%ebx
  800bab:	89 d8                	mov    %ebx,%eax
  800bad:	39 f3                	cmp    %esi,%ebx
  800baf:	72 db                	jb     800b8c <readn+0x1d>
  800bb1:	eb 09                	jmp    800bbc <readn+0x4d>
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	eb 02                	jmp    800bbc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800bba:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 14             	sub    $0x14,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bd1:	50                   	push   %eax
  800bd2:	53                   	push   %ebx
  800bd3:	e8 8f fc ff ff       	call   800867 <fd_lookup>
  800bd8:	83 c4 08             	add    $0x8,%esp
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	78 62                	js     800c41 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bdf:	83 ec 08             	sub    $0x8,%esp
  800be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be5:	50                   	push   %eax
  800be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be9:	ff 30                	pushl  (%eax)
  800beb:	e8 cd fc ff ff       	call   8008bd <dev_lookup>
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	78 4a                	js     800c41 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bfe:	75 21                	jne    800c21 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c00:	a1 04 40 80 00       	mov    0x804004,%eax
  800c05:	8b 40 48             	mov    0x48(%eax),%eax
  800c08:	83 ec 04             	sub    $0x4,%esp
  800c0b:	53                   	push   %ebx
  800c0c:	50                   	push   %eax
  800c0d:	68 f9 1e 80 00       	push   $0x801ef9
  800c12:	e8 41 09 00 00       	call   801558 <cprintf>
		return -E_INVAL;
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c1f:	eb 20                	jmp    800c41 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c24:	8b 52 0c             	mov    0xc(%edx),%edx
  800c27:	85 d2                	test   %edx,%edx
  800c29:	74 11                	je     800c3c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c2b:	83 ec 04             	sub    $0x4,%esp
  800c2e:	ff 75 10             	pushl  0x10(%ebp)
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	50                   	push   %eax
  800c35:	ff d2                	call   *%edx
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	eb 05                	jmp    800c41 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c4c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c4f:	50                   	push   %eax
  800c50:	ff 75 08             	pushl  0x8(%ebp)
  800c53:	e8 0f fc ff ff       	call   800867 <fd_lookup>
  800c58:	83 c4 08             	add    $0x8,%esp
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	78 0e                	js     800c6d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	83 ec 14             	sub    $0x14,%esp
  800c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c7c:	50                   	push   %eax
  800c7d:	53                   	push   %ebx
  800c7e:	e8 e4 fb ff ff       	call   800867 <fd_lookup>
  800c83:	83 c4 08             	add    $0x8,%esp
  800c86:	85 c0                	test   %eax,%eax
  800c88:	78 5f                	js     800ce9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c8a:	83 ec 08             	sub    $0x8,%esp
  800c8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c90:	50                   	push   %eax
  800c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c94:	ff 30                	pushl  (%eax)
  800c96:	e8 22 fc ff ff       	call   8008bd <dev_lookup>
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	78 47                	js     800ce9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ca9:	75 21                	jne    800ccc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cab:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cb0:	8b 40 48             	mov    0x48(%eax),%eax
  800cb3:	83 ec 04             	sub    $0x4,%esp
  800cb6:	53                   	push   %ebx
  800cb7:	50                   	push   %eax
  800cb8:	68 bc 1e 80 00       	push   $0x801ebc
  800cbd:	e8 96 08 00 00       	call   801558 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cc2:	83 c4 10             	add    $0x10,%esp
  800cc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cca:	eb 1d                	jmp    800ce9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800ccc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ccf:	8b 52 18             	mov    0x18(%edx),%edx
  800cd2:	85 d2                	test   %edx,%edx
  800cd4:	74 0e                	je     800ce4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800cd6:	83 ec 08             	sub    $0x8,%esp
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	50                   	push   %eax
  800cdd:	ff d2                	call   *%edx
  800cdf:	83 c4 10             	add    $0x10,%esp
  800ce2:	eb 05                	jmp    800ce9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800ce4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800ce9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 14             	sub    $0x14,%esp
  800cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cf8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cfb:	50                   	push   %eax
  800cfc:	ff 75 08             	pushl  0x8(%ebp)
  800cff:	e8 63 fb ff ff       	call   800867 <fd_lookup>
  800d04:	83 c4 08             	add    $0x8,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	78 52                	js     800d5d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d11:	50                   	push   %eax
  800d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d15:	ff 30                	pushl  (%eax)
  800d17:	e8 a1 fb ff ff       	call   8008bd <dev_lookup>
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 3a                	js     800d5d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d26:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d2a:	74 2c                	je     800d58 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d2c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d2f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d36:	00 00 00 
	stat->st_isdir = 0;
  800d39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d40:	00 00 00 
	stat->st_dev = dev;
  800d43:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d49:	83 ec 08             	sub    $0x8,%esp
  800d4c:	53                   	push   %ebx
  800d4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d50:	ff 50 14             	call   *0x14(%eax)
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	eb 05                	jmp    800d5d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d58:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d67:	83 ec 08             	sub    $0x8,%esp
  800d6a:	6a 00                	push   $0x0
  800d6c:	ff 75 08             	pushl  0x8(%ebp)
  800d6f:	e8 78 01 00 00       	call   800eec <open>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 1b                	js     800d98 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d7d:	83 ec 08             	sub    $0x8,%esp
  800d80:	ff 75 0c             	pushl  0xc(%ebp)
  800d83:	50                   	push   %eax
  800d84:	e8 65 ff ff ff       	call   800cee <fstat>
  800d89:	89 c6                	mov    %eax,%esi
	close(fd);
  800d8b:	89 1c 24             	mov    %ebx,(%esp)
  800d8e:	e8 18 fc ff ff       	call   8009ab <close>
	return r;
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	89 f3                	mov    %esi,%ebx
}
  800d98:	89 d8                	mov    %ebx,%eax
  800d9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    
  800da1:	00 00                	add    %al,(%eax)
	...

00800da4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800db4:	75 12                	jne    800dc8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	6a 01                	push   $0x1
  800dbb:	e8 c6 0d 00 00       	call   801b86 <ipc_find_env>
  800dc0:	a3 00 40 80 00       	mov    %eax,0x804000
  800dc5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800dc8:	6a 07                	push   $0x7
  800dca:	68 00 50 80 00       	push   $0x805000
  800dcf:	53                   	push   %ebx
  800dd0:	ff 35 00 40 80 00    	pushl  0x804000
  800dd6:	e8 56 0d 00 00       	call   801b31 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800ddb:	83 c4 0c             	add    $0xc,%esp
  800dde:	6a 00                	push   $0x0
  800de0:	56                   	push   %esi
  800de1:	6a 00                	push   $0x0
  800de3:	e8 d4 0c 00 00       	call   801abc <ipc_recv>
}
  800de8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    

00800def <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	53                   	push   %ebx
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0e:	e8 91 ff ff ff       	call   800da4 <fsipc>
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 2c                	js     800e43 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	68 00 50 80 00       	push   $0x805000
  800e1f:	53                   	push   %ebx
  800e20:	e8 79 f3 ff ff       	call   80019e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e25:	a1 80 50 80 00       	mov    0x805080,%eax
  800e2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e30:	a1 84 50 80 00       	mov    0x805084,%eax
  800e35:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	8b 40 0c             	mov    0xc(%eax),%eax
  800e54:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e63:	e8 3c ff ff ff       	call   800da4 <fsipc>
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	8b 40 0c             	mov    0xc(%eax),%eax
  800e78:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e7d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8d:	e8 12 ff ff ff       	call   800da4 <fsipc>
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 4b                	js     800ee3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e98:	39 c6                	cmp    %eax,%esi
  800e9a:	73 16                	jae    800eb2 <devfile_read+0x48>
  800e9c:	68 28 1f 80 00       	push   $0x801f28
  800ea1:	68 2f 1f 80 00       	push   $0x801f2f
  800ea6:	6a 7d                	push   $0x7d
  800ea8:	68 44 1f 80 00       	push   $0x801f44
  800ead:	e8 ce 05 00 00       	call   801480 <_panic>
	assert(r <= PGSIZE);
  800eb2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800eb7:	7e 16                	jle    800ecf <devfile_read+0x65>
  800eb9:	68 4f 1f 80 00       	push   $0x801f4f
  800ebe:	68 2f 1f 80 00       	push   $0x801f2f
  800ec3:	6a 7e                	push   $0x7e
  800ec5:	68 44 1f 80 00       	push   $0x801f44
  800eca:	e8 b1 05 00 00       	call   801480 <_panic>
	memmove(buf, &fsipcbuf, r);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	50                   	push   %eax
  800ed3:	68 00 50 80 00       	push   $0x805000
  800ed8:	ff 75 0c             	pushl  0xc(%ebp)
  800edb:	e8 7f f4 ff ff       	call   80035f <memmove>
	return r;
  800ee0:	83 c4 10             	add    $0x10,%esp
}
  800ee3:	89 d8                	mov    %ebx,%eax
  800ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 1c             	sub    $0x1c,%esp
  800ef4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ef7:	56                   	push   %esi
  800ef8:	e8 4f f2 ff ff       	call   80014c <strlen>
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f05:	7f 65                	jg     800f6c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	e8 e1 f8 ff ff       	call   8007f4 <fd_alloc>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 55                	js     800f71 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	56                   	push   %esi
  800f20:	68 00 50 80 00       	push   $0x805000
  800f25:	e8 74 f2 ff ff       	call   80019e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f35:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3a:	e8 65 fe ff ff       	call   800da4 <fsipc>
  800f3f:	89 c3                	mov    %eax,%ebx
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 12                	jns    800f5a <open+0x6e>
		fd_close(fd, 0);
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	6a 00                	push   $0x0
  800f4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f50:	e8 ce f9 ff ff       	call   800923 <fd_close>
		return r;
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	eb 17                	jmp    800f71 <open+0x85>
	}

	return fd2num(fd);
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f60:	e8 67 f8 ff ff       	call   8007cc <fd2num>
  800f65:	89 c3                	mov    %eax,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	eb 05                	jmp    800f71 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f6c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    
	...

00800f7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
  800f81:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	ff 75 08             	pushl  0x8(%ebp)
  800f8a:	e8 4d f8 ff ff       	call   8007dc <fd2data>
  800f8f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	68 5b 1f 80 00       	push   $0x801f5b
  800f99:	56                   	push   %esi
  800f9a:	e8 ff f1 ff ff       	call   80019e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f9f:	8b 43 04             	mov    0x4(%ebx),%eax
  800fa2:	2b 03                	sub    (%ebx),%eax
  800fa4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800faa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800fb1:	00 00 00 
	stat->st_dev = &devpipe;
  800fb4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800fbb:	30 80 00 
	return 0;
}
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fd4:	53                   	push   %ebx
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 8e f6 ff ff       	call   80066a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fdc:	89 1c 24             	mov    %ebx,(%esp)
  800fdf:	e8 f8 f7 ff ff       	call   8007dc <fd2data>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	50                   	push   %eax
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 7b f6 ff ff       	call   80066a <sys_page_unmap>
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 1c             	sub    $0x1c,%esp
  800ffd:	89 c7                	mov    %eax,%edi
  800fff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801002:	a1 04 40 80 00       	mov    0x804004,%eax
  801007:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	57                   	push   %edi
  80100e:	e8 c1 0b 00 00       	call   801bd4 <pageref>
  801013:	89 c6                	mov    %eax,%esi
  801015:	83 c4 04             	add    $0x4,%esp
  801018:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101b:	e8 b4 0b 00 00       	call   801bd4 <pageref>
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	39 c6                	cmp    %eax,%esi
  801025:	0f 94 c0             	sete   %al
  801028:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80102b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801031:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801034:	39 cb                	cmp    %ecx,%ebx
  801036:	75 08                	jne    801040 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801038:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801040:	83 f8 01             	cmp    $0x1,%eax
  801043:	75 bd                	jne    801002 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801045:	8b 42 58             	mov    0x58(%edx),%eax
  801048:	6a 01                	push   $0x1
  80104a:	50                   	push   %eax
  80104b:	53                   	push   %ebx
  80104c:	68 62 1f 80 00       	push   $0x801f62
  801051:	e8 02 05 00 00       	call   801558 <cprintf>
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	eb a7                	jmp    801002 <_pipeisclosed+0xe>

0080105b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 28             	sub    $0x28,%esp
  801064:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801067:	56                   	push   %esi
  801068:	e8 6f f7 ff ff       	call   8007dc <fd2data>
  80106d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801076:	75 4a                	jne    8010c2 <devpipe_write+0x67>
  801078:	bf 00 00 00 00       	mov    $0x0,%edi
  80107d:	eb 56                	jmp    8010d5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80107f:	89 da                	mov    %ebx,%edx
  801081:	89 f0                	mov    %esi,%eax
  801083:	e8 6c ff ff ff       	call   800ff4 <_pipeisclosed>
  801088:	85 c0                	test   %eax,%eax
  80108a:	75 4d                	jne    8010d9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80108c:	e8 68 f5 ff ff       	call   8005f9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801091:	8b 43 04             	mov    0x4(%ebx),%eax
  801094:	8b 13                	mov    (%ebx),%edx
  801096:	83 c2 20             	add    $0x20,%edx
  801099:	39 d0                	cmp    %edx,%eax
  80109b:	73 e2                	jae    80107f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80109d:	89 c2                	mov    %eax,%edx
  80109f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8010a5:	79 05                	jns    8010ac <devpipe_write+0x51>
  8010a7:	4a                   	dec    %edx
  8010a8:	83 ca e0             	or     $0xffffffe0,%edx
  8010ab:	42                   	inc    %edx
  8010ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010af:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8010b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010b6:	40                   	inc    %eax
  8010b7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ba:	47                   	inc    %edi
  8010bb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8010be:	77 07                	ja     8010c7 <devpipe_write+0x6c>
  8010c0:	eb 13                	jmp    8010d5 <devpipe_write+0x7a>
  8010c2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ca:	8b 13                	mov    (%ebx),%edx
  8010cc:	83 c2 20             	add    $0x20,%edx
  8010cf:	39 d0                	cmp    %edx,%eax
  8010d1:	73 ac                	jae    80107f <devpipe_write+0x24>
  8010d3:	eb c8                	jmp    80109d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010d5:	89 f8                	mov    %edi,%eax
  8010d7:	eb 05                	jmp    8010de <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 18             	sub    $0x18,%esp
  8010ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010f2:	57                   	push   %edi
  8010f3:	e8 e4 f6 ff ff       	call   8007dc <fd2data>
  8010f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801101:	75 44                	jne    801147 <devpipe_read+0x61>
  801103:	be 00 00 00 00       	mov    $0x0,%esi
  801108:	eb 4f                	jmp    801159 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	eb 54                	jmp    801162 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80110e:	89 da                	mov    %ebx,%edx
  801110:	89 f8                	mov    %edi,%eax
  801112:	e8 dd fe ff ff       	call   800ff4 <_pipeisclosed>
  801117:	85 c0                	test   %eax,%eax
  801119:	75 42                	jne    80115d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80111b:	e8 d9 f4 ff ff       	call   8005f9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801120:	8b 03                	mov    (%ebx),%eax
  801122:	3b 43 04             	cmp    0x4(%ebx),%eax
  801125:	74 e7                	je     80110e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801127:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80112c:	79 05                	jns    801133 <devpipe_read+0x4d>
  80112e:	48                   	dec    %eax
  80112f:	83 c8 e0             	or     $0xffffffe0,%eax
  801132:	40                   	inc    %eax
  801133:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80113d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80113f:	46                   	inc    %esi
  801140:	39 75 10             	cmp    %esi,0x10(%ebp)
  801143:	77 07                	ja     80114c <devpipe_read+0x66>
  801145:	eb 12                	jmp    801159 <devpipe_read+0x73>
  801147:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80114c:	8b 03                	mov    (%ebx),%eax
  80114e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801151:	75 d4                	jne    801127 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801153:	85 f6                	test   %esi,%esi
  801155:	75 b3                	jne    80110a <devpipe_read+0x24>
  801157:	eb b5                	jmp    80110e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801159:	89 f0                	mov    %esi,%eax
  80115b:	eb 05                	jmp    801162 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 28             	sub    $0x28,%esp
  801173:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801176:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	e8 75 f6 ff ff       	call   8007f4 <fd_alloc>
  80117f:	89 c3                	mov    %eax,%ebx
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	0f 88 24 01 00 00    	js     8012b0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	68 07 04 00 00       	push   $0x407
  801194:	ff 75 e4             	pushl  -0x1c(%ebp)
  801197:	6a 00                	push   $0x0
  801199:	e8 82 f4 ff ff       	call   800620 <sys_page_alloc>
  80119e:	89 c3                	mov    %eax,%ebx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	0f 88 05 01 00 00    	js     8012b0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	e8 3d f6 ff ff       	call   8007f4 <fd_alloc>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	0f 88 dc 00 00 00    	js     8012a0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	68 07 04 00 00       	push   $0x407
  8011cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cf:	6a 00                	push   $0x0
  8011d1:	e8 4a f4 ff ff       	call   800620 <sys_page_alloc>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 bd 00 00 00    	js     8012a0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e9:	e8 ee f5 ff ff       	call   8007dc <fd2data>
  8011ee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f0:	83 c4 0c             	add    $0xc,%esp
  8011f3:	68 07 04 00 00       	push   $0x407
  8011f8:	50                   	push   %eax
  8011f9:	6a 00                	push   $0x0
  8011fb:	e8 20 f4 ff ff       	call   800620 <sys_page_alloc>
  801200:	89 c3                	mov    %eax,%ebx
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	0f 88 83 00 00 00    	js     801290 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	ff 75 e0             	pushl  -0x20(%ebp)
  801213:	e8 c4 f5 ff ff       	call   8007dc <fd2data>
  801218:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80121f:	50                   	push   %eax
  801220:	6a 00                	push   $0x0
  801222:	56                   	push   %esi
  801223:	6a 00                	push   $0x0
  801225:	e8 1a f4 ff ff       	call   800644 <sys_page_map>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 20             	add    $0x20,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 4f                	js     801282 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801233:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80123e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801241:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801248:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80124e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801251:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801253:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801256:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	ff 75 e4             	pushl  -0x1c(%ebp)
  801263:	e8 64 f5 ff ff       	call   8007cc <fd2num>
  801268:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80126a:	83 c4 04             	add    $0x4,%esp
  80126d:	ff 75 e0             	pushl  -0x20(%ebp)
  801270:	e8 57 f5 ff ff       	call   8007cc <fd2num>
  801275:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801280:	eb 2e                	jmp    8012b0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	56                   	push   %esi
  801286:	6a 00                	push   $0x0
  801288:	e8 dd f3 ff ff       	call   80066a <sys_page_unmap>
  80128d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	ff 75 e0             	pushl  -0x20(%ebp)
  801296:	6a 00                	push   $0x0
  801298:	e8 cd f3 ff ff       	call   80066a <sys_page_unmap>
  80129d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 bd f3 ff ff       	call   80066a <sys_page_unmap>
  8012ad:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 08             	pushl  0x8(%ebp)
  8012c7:	e8 9b f5 ff ff       	call   800867 <fd_lookup>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 18                	js     8012eb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d9:	e8 fe f4 ff ff       	call   8007dc <fd2data>
	return _pipeisclosed(fd, p);
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e3:	e8 0c fd ff ff       	call   800ff4 <_pipeisclosed>
  8012e8:	83 c4 10             	add    $0x10,%esp
}
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    
  8012ed:	00 00                	add    %al,(%eax)
	...

008012f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801300:	68 7a 1f 80 00       	push   $0x801f7a
  801305:	ff 75 0c             	pushl  0xc(%ebp)
  801308:	e8 91 ee ff ff       	call   80019e <strcpy>
	return 0;
}
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	57                   	push   %edi
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801324:	74 45                	je     80136b <devcons_write+0x57>
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801330:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801336:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801339:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80133b:	83 fb 7f             	cmp    $0x7f,%ebx
  80133e:	76 05                	jbe    801345 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801340:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801345:	83 ec 04             	sub    $0x4,%esp
  801348:	53                   	push   %ebx
  801349:	03 45 0c             	add    0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	57                   	push   %edi
  80134e:	e8 0c f0 ff ff       	call   80035f <memmove>
		sys_cputs(buf, m);
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	53                   	push   %ebx
  801357:	57                   	push   %edi
  801358:	e8 0c f2 ff ff       	call   800569 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80135d:	01 de                	add    %ebx,%esi
  80135f:	89 f0                	mov    %esi,%eax
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	3b 75 10             	cmp    0x10(%ebp),%esi
  801367:	72 cd                	jb     801336 <devcons_write+0x22>
  801369:	eb 05                	jmp    801370 <devcons_write+0x5c>
  80136b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801370:	89 f0                	mov    %esi,%eax
  801372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5f                   	pop    %edi
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801380:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801384:	75 07                	jne    80138d <devcons_read+0x13>
  801386:	eb 25                	jmp    8013ad <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801388:	e8 6c f2 ff ff       	call   8005f9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80138d:	e8 fd f1 ff ff       	call   80058f <sys_cgetc>
  801392:	85 c0                	test   %eax,%eax
  801394:	74 f2                	je     801388 <devcons_read+0xe>
  801396:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 1d                	js     8013b9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80139c:	83 f8 04             	cmp    $0x4,%eax
  80139f:	74 13                	je     8013b4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	88 10                	mov    %dl,(%eax)
	return 1;
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	eb 0c                	jmp    8013b9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	eb 05                	jmp    8013b9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013b4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013c7:	6a 01                	push   $0x1
  8013c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	e8 97 f1 ff ff       	call   800569 <sys_cputs>
  8013d2:	83 c4 10             	add    $0x10,%esp
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <getchar>:

int
getchar(void)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013dd:	6a 01                	push   $0x1
  8013df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 fe f6 ff ff       	call   800ae8 <read>
	if (r < 0)
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 0f                	js     801400 <getchar+0x29>
		return r;
	if (r < 1)
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	7e 06                	jle    8013fb <getchar+0x24>
		return -E_EOF;
	return c;
  8013f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013f9:	eb 05                	jmp    801400 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013fb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801400:	c9                   	leave  
  801401:	c3                   	ret    

00801402 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	ff 75 08             	pushl  0x8(%ebp)
  80140f:	e8 53 f4 ff ff       	call   800867 <fd_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 11                	js     80142c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801424:	39 10                	cmp    %edx,(%eax)
  801426:	0f 94 c0             	sete   %al
  801429:	0f b6 c0             	movzbl %al,%eax
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <opencons>:

int
opencons(void)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801434:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	e8 b7 f3 ff ff       	call   8007f4 <fd_alloc>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 3a                	js     80147e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	68 07 04 00 00       	push   $0x407
  80144c:	ff 75 f4             	pushl  -0xc(%ebp)
  80144f:	6a 00                	push   $0x0
  801451:	e8 ca f1 ff ff       	call   800620 <sys_page_alloc>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 21                	js     80147e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80145d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	50                   	push   %eax
  801476:	e8 51 f3 ff ff       	call   8007cc <fd2num>
  80147b:	83 c4 10             	add    $0x10,%esp
}
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801485:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801488:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80148e:	e8 42 f1 ff ff       	call   8005d5 <sys_getenvid>
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	ff 75 0c             	pushl  0xc(%ebp)
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	53                   	push   %ebx
  80149d:	50                   	push   %eax
  80149e:	68 88 1f 80 00       	push   $0x801f88
  8014a3:	e8 b0 00 00 00       	call   801558 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014a8:	83 c4 18             	add    $0x18,%esp
  8014ab:	56                   	push   %esi
  8014ac:	ff 75 10             	pushl  0x10(%ebp)
  8014af:	e8 53 00 00 00       	call   801507 <vcprintf>
	cprintf("\n");
  8014b4:	c7 04 24 73 1f 80 00 	movl   $0x801f73,(%esp)
  8014bb:	e8 98 00 00 00       	call   801558 <cprintf>
  8014c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014c3:	cc                   	int3   
  8014c4:	eb fd                	jmp    8014c3 <_panic+0x43>
	...

008014c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014d2:	8b 03                	mov    (%ebx),%eax
  8014d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8014db:	40                   	inc    %eax
  8014dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8014de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014e3:	75 1a                	jne    8014ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	68 ff 00 00 00       	push   $0xff
  8014ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8014f0:	50                   	push   %eax
  8014f1:	e8 73 f0 ff ff       	call   800569 <sys_cputs>
		b->idx = 0;
  8014f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014ff:	ff 43 04             	incl   0x4(%ebx)
}
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801510:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801517:	00 00 00 
	b.cnt = 0;
  80151a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801521:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	ff 75 08             	pushl  0x8(%ebp)
  80152a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	68 c8 14 80 00       	push   $0x8014c8
  801536:	e8 82 01 00 00       	call   8016bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801544:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	e8 19 f0 ff ff       	call   800569 <sys_cputs>

	return b.cnt;
}
  801550:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80155e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801561:	50                   	push   %eax
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 9d ff ff ff       	call   801507 <vcprintf>
	va_end(ap);

	return cnt;
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	57                   	push   %edi
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	83 ec 2c             	sub    $0x2c,%esp
  801575:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801578:	89 d6                	mov    %edx,%esi
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801586:	8b 45 10             	mov    0x10(%ebp),%eax
  801589:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80158c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80158f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801592:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801599:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80159c:	72 0c                	jb     8015aa <printnum+0x3e>
  80159e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8015a1:	76 07                	jbe    8015aa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015a3:	4b                   	dec    %ebx
  8015a4:	85 db                	test   %ebx,%ebx
  8015a6:	7f 31                	jg     8015d9 <printnum+0x6d>
  8015a8:	eb 3f                	jmp    8015e9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	57                   	push   %edi
  8015ae:	4b                   	dec    %ebx
  8015af:	53                   	push   %ebx
  8015b0:	50                   	push   %eax
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8015ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8015bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8015c0:	e8 53 06 00 00       	call   801c18 <__udivdi3>
  8015c5:	83 c4 18             	add    $0x18,%esp
  8015c8:	52                   	push   %edx
  8015c9:	50                   	push   %eax
  8015ca:	89 f2                	mov    %esi,%edx
  8015cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cf:	e8 98 ff ff ff       	call   80156c <printnum>
  8015d4:	83 c4 20             	add    $0x20,%esp
  8015d7:	eb 10                	jmp    8015e9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	56                   	push   %esi
  8015dd:	57                   	push   %edi
  8015de:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015e1:	4b                   	dec    %ebx
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 db                	test   %ebx,%ebx
  8015e7:	7f f0                	jg     8015d9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	56                   	push   %esi
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8015f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8015fc:	e8 33 07 00 00       	call   801d34 <__umoddi3>
  801601:	83 c4 14             	add    $0x14,%esp
  801604:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
  80160b:	50                   	push   %eax
  80160c:	ff 55 e4             	call   *-0x1c(%ebp)
  80160f:	83 c4 10             	add    $0x10,%esp
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80161d:	83 fa 01             	cmp    $0x1,%edx
  801620:	7e 0e                	jle    801630 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801622:	8b 10                	mov    (%eax),%edx
  801624:	8d 4a 08             	lea    0x8(%edx),%ecx
  801627:	89 08                	mov    %ecx,(%eax)
  801629:	8b 02                	mov    (%edx),%eax
  80162b:	8b 52 04             	mov    0x4(%edx),%edx
  80162e:	eb 22                	jmp    801652 <getuint+0x38>
	else if (lflag)
  801630:	85 d2                	test   %edx,%edx
  801632:	74 10                	je     801644 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801634:	8b 10                	mov    (%eax),%edx
  801636:	8d 4a 04             	lea    0x4(%edx),%ecx
  801639:	89 08                	mov    %ecx,(%eax)
  80163b:	8b 02                	mov    (%edx),%eax
  80163d:	ba 00 00 00 00       	mov    $0x0,%edx
  801642:	eb 0e                	jmp    801652 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801644:	8b 10                	mov    (%eax),%edx
  801646:	8d 4a 04             	lea    0x4(%edx),%ecx
  801649:	89 08                	mov    %ecx,(%eax)
  80164b:	8b 02                	mov    (%edx),%eax
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801657:	83 fa 01             	cmp    $0x1,%edx
  80165a:	7e 0e                	jle    80166a <getint+0x16>
		return va_arg(*ap, long long);
  80165c:	8b 10                	mov    (%eax),%edx
  80165e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801661:	89 08                	mov    %ecx,(%eax)
  801663:	8b 02                	mov    (%edx),%eax
  801665:	8b 52 04             	mov    0x4(%edx),%edx
  801668:	eb 1a                	jmp    801684 <getint+0x30>
	else if (lflag)
  80166a:	85 d2                	test   %edx,%edx
  80166c:	74 0c                	je     80167a <getint+0x26>
		return va_arg(*ap, long);
  80166e:	8b 10                	mov    (%eax),%edx
  801670:	8d 4a 04             	lea    0x4(%edx),%ecx
  801673:	89 08                	mov    %ecx,(%eax)
  801675:	8b 02                	mov    (%edx),%eax
  801677:	99                   	cltd   
  801678:	eb 0a                	jmp    801684 <getint+0x30>
	else
		return va_arg(*ap, int);
  80167a:	8b 10                	mov    (%eax),%edx
  80167c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80167f:	89 08                	mov    %ecx,(%eax)
  801681:	8b 02                	mov    (%edx),%eax
  801683:	99                   	cltd   
}
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80168c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80168f:	8b 10                	mov    (%eax),%edx
  801691:	3b 50 04             	cmp    0x4(%eax),%edx
  801694:	73 08                	jae    80169e <sprintputch+0x18>
		*b->buf++ = ch;
  801696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801699:	88 0a                	mov    %cl,(%edx)
  80169b:	42                   	inc    %edx
  80169c:	89 10                	mov    %edx,(%eax)
}
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 10             	pushl  0x10(%ebp)
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	ff 75 08             	pushl  0x8(%ebp)
  8016b3:	e8 05 00 00 00       	call   8016bd <vprintfmt>
	va_end(ap);
  8016b8:	83 c4 10             	add    $0x10,%esp
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 2c             	sub    $0x2c,%esp
  8016c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8016cc:	eb 13                	jmp    8016e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 84 6d 03 00 00    	je     801a43 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	57                   	push   %edi
  8016da:	50                   	push   %eax
  8016db:	ff 55 08             	call   *0x8(%ebp)
  8016de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e1:	0f b6 06             	movzbl (%esi),%eax
  8016e4:	46                   	inc    %esi
  8016e5:	83 f8 25             	cmp    $0x25,%eax
  8016e8:	75 e4                	jne    8016ce <vprintfmt+0x11>
  8016ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8016ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8016f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8016fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801703:	b9 00 00 00 00       	mov    $0x0,%ecx
  801708:	eb 28                	jmp    801732 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80170c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  801710:	eb 20                	jmp    801732 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801712:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801714:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  801718:	eb 18                	jmp    801732 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80171c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801723:	eb 0d                	jmp    801732 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801725:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801728:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801732:	8a 06                	mov    (%esi),%al
  801734:	0f b6 d0             	movzbl %al,%edx
  801737:	8d 5e 01             	lea    0x1(%esi),%ebx
  80173a:	83 e8 23             	sub    $0x23,%eax
  80173d:	3c 55                	cmp    $0x55,%al
  80173f:	0f 87 e0 02 00 00    	ja     801a25 <vprintfmt+0x368>
  801745:	0f b6 c0             	movzbl %al,%eax
  801748:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80174f:	83 ea 30             	sub    $0x30,%edx
  801752:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  801755:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  801758:	8d 50 d0             	lea    -0x30(%eax),%edx
  80175b:	83 fa 09             	cmp    $0x9,%edx
  80175e:	77 44                	ja     8017a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801760:	89 de                	mov    %ebx,%esi
  801762:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801765:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801766:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801769:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80176d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801770:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801773:	83 fb 09             	cmp    $0x9,%ebx
  801776:	76 ed                	jbe    801765 <vprintfmt+0xa8>
  801778:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80177b:	eb 29                	jmp    8017a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80177d:	8b 45 14             	mov    0x14(%ebp),%eax
  801780:	8d 50 04             	lea    0x4(%eax),%edx
  801783:	89 55 14             	mov    %edx,0x14(%ebp)
  801786:	8b 00                	mov    (%eax),%eax
  801788:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80178d:	eb 17                	jmp    8017a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80178f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801793:	78 85                	js     80171a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801795:	89 de                	mov    %ebx,%esi
  801797:	eb 99                	jmp    801732 <vprintfmt+0x75>
  801799:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80179b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8017a2:	eb 8e                	jmp    801732 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8017a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8017aa:	79 86                	jns    801732 <vprintfmt+0x75>
  8017ac:	e9 74 ff ff ff       	jmp    801725 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b2:	89 de                	mov    %ebx,%esi
  8017b4:	e9 79 ff ff ff       	jmp    801732 <vprintfmt+0x75>
  8017b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bf:	8d 50 04             	lea    0x4(%eax),%edx
  8017c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	57                   	push   %edi
  8017c9:	ff 30                	pushl  (%eax)
  8017cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d4:	e9 08 ff ff ff       	jmp    8016e1 <vprintfmt+0x24>
  8017d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017df:	8d 50 04             	lea    0x4(%eax),%edx
  8017e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e5:	8b 00                	mov    (%eax),%eax
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	79 02                	jns    8017ed <vprintfmt+0x130>
  8017eb:	f7 d8                	neg    %eax
  8017ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ef:	83 f8 0f             	cmp    $0xf,%eax
  8017f2:	7f 0b                	jg     8017ff <vprintfmt+0x142>
  8017f4:	8b 04 85 40 22 80 00 	mov    0x802240(,%eax,4),%eax
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	75 1a                	jne    801819 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8017ff:	52                   	push   %edx
  801800:	68 c3 1f 80 00       	push   $0x801fc3
  801805:	57                   	push   %edi
  801806:	ff 75 08             	pushl  0x8(%ebp)
  801809:	e8 92 fe ff ff       	call   8016a0 <printfmt>
  80180e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801811:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801814:	e9 c8 fe ff ff       	jmp    8016e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  801819:	50                   	push   %eax
  80181a:	68 41 1f 80 00       	push   $0x801f41
  80181f:	57                   	push   %edi
  801820:	ff 75 08             	pushl  0x8(%ebp)
  801823:	e8 78 fe ff ff       	call   8016a0 <printfmt>
  801828:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80182e:	e9 ae fe ff ff       	jmp    8016e1 <vprintfmt+0x24>
  801833:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801836:	89 de                	mov    %ebx,%esi
  801838:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80183b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80183e:	8b 45 14             	mov    0x14(%ebp),%eax
  801841:	8d 50 04             	lea    0x4(%eax),%edx
  801844:	89 55 14             	mov    %edx,0x14(%ebp)
  801847:	8b 00                	mov    (%eax),%eax
  801849:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80184c:	85 c0                	test   %eax,%eax
  80184e:	75 07                	jne    801857 <vprintfmt+0x19a>
				p = "(null)";
  801850:	c7 45 d0 bc 1f 80 00 	movl   $0x801fbc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  801857:	85 db                	test   %ebx,%ebx
  801859:	7e 42                	jle    80189d <vprintfmt+0x1e0>
  80185b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80185f:	74 3c                	je     80189d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	51                   	push   %ecx
  801865:	ff 75 d0             	pushl  -0x30(%ebp)
  801868:	e8 ff e8 ff ff       	call   80016c <strnlen>
  80186d:	29 c3                	sub    %eax,%ebx
  80186f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 db                	test   %ebx,%ebx
  801877:	7e 24                	jle    80189d <vprintfmt+0x1e0>
					putch(padc, putdat);
  801879:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80187d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  801880:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	57                   	push   %edi
  801887:	53                   	push   %ebx
  801888:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188b:	4e                   	dec    %esi
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 f6                	test   %esi,%esi
  801891:	7f f0                	jg     801883 <vprintfmt+0x1c6>
  801893:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801896:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80189d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8018a0:	0f be 02             	movsbl (%edx),%eax
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	75 47                	jne    8018ee <vprintfmt+0x231>
  8018a7:	eb 37                	jmp    8018e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ad:	74 16                	je     8018c5 <vprintfmt+0x208>
  8018af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8018b2:	83 fa 5e             	cmp    $0x5e,%edx
  8018b5:	76 0e                	jbe    8018c5 <vprintfmt+0x208>
					putch('?', putdat);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	57                   	push   %edi
  8018bb:	6a 3f                	push   $0x3f
  8018bd:	ff 55 08             	call   *0x8(%ebp)
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	eb 0b                	jmp    8018d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	57                   	push   %edi
  8018c9:	50                   	push   %eax
  8018ca:	ff 55 08             	call   *0x8(%ebp)
  8018cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8018d3:	0f be 03             	movsbl (%ebx),%eax
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	74 03                	je     8018dd <vprintfmt+0x220>
  8018da:	43                   	inc    %ebx
  8018db:	eb 1b                	jmp    8018f8 <vprintfmt+0x23b>
  8018dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018e4:	7f 1e                	jg     801904 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8018e9:	e9 f3 fd ff ff       	jmp    8016e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8018f1:	43                   	inc    %ebx
  8018f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8018f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8018f8:	85 f6                	test   %esi,%esi
  8018fa:	78 ad                	js     8018a9 <vprintfmt+0x1ec>
  8018fc:	4e                   	dec    %esi
  8018fd:	79 aa                	jns    8018a9 <vprintfmt+0x1ec>
  8018ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801902:	eb dc                	jmp    8018e0 <vprintfmt+0x223>
  801904:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	57                   	push   %edi
  80190b:	6a 20                	push   $0x20
  80190d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801910:	4b                   	dec    %ebx
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 db                	test   %ebx,%ebx
  801916:	7f ef                	jg     801907 <vprintfmt+0x24a>
  801918:	e9 c4 fd ff ff       	jmp    8016e1 <vprintfmt+0x24>
  80191d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801920:	89 ca                	mov    %ecx,%edx
  801922:	8d 45 14             	lea    0x14(%ebp),%eax
  801925:	e8 2a fd ff ff       	call   801654 <getint>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80192e:	85 d2                	test   %edx,%edx
  801930:	78 0a                	js     80193c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801932:	b8 0a 00 00 00       	mov    $0xa,%eax
  801937:	e9 b0 00 00 00       	jmp    8019ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	57                   	push   %edi
  801940:	6a 2d                	push   $0x2d
  801942:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801945:	f7 db                	neg    %ebx
  801947:	83 d6 00             	adc    $0x0,%esi
  80194a:	f7 de                	neg    %esi
  80194c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80194f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801954:	e9 93 00 00 00       	jmp    8019ec <vprintfmt+0x32f>
  801959:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80195c:	89 ca                	mov    %ecx,%edx
  80195e:	8d 45 14             	lea    0x14(%ebp),%eax
  801961:	e8 b4 fc ff ff       	call   80161a <getuint>
  801966:	89 c3                	mov    %eax,%ebx
  801968:	89 d6                	mov    %edx,%esi
			base = 10;
  80196a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80196f:	eb 7b                	jmp    8019ec <vprintfmt+0x32f>
  801971:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  801974:	89 ca                	mov    %ecx,%edx
  801976:	8d 45 14             	lea    0x14(%ebp),%eax
  801979:	e8 d6 fc ff ff       	call   801654 <getint>
  80197e:	89 c3                	mov    %eax,%ebx
  801980:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  801982:	85 d2                	test   %edx,%edx
  801984:	78 07                	js     80198d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  801986:	b8 08 00 00 00       	mov    $0x8,%eax
  80198b:	eb 5f                	jmp    8019ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	57                   	push   %edi
  801991:	6a 2d                	push   $0x2d
  801993:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  801996:	f7 db                	neg    %ebx
  801998:	83 d6 00             	adc    $0x0,%esi
  80199b:	f7 de                	neg    %esi
  80199d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8019a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a5:	eb 45                	jmp    8019ec <vprintfmt+0x32f>
  8019a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	57                   	push   %edi
  8019ae:	6a 30                	push   $0x30
  8019b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8019b3:	83 c4 08             	add    $0x8,%esp
  8019b6:	57                   	push   %edi
  8019b7:	6a 78                	push   $0x78
  8019b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bf:	8d 50 04             	lea    0x4(%eax),%edx
  8019c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019c5:	8b 18                	mov    (%eax),%ebx
  8019c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8019d4:	eb 16                	jmp    8019ec <vprintfmt+0x32f>
  8019d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019d9:	89 ca                	mov    %ecx,%edx
  8019db:	8d 45 14             	lea    0x14(%ebp),%eax
  8019de:	e8 37 fc ff ff       	call   80161a <getuint>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	89 d6                	mov    %edx,%esi
			base = 16;
  8019e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019ec:	83 ec 0c             	sub    $0xc,%esp
  8019ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8019f3:	52                   	push   %edx
  8019f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f7:	50                   	push   %eax
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	89 fa                	mov    %edi,%edx
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	e8 68 fb ff ff       	call   80156c <printnum>
			break;
  801a04:	83 c4 20             	add    $0x20,%esp
  801a07:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801a0a:	e9 d2 fc ff ff       	jmp    8016e1 <vprintfmt+0x24>
  801a0f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	57                   	push   %edi
  801a16:	52                   	push   %edx
  801a17:	ff 55 08             	call   *0x8(%ebp)
			break;
  801a1a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a20:	e9 bc fc ff ff       	jmp    8016e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	57                   	push   %edi
  801a29:	6a 25                	push   $0x25
  801a2b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	eb 02                	jmp    801a35 <vprintfmt+0x378>
  801a33:	89 c6                	mov    %eax,%esi
  801a35:	8d 46 ff             	lea    -0x1(%esi),%eax
  801a38:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a3c:	75 f5                	jne    801a33 <vprintfmt+0x376>
  801a3e:	e9 9e fc ff ff       	jmp    8016e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  801a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5f                   	pop    %edi
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 18             	sub    $0x18,%esp
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a5a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a5e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	74 26                	je     801a92 <vsnprintf+0x47>
  801a6c:	85 d2                	test   %edx,%edx
  801a6e:	7e 29                	jle    801a99 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a70:	ff 75 14             	pushl  0x14(%ebp)
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a79:	50                   	push   %eax
  801a7a:	68 86 16 80 00       	push   $0x801686
  801a7f:	e8 39 fc ff ff       	call   8016bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb 0c                	jmp    801a9e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a97:	eb 05                	jmp    801a9e <vsnprintf+0x53>
  801a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aa6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801aa9:	50                   	push   %eax
  801aaa:	ff 75 10             	pushl  0x10(%ebp)
  801aad:	ff 75 0c             	pushl  0xc(%ebp)
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 93 ff ff ff       	call   801a4b <vsnprintf>
	va_end(ap);

	return rc;
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    
	...

00801abc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801aca:	85 c0                	test   %eax,%eax
  801acc:	74 0e                	je     801adc <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	50                   	push   %eax
  801ad2:	e8 44 ec ff ff       	call   80071b <sys_ipc_recv>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	eb 10                	jmp    801aec <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	68 00 00 c0 ee       	push   $0xeec00000
  801ae4:	e8 32 ec ff ff       	call   80071b <sys_ipc_recv>
  801ae9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801aec:	85 c0                	test   %eax,%eax
  801aee:	75 26                	jne    801b16 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801af0:	85 f6                	test   %esi,%esi
  801af2:	74 0a                	je     801afe <ipc_recv+0x42>
  801af4:	a1 04 40 80 00       	mov    0x804004,%eax
  801af9:	8b 40 74             	mov    0x74(%eax),%eax
  801afc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801afe:	85 db                	test   %ebx,%ebx
  801b00:	74 0a                	je     801b0c <ipc_recv+0x50>
  801b02:	a1 04 40 80 00       	mov    0x804004,%eax
  801b07:	8b 40 78             	mov    0x78(%eax),%eax
  801b0a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b11:	8b 40 70             	mov    0x70(%eax),%eax
  801b14:	eb 14                	jmp    801b2a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b16:	85 f6                	test   %esi,%esi
  801b18:	74 06                	je     801b20 <ipc_recv+0x64>
  801b1a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	74 06                	je     801b2a <ipc_recv+0x6e>
  801b24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    

00801b31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	57                   	push   %edi
  801b35:	56                   	push   %esi
  801b36:	53                   	push   %ebx
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b40:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	75 25                	jne    801b6c <ipc_send+0x3b>
  801b47:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b4c:	eb 1e                	jmp    801b6c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b4e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b51:	75 07                	jne    801b5a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b53:	e8 a1 ea ff ff       	call   8005f9 <sys_yield>
  801b58:	eb 12                	jmp    801b6c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b5a:	50                   	push   %eax
  801b5b:	68 a0 22 80 00       	push   $0x8022a0
  801b60:	6a 43                	push   $0x43
  801b62:	68 b3 22 80 00       	push   $0x8022b3
  801b67:	e8 14 f9 ff ff       	call   801480 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	57                   	push   %edi
  801b6f:	ff 75 08             	pushl  0x8(%ebp)
  801b72:	e8 7f eb ff ff       	call   8006f6 <sys_ipc_try_send>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 d0                	jne    801b4e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5f                   	pop    %edi
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b8c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801b92:	74 1a                	je     801bae <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b94:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	c1 e2 07             	shl    $0x7,%edx
  801b9e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801ba5:	8b 52 50             	mov    0x50(%edx),%edx
  801ba8:	39 ca                	cmp    %ecx,%edx
  801baa:	75 18                	jne    801bc4 <ipc_find_env+0x3e>
  801bac:	eb 05                	jmp    801bb3 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bb3:	89 c2                	mov    %eax,%edx
  801bb5:	c1 e2 07             	shl    $0x7,%edx
  801bb8:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801bbf:	8b 40 40             	mov    0x40(%eax),%eax
  801bc2:	eb 0c                	jmp    801bd0 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc4:	40                   	inc    %eax
  801bc5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bca:	75 cd                	jne    801b99 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bcc:	66 b8 00 00          	mov    $0x0,%ax
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    
	...

00801bd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bda:	89 c2                	mov    %eax,%edx
  801bdc:	c1 ea 16             	shr    $0x16,%edx
  801bdf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801be6:	f6 c2 01             	test   $0x1,%dl
  801be9:	74 1e                	je     801c09 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801beb:	c1 e8 0c             	shr    $0xc,%eax
  801bee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bf5:	a8 01                	test   $0x1,%al
  801bf7:	74 17                	je     801c10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf9:	c1 e8 0c             	shr    $0xc,%eax
  801bfc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c03:	ef 
  801c04:	0f b7 c0             	movzwl %ax,%eax
  801c07:	eb 0c                	jmp    801c15 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	eb 05                	jmp    801c15 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    
	...

00801c18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	57                   	push   %edi
  801c1c:	56                   	push   %esi
  801c1d:	83 ec 10             	sub    $0x10,%esp
  801c20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c26:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c32:	85 c0                	test   %eax,%eax
  801c34:	75 2e                	jne    801c64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c36:	39 f1                	cmp    %esi,%ecx
  801c38:	77 5a                	ja     801c94 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c3a:	85 c9                	test   %ecx,%ecx
  801c3c:	75 0b                	jne    801c49 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c43:	31 d2                	xor    %edx,%edx
  801c45:	f7 f1                	div    %ecx
  801c47:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c49:	31 d2                	xor    %edx,%edx
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	f7 f1                	div    %ecx
  801c4f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c51:	89 f8                	mov    %edi,%eax
  801c53:	f7 f1                	div    %ecx
  801c55:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c57:	89 f8                	mov    %edi,%eax
  801c59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    
  801c62:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c64:	39 f0                	cmp    %esi,%eax
  801c66:	77 1c                	ja     801c84 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c68:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c6b:	83 f7 1f             	xor    $0x1f,%edi
  801c6e:	75 3c                	jne    801cac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c70:	39 f0                	cmp    %esi,%eax
  801c72:	0f 82 90 00 00 00    	jb     801d08 <__udivdi3+0xf0>
  801c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c7e:	0f 86 84 00 00 00    	jbe    801d08 <__udivdi3+0xf0>
  801c84:	31 f6                	xor    %esi,%esi
  801c86:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c88:	89 f8                	mov    %edi,%eax
  801c8a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    
  801c93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	f7 f1                	div    %ecx
  801c9a:	89 c7                	mov    %eax,%edi
  801c9c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c9e:	89 f8                	mov    %edi,%eax
  801ca0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    
  801ca9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cac:	89 f9                	mov    %edi,%ecx
  801cae:	d3 e0                	shl    %cl,%eax
  801cb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cb3:	b8 20 00 00 00       	mov    $0x20,%eax
  801cb8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbd:	88 c1                	mov    %al,%cl
  801cbf:	d3 ea                	shr    %cl,%edx
  801cc1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cc4:	09 ca                	or     %ecx,%edx
  801cc6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ccc:	89 f9                	mov    %edi,%ecx
  801cce:	d3 e2                	shl    %cl,%edx
  801cd0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cd3:	89 f2                	mov    %esi,%edx
  801cd5:	88 c1                	mov    %al,%cl
  801cd7:	d3 ea                	shr    %cl,%edx
  801cd9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801cdc:	89 f2                	mov    %esi,%edx
  801cde:	89 f9                	mov    %edi,%ecx
  801ce0:	d3 e2                	shl    %cl,%edx
  801ce2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ce5:	88 c1                	mov    %al,%cl
  801ce7:	d3 ee                	shr    %cl,%esi
  801ce9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ceb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cee:	89 f0                	mov    %esi,%eax
  801cf0:	89 ca                	mov    %ecx,%edx
  801cf2:	f7 75 ec             	divl   -0x14(%ebp)
  801cf5:	89 d1                	mov    %edx,%ecx
  801cf7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cf9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cfc:	39 d1                	cmp    %edx,%ecx
  801cfe:	72 28                	jb     801d28 <__udivdi3+0x110>
  801d00:	74 1a                	je     801d1c <__udivdi3+0x104>
  801d02:	89 f7                	mov    %esi,%edi
  801d04:	31 f6                	xor    %esi,%esi
  801d06:	eb 80                	jmp    801c88 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d08:	31 f6                	xor    %esi,%esi
  801d0a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    
  801d1a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d1f:	89 f9                	mov    %edi,%ecx
  801d21:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d23:	39 c2                	cmp    %eax,%edx
  801d25:	73 db                	jae    801d02 <__udivdi3+0xea>
  801d27:	90                   	nop
		{
		  q0--;
  801d28:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d2b:	31 f6                	xor    %esi,%esi
  801d2d:	e9 56 ff ff ff       	jmp    801c88 <__udivdi3+0x70>
	...

00801d34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	57                   	push   %edi
  801d38:	56                   	push   %esi
  801d39:	83 ec 20             	sub    $0x20,%esp
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d45:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d51:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d53:	85 ff                	test   %edi,%edi
  801d55:	75 15                	jne    801d6c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d57:	39 f1                	cmp    %esi,%ecx
  801d59:	0f 86 99 00 00 00    	jbe    801df8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d65:	83 c4 20             	add    $0x20,%esp
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	0f 87 a4 00 00 00    	ja     801e18 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d74:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d77:	83 f0 1f             	xor    $0x1f,%eax
  801d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d7d:	0f 84 a1 00 00 00    	je     801e24 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d83:	89 f8                	mov    %edi,%eax
  801d85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d88:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d8a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d8f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	d3 ea                	shr    %cl,%edx
  801d99:	09 c2                	or     %eax,%edx
  801d9b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801dad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db0:	d3 e0                	shl    %cl,%eax
  801db2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801db8:	89 f9                	mov    %edi,%ecx
  801dba:	d3 e8                	shr    %cl,%eax
  801dbc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dbe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	f7 75 f0             	divl   -0x10(%ebp)
  801dc5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dc7:	f7 65 f4             	mull   -0xc(%ebp)
  801dca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801dcd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dcf:	39 d6                	cmp    %edx,%esi
  801dd1:	72 71                	jb     801e44 <__umoddi3+0x110>
  801dd3:	74 7f                	je     801e54 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd8:	29 c8                	sub    %ecx,%eax
  801dda:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ddc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ddf:	d3 e8                	shr    %cl,%eax
  801de1:	89 f2                	mov    %esi,%edx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801de7:	09 d0                	or     %edx,%eax
  801de9:	89 f2                	mov    %esi,%edx
  801deb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df0:	83 c4 20             	add    $0x20,%esp
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    
  801df7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801df8:	85 c9                	test   %ecx,%ecx
  801dfa:	75 0b                	jne    801e07 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	f7 f1                	div    %ecx
  801e05:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	31 d2                	xor    %edx,%edx
  801e0b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e10:	f7 f1                	div    %ecx
  801e12:	e9 4a ff ff ff       	jmp    801d61 <__umoddi3+0x2d>
  801e17:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e18:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e1a:	83 c4 20             	add    $0x20,%esp
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    
  801e21:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e24:	39 f7                	cmp    %esi,%edi
  801e26:	72 05                	jb     801e2d <__umoddi3+0xf9>
  801e28:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e2b:	77 0c                	ja     801e39 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e32:	29 c8                	sub    %ecx,%eax
  801e34:	19 fa                	sbb    %edi,%edx
  801e36:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e3c:	83 c4 20             	add    $0x20,%esp
  801e3f:	5e                   	pop    %esi
  801e40:	5f                   	pop    %edi
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    
  801e43:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e44:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e47:	89 c1                	mov    %eax,%ecx
  801e49:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e4c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e4f:	eb 84                	jmp    801dd5 <__umoddi3+0xa1>
  801e51:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e57:	72 eb                	jb     801e44 <__umoddi3+0x110>
  801e59:	89 f2                	mov    %esi,%edx
  801e5b:	e9 75 ff ff ff       	jmp    801dd5 <__umoddi3+0xa1>
