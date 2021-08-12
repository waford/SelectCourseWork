# Lab 3 -- Scheduling and Threading

The purpose of this lab is to introduce you to the concepts of
scheduling and concurrency.  This lab consists primarily of two parts:  First,
you will be extending xv6's scheduler to support multiple new schedulers.
Second, you will be constructing a kernel-space threading library.

This is a *large* lab, larger than the labs you've done so far.  We've broken
into two largely independent components, part 1 and part 2.  We encourage you to
break the lab down into smaller pieces.  E.g.  complete part 1, then test it,
and submit it to the autograder.  There are many tests on the autograder which
depend only on part 1.

**NOTE:** Throughout this lab, you will have to test the concurrency of your
system.  You will have to run the `xv6-qemu` script with multiple cpus (default
is 1 cpu) using the `-c <CPUS>` or `--num-cpus=<CPUS>` flags.  We recommend
initial debugging with 1 cpu, to make things easier to parse, then further
debugging with additional cpus.

## Part 1 -- Scheduling

In this portion of the lab we will define a basic scheduler API, and build several new
schedulers.

#### Background
Recall the xv6 scheduler is found in `kernel/src/proc.c`, in the `scheduler()` function, and by
default implements a round robin (RR) scheduler. After each CPU is setup, all
eventually reach `mpmain()`, where `scheduler()` is called for the first time.
`scheduler()` loops over the process table in order looking for `RUNNABLE`
processes. When a `RUNNABLE` process is found, the kernel switches to that
process. It executes until it finishes or until a timer tick interrupts it and
causes the process to `yield()`.

Remember that the timer is a hardware interrupt. The code for handling this is
found in `kernel/src/trap.c`, around line 105.

```
// Force process to give up CPU on clock tick.
// If interrupts were on while locks held, would need to check nlock.
if (proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  yield();
```

`yield()` sets the current process to `RUNNABLE` and then switches directly to the
kernel scheduler.

### The Spec

For this portion of the lab, you will be enabling the user-space to specify
their scheduler policy.  You will:

- Enable the user-space to select their scheduling policy (`SCHED_RR`, or
  `SCHED_FIFO`)
- Enable the user-space process to set a priority.
- Implement two new schedulers: Round Robin with Priority and FIFO with Priority


#### Added System Call

To enable the user-space to set their scheduler policy, you will be adding one
system-call to the kernel:

```
int setscheduler(int pid, int policy, int priority);

Arguments:
pid - the pid of the process to change priority (a process may only change the
scheduler of themselves, or their direct children)
policy - the scheduler policy (SCHED_RR, SCHED_FIFO)
priority - the priority value to be set (any non-negative int value is
legal)

setscheduler should be declared in a program by including "user.h".
```

A user-space program should also be able to use the macros `SCHED_RR` and
`SCHED_FIFO` by including the file `include/sched.h` (typically through the
pre-processor directive `#include "sched.h"`).

#### The Schedulers

You will be building two schedulers for this lab, a Round Robin (RR), and a
First In First Out (FIFO) scheduler.  We will also be adding a notion of
priority to these schedulers.  We will explain the behaviors of these
schedulers without priority first, then add the notion of priority after.

##### Round Robin

Your Round Robin scheduler will logically create a circular buffer of processes
to run, and loops over the buffer.  It will run each process in the buffer for
either one scheduling quantum (unit of scheduling), or until the process becomes
non-runnable.  At which point it will select the next process in the circular
buffer.

For this lab you are to implement a round robin scheduler, much like the default
xv6 scheduler (note the default xv6 scheduler is a reasonable RR baseline, and you
may directly use that code, particularly for your non-priority scheduler).  Your
scheduler must:  Keep circular buffer of processes, then run those processes in order
assigning a time-quantum to each process.  Once that time quantum has expired, the
scheduler should run the next available process.

##### First-In-First-Out

The second scheduler you are to construct is the First-In-First-Out (FIFO) scheduler.
The FIFO scheduler logically keeps a list of processes, then runs them in-order.  Unlike
the RR scheduler, as long as the process at the head of the FIFO queue can make process,
it will not be preempted unless a higher priority process comes along (see the priorities
section).

There are two major  differences, between RR and FIFO.  1) FIFO will not yield to another
process of the same priority until the current process becomes un-runnable.  2) FIFO processes will
always run with higher priority than RR processes (e.g. if there are any
runnable FIFO processes, they should run before any RR processes).

##### Priorities

Now that we've specified the basics of FIFO and RR scheduling, we'll specify
our priority policy.

Each process has both a scheduler policy and priority.  When each of your
schedulers are selecting a process, the scheduler should obey the following
rules:

- FIFO policy processes always run before RR policy processes.
- Higher integral priority values correspond to higher logical priority.
- A process will not be scheduled if a higher priority process is runnable.  
- If two processes share priority, then they will run in scheduler order
  (as specified in the scheduler specification).
- When a new process becomes runnable, if it should run before the current
  process, your scheduler should immediately preempt the currently running process and
  shcedule it (with one exception, in "Nit").

##### Nit:
If another process becomes a better candidate than the currently running process
the kernel must immediately switch to running that process.

There is one exception to this rule. If there are multiple CPUs active, and an
action on CPU `c1` running process `p1` causes a process to become
RUNNABLE that is not higher priority than `p1`, but is higher priority than
process `p2` currently running on a different CPU `c2`, then `c2` need not
preempt `p2` until the first of: an interrupt to `c2`, `p2`'s completion, or an
event which causes `p2` to suspend.

#### Default Behavior

All processes should default to `SCHED_RR` with a priority of 0

## Part 2 -- Kernel Threading

