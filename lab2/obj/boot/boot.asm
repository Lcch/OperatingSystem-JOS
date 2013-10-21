
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	68 7c 0f 20 c0       	push   $0xc0200f7c
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  movw    $10, %ax
    7c2d:	b8 0a 00 ea 35       	mov    $0x35ea000a,%eax

  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c32:	7c 08                	jl     7c3c <protcseg+0x7>
	...

00007c35 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c35:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c39:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c3b:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3d:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3f:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c41:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c48:	e8 c2 00 00 00       	call   7d0f <bootmain>

00007c4d <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4d:	eb fe                	jmp    7c4d <spin>
    7c4f:	90                   	nop

00007c50 <gdt>:
    7c50:	0f 00 10             	lldt   (%eax)
    7c53:	00 00                	add    %al,(%eax)
    7c55:	90                   	nop
    7c56:	c0 00 ff             	rolb   $0xff,(%eax)
    7c59:	ff 00                	incl   (%eax)
    7c5b:	00 00                	add    %al,(%eax)
    7c5d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c64:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c68 <gdtdesc>:
    7c68:	17                   	pop    %ss
    7c69:	00 50 7c             	add    %dl,0x7c(%eax)
    7c6c:	00 00                	add    %al,(%eax)
    7c6e:	90                   	nop
    7c6f:	90                   	nop

00007c70 <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c70:	55                   	push   %ebp
    7c71:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c73:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c78:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c79:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7e:	83 f8 40             	cmp    $0x40,%eax
    7c81:	75 f5                	jne    7c78 <waitdisk+0x8>
		/* do nothing */;
}
    7c83:	c9                   	leave  
    7c84:	c3                   	ret    

00007c85 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c85:	55                   	push   %ebp
    7c86:	89 e5                	mov    %esp,%ebp
    7c88:	57                   	push   %edi
    7c89:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// wait for disk to be ready
	waitdisk();
    7c8c:	e8 df ff ff ff       	call   7c70 <waitdisk>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c91:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c96:	b0 01                	mov    $0x1,%al
    7c98:	ee                   	out    %al,(%dx)
    7c99:	b2 f3                	mov    $0xf3,%dl
    7c9b:	89 f8                	mov    %edi,%eax
    7c9d:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
    7c9e:	89 f8                	mov    %edi,%eax
    7ca0:	c1 e8 08             	shr    $0x8,%eax
    7ca3:	b2 f4                	mov    $0xf4,%dl
    7ca5:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
    7ca6:	89 f8                	mov    %edi,%eax
    7ca8:	c1 e8 10             	shr    $0x10,%eax
    7cab:	b2 f5                	mov    $0xf5,%dl
    7cad:	ee                   	out    %al,(%dx)
	outb(0x1F6, (offset >> 24) | 0xE0);
    7cae:	c1 ef 18             	shr    $0x18,%edi
    7cb1:	89 f8                	mov    %edi,%eax
    7cb3:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb6:	b2 f6                	mov    $0xf6,%dl
    7cb8:	ee                   	out    %al,(%dx)
    7cb9:	b2 f7                	mov    $0xf7,%dl
    7cbb:	b0 20                	mov    $0x20,%al
    7cbd:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cbe:	e8 ad ff ff ff       	call   7c70 <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7cc3:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cc6:	b9 80 00 00 00       	mov    $0x80,%ecx
    7ccb:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cd0:	fc                   	cld    
    7cd1:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cd3:	5f                   	pop    %edi
    7cd4:	c9                   	leave  
    7cd5:	c3                   	ret    

00007cd6 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cd6:	55                   	push   %ebp
    7cd7:	89 e5                	mov    %esp,%ebp
    7cd9:	57                   	push   %edi
    7cda:	56                   	push   %esi
    7cdb:	53                   	push   %ebx
    7cdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cdf:	8b 75 10             	mov    0x10(%ebp),%esi
	uint32_t end_pa;

	end_pa = pa + count;
    7ce2:	8b 7d 0c             	mov    0xc(%ebp),%edi
    7ce5:	01 df                	add    %ebx,%edi

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
    7ce7:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7ced:	c1 ee 09             	shr    $0x9,%esi
    7cf0:	46                   	inc    %esi

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7cf1:	eb 10                	jmp    7d03 <readseg+0x2d>
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7cf3:	56                   	push   %esi
    7cf4:	53                   	push   %ebx
    7cf5:	e8 8b ff ff ff       	call   7c85 <readsect>
		pa += SECTSIZE;
    7cfa:	81 c3 00 02 00 00    	add    $0x200,%ebx
		offset++;
    7d00:	46                   	inc    %esi
    7d01:	58                   	pop    %eax
    7d02:	5a                   	pop    %edx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7d03:	39 fb                	cmp    %edi,%ebx
    7d05:	72 ec                	jb     7cf3 <readseg+0x1d>
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}
    7d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d0a:	5b                   	pop    %ebx
    7d0b:	5e                   	pop    %esi
    7d0c:	5f                   	pop    %edi
    7d0d:	c9                   	leave  
    7d0e:	c3                   	ret    

00007d0f <bootmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d0f:	55                   	push   %ebp
    7d10:	89 e5                	mov    %esp,%ebp
    7d12:	56                   	push   %esi
    7d13:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d14:	6a 00                	push   $0x0
    7d16:	68 00 10 00 00       	push   $0x1000
    7d1b:	68 00 00 01 00       	push   $0x10000
    7d20:	e8 b1 ff ff ff       	call   7cd6 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d25:	83 c4 0c             	add    $0xc,%esp
    7d28:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d2f:	45 4c 46 
    7d32:	75 39                	jne    7d6d <bootmain+0x5e>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d34:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
    7d3a:	81 c3 00 00 01 00    	add    $0x10000,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d40:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d47:	c1 e0 05             	shl    $0x5,%eax
    7d4a:	8d 34 03             	lea    (%ebx,%eax,1),%esi
	for (; ph < eph; ph++)
    7d4d:	eb 14                	jmp    7d63 <bootmain+0x54>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d4f:	ff 73 04             	pushl  0x4(%ebx)
    7d52:	ff 73 14             	pushl  0x14(%ebx)
    7d55:	ff 73 0c             	pushl  0xc(%ebx)
    7d58:	e8 79 ff ff ff       	call   7cd6 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d5d:	83 c3 20             	add    $0x20,%ebx
    7d60:	83 c4 0c             	add    $0xc,%esp
    7d63:	39 f3                	cmp    %esi,%ebx
    7d65:	72 e8                	jb     7d4f <bootmain+0x40>
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7d67:	ff 15 18 00 01 00    	call   *0x10018
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d6d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d72:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d77:	66 ef                	out    %ax,(%dx)
    7d79:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d7e:	66 ef                	out    %ax,(%dx)
    7d80:	eb fe                	jmp    7d80 <bootmain+0x71>
