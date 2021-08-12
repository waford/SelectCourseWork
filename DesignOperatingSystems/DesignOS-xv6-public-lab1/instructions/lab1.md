# Lab 1 - Getting to know Kernel Development

The goal of this lab is to get you familiar with kernel devlopment, and our xv6
environment.

The lab is composed of three parts:
 - First, you will use git to checkout, and build the repository. (ungraded, but
   required for the rest of the lab)
 - Second, you will add some debugging functionality to the xv6 kernel.
 - Third, you will get familiar with the boot procedure of xv6 by modifying the
   kernel to support variable memory sizes.


## Part 1 - checking out the repository

All of the code for this course will be distributed and turned in using the
[git](www.git-scm.com) revision system.  If you don't know git, we recommend
looking at the 
[Git User's Manual](www.kernel.org/pub/software/scm/git/docs/user-manual.html).
You may also find [this](eagain.net/articles/git-for-computer-scientists/)
overview helpful.

The xv6 repository we're using for this course is avaialble on Georgia Tech's
github:

```bash
git clone git@github.gatech.edu:cs3210-fall20/<your_uniquename>-xv6-public.git
```

For this lab, we will be using the lab1 branch within git.  You may switch to it
with:

```bash
git checkout lab1
```

Once you've checked out the lab, you'll want to build it.  We're using the [cmake](cmake-homepage)
build system this semester.  You may find more information about it
[here](cmake-manual).

For now, to build the lab, we encourage you building in a separate build
directory:

```bash
cd <YourLab1CheckoutDirectory>
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make
```

**NOTE: You may have to install gcc multilib support to get lab1 to build:**
```
sudo apt install gcc-multilib
```


**NOTE2: The above code uses a "Debug" build. This disables optimizations and
adds in debug symbols.  Its much easier to work with than a "Release" build, the
default CMAKE_BUILD_TYPE.  The autograder (more later) will run your code in
"Release" mode**

Once you've built xv6, you may launch your new kernel.  We've provided a
convenience script to help you launch it:

```bash
./xv6-qemu
```

This should take you to a shell prompt, where you can use your basic xv6
commands (try typing "ls" to see what files exist in your root directory).

You may terminate the qemu instance launched by the script by hitting
CTRL-a,x.

#### What's happening under the hood

Our xv6 kernel is an OS kernel, its made to run on bare-hardware.  However,
launching it on your PC seems like a bad idea, as it would overwrite your
existing OS.  Instead, we want to run it in a virtual environment that's much
more friendly for testing.  We could use a classic virtual machine (VM)
solution (e.g. VMWare or VirtualBox), but those are pretty heavy-weight, take a
long time to launch, and are hard to configure.  Instead, we use qemu, a machine
emulator.  Qemu emulates a cpu, causing it to look to the program running inside
of it like it has its own raw x86 CPU.  This is slow, and you may notice that xv6
actually runs really slowly in qemu, but its much more convenient for deubbing,
as launching and tearing down a qemu instance is very fast!  It is possible to
run xv6 on a more traditional VM, or even raw hardware! However, we wont require
that for the purpose of this course.

You can see the exact command used by turning on the verbose option to
`xv6-qemu` with `-v` or `--verbose`, and all available options with `-h`


## Part 2 - Modifying The Repository

Now that you have the kernel launching, we're going to make some changes to the
kernel.  The first change is adding [stack backtrace](https://en.wikipedia.org/wiki/Stack_trace)
support.  This exercise is aimed at getting you familiar with xv6, and some
low-level x86 behaviors and registers (including the stack).  Overall the
quantity of code you write for it will likely be small, but for most, it will
take a great deal of effort to write.

The second modification you'll be making to the kernel is to add variable memory
support.  That will get you experience with the xv6 bootup, a little familiarity
with system-call like behavior, and some assembly experience.  We'll cover that
more in Part 3.


### The Specification

For part 2 of the lab, you will be modifying the xv6 kernel to add
stack-trace support through a function named `backtrace`.  Backtrace has the
following specification:

```c
void backtrace();

Summary:
Prints the stack trace of any functions run within the kernel.
```

The format of the data printed is:
```
Backtrace:
   <0xaddress0> [top_of_stack_function_name]+offs1
   <0xaddress1> [next_function_in_stack_name]+offs2
   ...
   <0xaddressN> [last_function_in_stack]+offsN
```
**NOTE: there are three space characters (' ') preceeding each of the address lines.**

You must create a header `backtrace.h` (located in `kernel/include/`) with the declaration of the `backtrace()`
function (but not definition, definitons generally belong in c files), such that
any kernel file including `backtrace.h` may run the `backtrace()` function.

##### The format:
The backtrace function will print N+1 lines, where N is the number of functions in
the kernel's stack (excluding the backtrace function itself).  The first line
will read `Backtrace:`.

Each of the following N lines will have the following information and format (in
order from left to right):
-  three (3) spaces to start the line
-  The address of the next instruction to run in the stack, printed in lower-case hex, prefixed by "0x", surrounded on the left by a single `<` and on the right by a single `>`
-  a single space
-  The name of the function on the callstack
-  A single `+` character
-  A decimal number representing the offset from the start of that function in bytes
-  A newline character


So, if my codebase had a function named `foo`, starting on address `0x200` with
length `0x100` (e.g. ending at `0x300`), and my backtrace identified the return
address `0x210` on the stack, I would print the line:
```
   <0x210> foo+16
```

### Some Guidance:

To create this function, you'll have to handle three primary tasks:
1.  Identify return addresses on the function stack to identify the call-chain before this function
2.  Lookup the name of the function via its stack location
3.  Find the starting address of the function, and calculate its offset

The specific details about each of these tasks is as follows:

##### Stack Addresses:

Function calls are managed through the stack abstraction, you should have
learned about this extensively in CS2200 or equivalent.  If you're rusty on the
stack, you may find references [here](TODO-stackreference).

For this lab, you'll need to know to know how x86 handles some of these primitive stack
operations:

-  The stack pointer is maintained in the stack pointer `sp` register (`esp` in 32-bit mode)
-  The stack grows downwards (pushing decrements the stack pointer)
-  The `call` instruction, used to call functions implicitly pushes the return address of the call (the instruction after the call) onto the stack (e.g. after call `esp` will point to the return address used by the function)
-  The `ret` instruction pops the top of the stack and jumps to that address (basically undoing a call)
-  The base-pointer register (`bp` or `ebp` in 32-bit mode) points to the beginning of the stack frame for this function
-  The stack pointer points to the last pushed value (e.g. `push` decrements the stack pointer, then writes to the location pointed by it, and `pop` dereferences `esp`, then increments)
-  By convention, when a function is first called, the base-pointer is written to the stack, and stack-pointer is transferred into the base-pointer.

This forces the stack layout to appear as follows:

```
---------------------
|        ...        |
---------------------
|  Return Address 0 |  <-  First frame on the stack [0]
---------------------
|  Base Pointer 0   |  <- Not defined for first frame
---------------------
|        ...        |
---------------------
|  Local Variables  |
---------------------
|        ...        |
---------------------
|  Return Address 1 |  <-  Return address of the 2nd frame
---------------------
|  Base Pointer 1   |  <- Points to Base Pointer 0
---------------------
|        ...        |
---------------------
|  Local Variables  |
---------------------
|        ...        |
|        ...        |
|        ...        |
|        ...        |
---------------------
|  Return Address N |  <-  Return address of the 2nd frame
---------------------
|  Base Pointer N   |  <- Points to Base Pointer N-1 <= %ebp
---------------------
|        ...        |
---------------------
|  Local Variables  |
---------------------
|        ...        |
--------------------- <= %esp

Curent registers:

$esp: Top of current stack
$ebp: Base Pointer N
```

To ease your use of this lab, we provide you with the following helper macro
in `include/asm/x86.h`:

```c
// This is a define, so its always inlined
// Reads the current value of the register %ebp into the variable passed by
// dest.
// USAGE:
// int ebp;
// read_ebp(dest);
// -- dest now contains %ebp ---
#define read_ebp(dest)
```

#### Symbol Information:

Getting the name of the running function within the kernel is another huge
challenge.  Once I know the address of the function, how can I determine what
function was running?  If I were on a normal desktop, I could try to figure it
out from the binary file, but do I necessarily have a filesystem on all phases
of kernel boot?

Instead, the kernel has information embedded in its address space giving us some
information about the running symbols (e.g. the names of the functions that are
running, and the mapping from address to function name), we just need to parse
this information out of the address space.

##### STAB information

The kernel has embedded in its address space [STAB information](https://sourceware.org/gdb/current/onlinedocs/stabs/Overview.html).
This information is placed at special symbols called `__STAB_BEGIN__` and
`__STABSTR_BEGIN__`.  You can learn more about how we do this by exploring
[linker scripts](https://sourceware.org/binutils/docs/ld/Scripts.html), and
looking at ours in `kernel/kernel.ld`.

Having you write a library that parses the STAB information would be a little
too  tedious for a class project, so we have instead provided you with a stab
library in the file `kernel/stab.c` and its associated header
`kernel/include/stab.h`.  

The library includes the following relevant functions:

```c
// Populates info to contain the stab_info about the given eip.
// Returns 0 on success, non-zero on failure.
int stab_info(uint eip, struct stab_info *info);
```

Sometimes (in the instance of compiler optimizations or assembly functions) the 
`stab_info` function cannot find a symbol for a valid return address, in this instance
your backtrace function should print the function name as `<unknown>` with an offset of 0.

## Part 3 - Modifying boot.

This part of this lab will involve modifying the boot system of the kernel
to detect the amount of available RAM on the machine, then passing and utilizing
that information within the xv6 kernel.

**NOTE:** For much of this portion of the lab you will be modifying the kernel before its
console print infrastructure is set up, making debugging via print basically
impossible.  We strongly advise you to complete Lab 0 before attempting this
part of lab 1.

Before we get into the specifics of the lab, lets cover some background
knowledge.

### Background Information

Your computer has many essential low-level components, such as your RAM
controller, power supply, and other peripherals.  These components are fixed on
the motherboard and generally don't change.  They must also be set up properly,
in a device specific way before you can run any general purpose code on your
processor.  Think about it, how will your kernel load itself off the disk before
the disk driver is set up?

This problem, of bringing up the essential low-level devices on the machine and
loading your kernel into memory is what we'll call boot-loading.  Let's now
discuss the three phases of bootloading.

#### BIOS

To help enable the initial configuration and setup of these devices,
motherboards come with a BIOS (now commonly replaced by the more complex EFI
protocol), which sets up these devices, loads a single block of data from disk,
and provides support for additional hardware device queries.  When you first
launch xv6 (if you launch with gdb attached), you'll notice that the processor
starts at address 0xfff0, then jumps (if you use `si`, or step instruction) to
step to the next instruction, at address 0xe05b in the BIOS.

The low-level details of what the BIOS does are hardware specific and not
relevant for this course (if you're really interested, you can look at xv6's
[bios source](https://github.com/qemu/qemu/tree/master/pc-bios)).  What we care about for this course is the
handshake the bios makes with the actual kernel.

When the bios finishes running, it loads a single disk block (the first block on
disk) into the address 0x7c00, then jumps to and begins executing the code at
that location.  This is how control is passed from the BIOS to the kernel.
However, the kernel doesn't fit on a single block in disk, so we have to provide
one more boot layer to help load the kernel.  This layer is aptly called the
Boot Loader.

We will explore just a couple of details of the BIOS before we move onto the
boot loader, as they are fundamental to the BIOS construction.  First, the BIOS
isn't loaded from disk -- how could it be loaded from disk when it hasn't yet
initialized the disk controllers?  Instead the BIOS lives on its own ROM that
ships with your motherboard (or emulated rom for xv6).  This makes the BIOS
brittle, as it cannot easily be changed, and consequently we try to move as much
logic off of the BIOS as possible.  Additionally, the BIOS runs before the
boot loader (and hence kernel), and therefore must leave the processor in its
lowest configuration state (as if nothing had run), 16-bit real mode (we'll talk
more about this later), and any BIOS functions that run must also be run from
16-bit real mode.

#### Boot Loader (bootblock)

The boot loader is the first easily modifiable code that runs (it runs from the
first disk block), so it can be more complex and flexible than the BIOS.
However, the boot loader also operates in a constrained environment.  It starts
in 16-bit real mode (a mode of the x86 processor with 16-bit registers, and
physical addressing), with at most 512 bytes (1 disk block) of code.

The goal of the boot block is to set up the CPU for the kernel, then load the
kernel and pass it control (e.g. jump to the kernel's entry point).  You can
find the code for our boot loader in the `bootblock` directory.  The entry point
from the BIOS is `start` found in `bootblock/bootasm.S`.  Once the bootloader
has switched the processor into 32-bit mode, initialized the disk, and loaded the
kernel into memory, it jumps into the kernel at the end of `bootmain` in
`bootblock/bootmain.c`.

Modern bootloaders preform much more complex tasks than our bootblock, 
[GRUB](https://www.gnu.org/software/grub/) is an example of a modern boot loader.

#### Kernel Startup

The kernel goes through a long, arduous boot process, beginning at `entry` in
`kernel/src/asm/entry.S`, and continuing through much of kernel's `main` in
`kernel/src/main.c`.  This process will be relevant throughout the course, so
feel free to take a look at it.  However, we wont cover it in too much detail here.

### The Assignment

Currently, the kernel assumes it has `PHYSTOP` memory (defined in
`include/memlayout.h` as `0xE000000`).  This is a static memory assumption, so
regardless of what the attached machine has, the kernel will use exactly
`PHYSTOP` bytes of RAM.  This could be an issue in two ways, (1) the machine has
less than `PHYSTOP` memory, and the kernel assumes it has memory that doesn't
exist! or (2) the machine has much more memory, but the kernel cannot allow the
user-space to utilize it.

In this part of the lab, we're going to call into the BIOS, and have it tell us
how much memory is available, then we'll pass this information into our kernel
proper.  However, recall that the bios assumes the processor is running in
16-bit real mode (not the more common 32-bit mode that our kernel actually runs
in).  This means, we have to call the BIOS from the bootblock, before it
transitions us out of 16-bit real mode, and pass the information to the kernel
from there.

This part of your assignment has three sub-tasks:
1.  Get the available RAM from the bootblock
2.  Make that information available in the kernel
3.  Have the kernel read that information, and initialize its free memory structure based on the available RAM instead of an arbitrary `PHYSTOP`.

#### The BIOS Call.

As the BIOS is responsible for initializing and configuring the RAM controller,
it is our definitive source on how much RAM the machine has, and the logical
place to ask about allocated memory.  However, our bootloader cannot simply jump
into the BIOS (then our bootloader would be BIOS dependant, and we don't want
that), instead the BIOS exports an interface much like the system-call
interface.  We'll be making a BIOS call by interrupting and passing control into
the BIOS through the `int` instruction (much like system calls use the int
instruction).  Once this is done, the BIOS will pass us the information needed,
and return.

Recall that the BIOS runs before the boot loader, and must run in 16-bit
real-mode.  As a result, we must make our BIOS call from code running in 16-bit
real-mode.  Unfortunately, once the x86 cpu transitions into 32-bit mode, it
cannot revert to real-mode.  This means, we must make our BIOS call before the
CPU converts to 32-bit mode, in the bootloader.


As the BIOS call is tedious and complex, we wont require you to actually write
the assembly for the call itself, we've provided that method detailed below.
Your job is to place the call at the appropriate location, and handle putting
that memory in a location the kernel can read from.  The bios call is defined in
`bootblock/e820.S`

```asm
# The desetination adder (where the data will be stored) is passed in ax
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
```

More information on the e820 bios call can be found
[here](https://wiki.osdev.org/Detecting_Memory_(x86)#BIOS_Function:_INT_0x15.2C_EAX_.3D_0xE820).
For the purpose of this lab, we're going to assume the call behaves well
(regions are reported in-order, and non-overlapping).

#### The Kernel.

Once you have the memory passed to the kernel, your job within the kernel is
make it aware of the amount and location of physical memory, and to enable the
kernel to use that physical memory from its `kalloc` function.  For simplicity,
we will only require you to change how the kernel handles extended memory
(ram available at physical addresses above the BIOs).  After you have
completed this lab the kernel should be able to allocate all non-statically
allocated physical pages present in extended memory from the `kalloc` function,
and `kalloc` should never return a physical page that isn't present on the system.

We encourage you to familiarize yourself with the kernel's `kinit` functions,
and physical memory allocation functions, as they will likely be useful in
completing this exercise

## Grading

As with all labs in this course, the lab has an associated autograder.  The
policies and rules of the autograder may be found on the class
[syllabus](https://gatech.instructure.com/courses/140830/assignments/syllabus) and the
[autograder page](https://github.gatech.edu/cs3210-fall20/xv6-public/blob/main/instructions/autograder_instructions.md).
You will submit your code to the auto-grader for
auto-grading.  There will also be a hand graded portion of this lab, worth 15%
of your lab grade.  Finally, this is our only *individual* lab, you cannot
collaborate or share code with others (although discussion is allowed).  Your
code will be checked for cheating, and any detection of shared code, or pulling
code from the internet will be harshly punished.

To submit to the autograder, first push your code into your class repository.
Your code must be pushed to the `lab1` branch.  Then, visit the autograder's web
interface [here](https://cs3210-autograder.cc.gatech.edu) (Note, you'll have to be
on the gatech network -- e.g. through vpn -- to access the autograder site).  Authenticate with github,
then submit your lab1 code for grading.  The lab1 code will be automatically
pulled from github, and graded by the autograder.  You should see interactive
feedback on the website, as well as receive an email once the grading is
finished.  This lab is subject to all [autograder policies](todo), please review
them before submitting.

**NOTE:** Any unauthorized attempt to subvert or attack the autograder will be
considered a violation of academic integrity, and will be punished.  The
autograder logs all submissions both locally and remotely, so any submission may
be audited.


## Extra

If you're begging for more after this assignment, you may consider trying some
of the following projects (no credit given, just fun experiments):
-  Explore what it takes to get the xv6 kernel to boot with a commodity bootloader (e.g. Grub), why is this hard?
-  Can the xv6 bootblock be made to work with an EFI (instead of BIOS) based bootloader?  What does that take?
-  Can you get xv6 to use (not just recognize) arbitrarily large amounts of physical memory? (up to 4GB)  This is very challenging, but also very interesting!  (Its also highly related to lab 2)  (Even harder, you can use over 4GB of physical memory with PAE)
