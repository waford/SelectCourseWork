.code16                       # Assemble for 16-bit mode

magic:
  .long 0x0534d4150

e820:
  .long 0xe820

# Only 16 bit.
dest_addr:
  .word 0x0


# The desetination adder (where the data will be stored) is passed in eax
# Makes the e820 bios call.  The result of the call will be stored in the
# address passed in ax (note only 16-bits available).
#
# The following information will be stored at *ax
# +0 : a 4-byte size field, containing the number of e820 records found
# +4 : an array of e820 records.
#
# E820 records are 24 bytes in size, and have the following format:
# +0 : an 8-byte physical_address field
# +8 : an 8-byte length field
# +16 : a 4-byte type field
# +20 : a 4 byte apic3 field (unused)
#
# The physical_address field contains the physical address of the RAM block
# The length field contains the number of bytes in this RAM block
# The type field contains the type of memory:
#   1 - usable
#   2 - reserved
#   3 - ACPI reclaimable
#   4 - ACPI NVS
#   5 - bad memory
#   -- for the purpose of this lab, we only care about type 1 memory
.globl do_e820
do_e820:
  mov %ax, (dest_addr)
  add $4, %ax
  mov %ax, %di
  xor %ebx, %ebx
  xor %bp, %bp
  mov (magic), %edx

.e820lp:
  mov (e820), %eax
  movl $1, %es:20(%di)
  mov $24, %ecx
  int $0x15
  jc .e820f
  mov (magic), %edx

  cmp %edx, %eax
  jne .e820f
  test %ebx, %ebx
  je .e820f
  jcxz .skipent
  cmp $20, %cl
  inc %bp		
  add $24, %di
.skipent:
  test %ebx, %ebx
  jne .e820lp
.e820f:
  xor %eax, %eax
  mov (dest_addr), %ax
  mov %bp, (%eax)
  ret