What is a thread, and how do we build it?  Like a process, a thread represents
an independent execution context (all processes execute independently), however,
where processes have memory isolation, a thread shares its address space with
all of its peer threads.

In this part of lab3 you will be building a kernel threading library.  Like
Linux, you'll be treating threads as processes, however they share memory with
their neighboring threads.  Additionally, you'll be providing kernel support to
help build threading primitives on top of your threading library.

### The Kernel Threading

Your threading library will have two parts, a kernel implementation and a
user-space implementation.  We'll start with our kernel interface specification.

**NOTE:** This is a minimum kernel interface specification, you must build
at least these system calls.  However, if needed, you may build additional
system calls to aid you in your lab construction (although you may not modify
the interface of these system calls).

First, you'll need a way to create a new thread (a process that shares address
space with its parent).  For this lab, we'll be accomplishing this with our
version of the classic system call `clone()`:

```
int clone(void *stack, int stack_size)

Arguments:
  stack -- a pointer to the beginning of a memory region of size stack_size, to
           be used as the new thread's stack
  stack_size -- the size of the new thread's stack in bytes

Return:
  As with fork, clone returns twice on success (in the child and the parent).
  The returned values are:
    Parent - the pid of the child.
    Child - 0

  On error clone returns exactly once, with the value -1 (no child is created).

Behavior:
  On success clone creates a new process which shares its address space with its
  parent.  Additionally, clone sets up the child's stack to be logically
  equivalent to the parent's stack.  On clone the child's register state is
  equivalent to that of the parent, with two exceptions:  eax is 0 for the child
  and the pid of the child for the parent (recall eax is the return value of a system call), 
  and the esp of the child points to a location on the child's stack.
```

`clone()` creates a new process, and adds it to the caller's "thread group".
Processes within a "thread group" all share the same address space.  Thread
groups are created via either the `fork` or `exec` system calls.  The first
process within a thread group (the `fork`d or `exec`d process) is the thread
group's owner.  If the owner of a thread group terminates before the other
threads in the group, the behavior for those threads is undefined.

Clone should additionally follow these rules:

- Clone should fail cleanly on errors. If clone cannot run (for instance, if its
  passed a stack that's too small), it should return with an error.

- Cloned processes share several resources with their parent, namely:
   - Virtual address space (shared memory)
   - File descriptor table
   - Current working directory

When any thread makes a change to a shared resource (such as writing to memory,
allocating new memory, or changing the directory) that change should be visible
to all threads in that thread group. 

**NOTE:** Clone sets up its stack to be logically equivalent to its parents, however it
cannot just `memcpy` the stack.  What do you know about stacks that limits you
from doing this (think back to lab1's backtrace)?  How must clone adjust?

### The Thread Library

As part of this lab you will be required to create a (very simple) user-space threading
library to accompany your kernel `clone` functionality.  The library will include two funcitons:

```c
Function: thread_create
Arguments:
  - start_routine -- A function pointer to the routine that the child thread will run
  - arg -- the argument passed to start_routine
Return Value:
  - -1 on failure, pid of the created thread on success
Description:
Creates a new child thread.  That thread will immediately begin running start_routine,
as though invoked with start_routine(arg).

Definition:
int thread_create(void *(*start_routine)(void *), void *arg);


Function: thread_wait
Return Value:
  - -1 on failure, pid of the joined thread on success
Description:
Waits for a child thread to finish.

Definition:
int thread_wait();
```

These functions should be declared in `user/include/user.h`.  Be warned,
despite this simple interface, these funcitions actually have tricky implementations,
particularly when attempting to safely avoid memory leaks.

#### Nits

- All threads within a thread group share all shared resources.
- If a thread finishes before its children, the behavior of those children
  (threads spawned by this thread) is undefined.
- Any thread may spawn child threads.  `thread_wait` only waits for a child of the
  currently running thread to finish (It need not wait for its grandchildren or
  siblings).
- `thread_wait` should return the pid of the joined thread, or -1 on error.
- `thread_create` should return the pid of the created thread, or -1 on error.

## General Principles

Recall, a kernel's responsibility is to provide high-level abstractions to the
user-space. Any user-behavior shouldn't be able to break the abstractions
provided by the kernel. As such, user-state and user input to the kernel should
not allow the user-space to execute arbitrary code on the user's behalf, modify
arbitrary kernel memory, or crash the kernel. The autograder will try to crash
your kernel by providing unexpected user-space input! You should protect against
bad input that comes from user-space, just as a real kernel must protect against
malicious users.

Also, the kernel persists throughout the lifetime of the machine. As a result,
any OS code should be free of memory leaks and data-races. Your code should
error out correctly when given bad inputs, and shouldn't leak resources (memory,
process table entries, or fds, etc), even in the instance of failures.


## Autograder

As usual, you will submit this lab to the autograder.  As this lab is larger
than prior labs, we will give you some guidance as to what the autograder is
testing for.

### Tests

The tests in the autograder can roughly be classified as follows (NOTE: Some
tests, such as the those testing threading functionality may depend on prior
tests, such as the clone tests, or the scheduler tests -- Second NOTE: This is a
rough outline of what the tests look at, not a comprehensive list. Please
consult the spec for a clear outline of what is subject to testing).

Points assigned to tests: --
- Scheduler (20 points total)
  - Tests 1-10, 2 points each
- Clone Functionality (20 points total)
  - Tests 11-15 - 4 points each
- Clone error /security (9 points total)
  - Tests 19-21 - 3 points each
- Thread library general testing (20 points total)
  - Tests 22-26 - 4 points each
- Thread library error / security testing (12 points)
  - Tests 27-31 - 3 points each

