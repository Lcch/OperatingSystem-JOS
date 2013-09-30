	.file	"init.c"
	.stabs	"kern/init.c",100,0,2,.Ltext0
	.text
.Ltext0:
	.stabs	"gcc2_compiled.",60,0,0,0
	.stabs	"int:t(0,1)=r(0,1);-2147483648;2147483647;",128,0,0,0
	.stabs	"char:t(0,2)=r(0,2);0;127;",128,0,0,0
	.stabs	"long int:t(0,3)=r(0,3);-2147483648;2147483647;",128,0,0,0
	.stabs	"unsigned int:t(0,4)=r(0,4);0;4294967295;",128,0,0,0
	.stabs	"long unsigned int:t(0,5)=r(0,5);0;4294967295;",128,0,0,0
	.stabs	"long long int:t(0,6)=r(0,6);-0;4294967295;",128,0,0,0
	.stabs	"long long unsigned int:t(0,7)=r(0,7);0;-1;",128,0,0,0
	.stabs	"short int:t(0,8)=r(0,8);-32768;32767;",128,0,0,0
	.stabs	"short unsigned int:t(0,9)=r(0,9);0;65535;",128,0,0,0
	.stabs	"signed char:t(0,10)=r(0,10);-128;127;",128,0,0,0
	.stabs	"unsigned char:t(0,11)=r(0,11);0;255;",128,0,0,0
	.stabs	"float:t(0,12)=r(0,1);4;0;",128,0,0,0
	.stabs	"double:t(0,13)=r(0,1);8;0;",128,0,0,0
	.stabs	"long double:t(0,14)=r(0,1);12;0;",128,0,0,0
	.stabs	"void:t(0,15)=(0,15)",128,0,0,0
	.stabs	"./inc/stdio.h",130,0,0,0
	.stabs	"./inc/stdarg.h",130,0,0,0
	.stabs	"va_list:t(2,1)=(2,2)=*(0,2)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.stabs	"./inc/string.h",130,0,0,0
	.stabs	"./inc/types.h",130,0,0,0
	.stabs	"bool:t(4,1)=(4,2)=eFalse:0,True:1,;",128,0,0,0
	.stabs	" :T(4,3)=efalse:0,true:1,;",128,0,0,0
	.stabs	"int8_t:t(4,4)=(0,10)",128,0,0,0
	.stabs	"uint8_t:t(4,5)=(0,11)",128,0,0,0
	.stabs	"int16_t:t(4,6)=(0,8)",128,0,0,0
	.stabs	"uint16_t:t(4,7)=(0,9)",128,0,0,0
	.stabs	"int32_t:t(4,8)=(0,1)",128,0,0,0
	.stabs	"uint32_t:t(4,9)=(0,4)",128,0,0,0
	.stabs	"int64_t:t(4,10)=(0,6)",128,0,0,0
	.stabs	"uint64_t:t(4,11)=(0,7)",128,0,0,0
	.stabs	"intptr_t:t(4,12)=(4,8)",128,0,0,0
	.stabs	"uintptr_t:t(4,13)=(4,9)",128,0,0,0
	.stabs	"physaddr_t:t(4,14)=(4,9)",128,0,0,0
	.stabs	"ppn_t:t(4,15)=(4,9)",128,0,0,0
	.stabs	"size_t:t(4,16)=(4,9)",128,0,0,0
	.stabs	"ssize_t:t(4,17)=(4,8)",128,0,0,0
	.stabs	"off_t:t(4,18)=(4,8)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"entering test_backtrace %d\n"
.LC1:
	.string	"leaving test_backtrace %d\n"
	.text
	.align 4
	.stabs	"test_backtrace:F(0,15)",36,0,0,test_backtrace
	.stabs	"x:p(0,1)",160,0,0,8
.globl test_backtrace
	.type	test_backtrace, @function
test_backtrace:
	.stabn	68,0,13,.LM0-.LFBB1
.LM0:
.LFBB1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$12, %esp
	movl	8(%ebp), %ebx
	.stabn	68,0,14,.LM1-.LFBB1
.LM1:
	pushl	%ebx
	pushl	$.LC0
	call	cprintf
	.stabn	68,0,15,.LM2-.LFBB1
.LM2:
	addl	$16, %esp
	testl	%ebx, %ebx
	jle	.L2
	.stabn	68,0,16,.LM3-.LFBB1
.LM3:
	subl	$12, %esp
	leal	-1(%ebx), %eax
	pushl	%eax
	call	test_backtrace
	addl	$16, %esp
.L3:
	.stabn	68,0,19,.LM4-.LFBB1
.LM4:
	subl	$8, %esp
	pushl	%ebx
	pushl	$.LC1
	call	cprintf
	addl	$16, %esp
	.stabn	68,0,20,.LM5-.LFBB1
.LM5:
	movl	-4(%ebp), %ebx
	leave
	ret
	.align 4
.L2:
	.stabn	68,0,18,.LM6-.LFBB1
.LM6:
	pushl	%eax
	pushl	$0
	pushl	$0
	pushl	$0
	call	mon_backtrace
	addl	$16, %esp
	jmp	.L3
	.size	test_backtrace, .-test_backtrace
	.stabs	"x:r(0,1)",64,0,0,3
.Lscope1:
	.section	.rodata.str1.1
.LC2:
	.string	"H%x Wo%s\n"
.LC3:
	.string	"6828 decimal is %o octal!\n"
	.text
	.align 4
	.stabs	"i386_init:F(0,15)",36,0,0,i386_init
