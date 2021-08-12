# Lab0: Booting xv6

The goal of this lab is to get your environment setup, and some familiarity
gained with xv6, particularly the boot process (which you'll be modifying in lab
1), as well as to gain some familiarity with the tools we'll be using as a part
of this course.

This is the only lab where you will submit answers to questions, in prose.  All
other labs will be autograded, and based on code.

For this lab you will submit your answers to the canvas Lab0 assignment as a
txt, md, or pdf file by the due date and time given in the schedule.


## Downloading, Compiling, and Running xv6


Start by checking your your xv6 repository.  The following line will clone your
code into cs3210\_lab:

```bash
     git clone git@github.gatech.edu:cs3210-fall20/<youruniquename>-xv6-public.git cs3210_lab
```

Now, build your repository.  We recommend building within a separate build
directory:

```bash
  cd cs3210_lab
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=Debug
  make
```

This will build and install the kernel.  

**NOTE:** Depending on the state of your VM installation, you may have to install
some programs, such as gcc, make, cmake, to actually build the kernel.  Install
any missing programs as follows
```bash
  sudo apt install <programs>
```

If you have a new installation, we recommend installing at least:
```bash
  sudo apt install gcc build-essential cmake
```

Once make complete successfully you can try to boot the kernel by
running our xv6-qemu script (from within your build directory):

```bash
  ./xv6-qemu
```

This should launch xv6 and take you to prompt.  You can view avaialble files
with `ls`.  You can close qemu by pressing CTRL-a followed by x.

## Observing behaviors with gdb

Now, we're going to run our code with gdb.  We've attached a gdb flag to the xv6
launcher script, please launch the xv6 launcher with gdb enabled:

```bash
  ./xv6-qemu -g
```

This should pause qemu from launching, and wait for a gdb session to attach.
Now, in a separate terminal, launch gdb from your build directory:
```bash
  cd <your build directory>
  gdb
```

**NOTE:** gdb may give you an error.  Please follow the instructions they give
you to enable gdb to use our `.gdbinit` script to connect to qemu.

Once this is complete, it should take you to a gdb console, with the initial
BIOS `ljmp` instruction from the x86 machine's reset vector:
```
ljmp   $0xf000,$0xe05b
```

This is a 16-bit real-mode instruction (an obsure mode of the x86 processor run
at boot).  The 0xf000 is the real-mode segment, with 0xe05b the jumped to
address.  Look up real-mode addressing, what is the linear address to which it
is jumping? (question is ungraded)

Find the address of \_start, the entry point of the kernel:
```
$ nm kernel/kernel | grep _start
8010b50c D _binary_entryother_start
8010b4e0 D _binary_initcode_start
0010000c T _start
```


The kernel address is at 0010000c.

Open gdb in the same directory, set a break point and run to \_start as in the
following:

```
$ gdb
...
The target architecture is assumed to be i8086
[f000:fff0]    0xffff0: ljmp   $0xf000,$0xe05b
0x0000fff0 in ?? ()
+ symbol-file kernel
(gdb) br *0x0010000c
Breakpoint 1 at 0x10000c
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0x10000c:  mov    %cr4,%eax

Thread 1 hit Breakpoint 1, 0x0010000c in ?? ()
(gdb) 


Look at the registers and stack:

(gdb) info reg 
... 
(gdb) x/24x $esp 
... 
(gdb)
```

The stack grows from higher addresses to lower in x86, so items pushed on the
stack will be at higher addresses the earlier they were pushed on.

## Graded Questions:

Answer the following:

1. What address is the start (top) of the stack?

2. What items are on the stack at this point (pc = 0x10000c)?

To understand what is on the stack, you need to understand the boot procedure
because at this point the kernel has not started, so anything on the stack was
put there by the bootblock. Look at the files `bootblock/bootasm.S`,
`bootblock/bootmain.c`, and `build/bootblock/bootblock.asm`. Can you see what
they are putting on the stack?

3. Restart qemu and gdb as above but now set a break-point at 0x7c00. This is
the start of the boot block (`bootblock/bootasm.S`). Using the single
instruction step (si) step through the bootblock. Where is the stack pointer
initialized (filename, line)?

4. Single step into bootmain. Now look at the stack using x/24x $esp. What is
there?

5. What does the initial assembly of bootmain do to the stack? (Look in
bootblock.asm for bootmain.)

6. Continue tracing. You can use breakpoints to skip over things. Look for
where eip is set to 0x10000c. What happens to the stack as a result of that
call? Look at the bootmain C code and compare to the bootblock.asm assembly
code.

## Extra (not graded):

For thought: (let us know if you play with it!): Most modern OS's boot using a
firmware standard called UEFI instead of the older standard BIOS. Bootloaders
like grub are designed to support both standards. Thus, grub should be able to
boot xv6 on UEFI. Xv6 is not able to boot to the shell with UEFI because it has
significant dependencies on the BIOS firmware standard, but it is fairly
straightforward to allow the processor to reach the kernel entry point on UEFI
(before panicking as it tries to access the firmware.) Using grub, a UEFI
firmware load such as OVMF, and QEMU, show using gdb that you can reach the
kernel entry point. What did you have to change to get this working? (You may
use the 64-bit architecture qemu for this to avoid having to compile OVMF
32-bit.)

