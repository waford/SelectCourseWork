# Source files built along with the kernel

set(kernel_SOURCES
  # ASM Files
  src/asm/entry.S
  src/asm/swtch.S
  src/asm/trapasm.S

  # Generated
  gen/vectors.S

  # C Files
  src/bio.c
	src/console.c
	src/exec.c
	src/file.c
	src/fs.c
	src/ide.c
	src/ioapic.c
	src/kalloc.c
	src/kbd.c
	src/lapic.c
	src/log.c
	src/main.c
	src/mp.c
	src/picirq.c
	src/pipe.c
	src/proc.c
	src/sleeplock.c
	src/spinlock.c
	src/string.c
	src/syscall.c
	src/sysfile.c
	src/sysproc.c
	src/trap.c
	src/uart.c
	src/vm.c
  )