.globl i386_init
	.type	i386_init, @function
i386_init:
	.stabn	68,0,24,.LM7-.LFBB2
.LM7:
.LFBB2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$28, %esp
	.stabn	68,0,30,.LM8-.LFBB2
.LM8:
	movl	$end, %eax
	subl	$edata, %eax
	pushl	%eax
	pushl	$0
	pushl	$edata
	call	memset
	.stabn	68,0,34,.LM9-.LFBB2
.LM9:
	call	cons_init
	.stabn	68,0,39,.LM10-.LFBB2
.LM10:
	movl	$6581362, -12(%ebp)
	.stabn	68,0,40,.LM11-.LFBB2
.LM11:
	addl	$12, %esp
	leal	-12(%ebp), %eax
	pushl	%eax
	pushl	$57616
	pushl	$.LC2
	call	cprintf
	.stabn	68,0,45,.LM12-.LFBB2
.LM12:
	popl	%edx
	popl	%ecx
	pushl	$6828
	pushl	$.LC3
	call	cprintf
	.stabn	68,0,48,.LM13-.LFBB2
.LM13:
	movl	$5, (%esp)
	call	test_backtrace
	addl	$16, %esp
	.align 4
.L6:
	.stabn	68,0,52,.LM14-.LFBB2
.LM14:
	subl	$12, %esp
	pushl	$0
	call	monitor
	addl	$16, %esp
	jmp	.L6
	.size	i386_init, .-i386_init
	.stabs	"i:(0,4)",128,0,0,-12
	.stabn	192,0,0,.LFBB2-.LFBB2
	.stabn	224,0,0,.Lscope2-.LFBB2
.Lscope2:
	.section	.rodata.str1.1
.LC4:
	.string	"kernel panic at %s:%d: "
.LC5:
	.string	"\n"
	.text
	.align 4
	.stabs	"_panic:F(0,15)",36,0,0,_panic
	.stabs	"file:p(0,16)=*(0,2)",160,0,0,8
	.stabs	"line:p(0,1)",160,0,0,12
	.stabs	"fmt:p(0,16)",160,0,0,16
.globl _panic
	.type	_panic, @function
_panic:
	.stabn	68,0,68,.LM15-.LFBB3
.LM15:
.LFBB3:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	movl	16(%ebp), %ebx
	.stabn	68,0,71,.LM16-.LFBB3
.LM16:
	cmpl	$0, panicstr
	je	.L11
	.align 4
.L10:
	.stabn	68,0,87,.LM17-.LFBB3
.LM17:
	subl	$12, %esp
	pushl	$0
	call	monitor
	addl	$16, %esp
	jmp	.L10
.L11:
	.stabn	68,0,73,.LM18-.LFBB3
.LM18:
	movl	%ebx, panicstr
	.stabn	68,0,76,.LM19-.LFBB3
.LM19:
/APP
/  76 "kern/init.c" 1
	cli; cld
/  0 "" 2
	.stabn	68,0,78,.LM20-.LFBB3
.LM20:
/NO_APP
	leal	20(%ebp), %esi
	.stabn	68,0,79,.LM21-.LFBB3
.LM21:
	pushl	%ecx
	pushl	12(%ebp)
	pushl	8(%ebp)
	pushl	$.LC4
	call	cprintf
	.stabn	68,0,80,.LM22-.LFBB3
.LM22:
	popl	%eax
	popl	%edx
	pushl	%esi
	pushl	%ebx
	call	vcprintf
	.stabn	68,0,81,.LM23-.LFBB3
.LM23:
	movl	$.LC5, (%esp)
	call	cprintf
	.stabn	68,0,82,.LM24-.LFBB3
.LM24:
	addl	$16, %esp
	jmp	.L10
	.size	_panic, .-_panic
	.stabs	"fmt:r(0,16)",64,0,0,3
.Lscope3:
	.section	.rodata.str1.1
.LC6:
	.string	"kernel warning at %s:%d: "
	.text
	.align 4
	.stabs	"_warn:F(0,15)",36,0,0,_warn
	.stabs	"file:p(0,16)",160,0,0,8
	.stabs	"line:p(0,1)",160,0,0,12
	.stabs	"fmt:p(0,16)",160,0,0,16
.globl _warn
	.type	_warn, @function
_warn:
	.stabn	68,0,93,.LM25-.LFBB4
.LM25:
.LFBB4:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$8, %esp
	.stabn	68,0,96,.LM26-.LFBB4
.LM26:
	leal	20(%ebp), %ebx
	.stabn	68,0,97,.LM27-.LFBB4
.LM27:
	pushl	12(%ebp)
	pushl	8(%ebp)
	pushl	$.LC6
	call	cprintf
	.stabn	68,0,98,.LM28-.LFBB4
.LM28:
	popl	%eax
	popl	%edx
	pushl	%ebx
	pushl	16(%ebp)
	call	vcprintf
	.stabn	68,0,99,.LM29-.LFBB4
.LM29:
	movl	$.LC5, (%esp)
	call	cprintf
	.stabn	68,0,100,.LM30-.LFBB4
.LM30:
	addl	$16, %esp
	.stabn	68,0,101,.LM31-.LFBB4
.LM31:
	movl	-4(%ebp), %ebx
	leave
	ret
	.size	_warn, .-_warn
.Lscope4:
	.comm	panicstr,4,4
	.stabs	"panicstr:G(0,16)",32,0,0,0
	.stabs	"",100,0,0,.Letext0
.Letext0:
	.ident	"GCC: (GNU) 4.5.1"
