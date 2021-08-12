# Initial process execs /init.
# This code runs in user space.

#include "syscall.h"
#include "traps.h"

/*
 * Frees the stack and calls exit() safely.
 *
 * PRECONDITION: The thread should be in the lowest-priority RR scheduler mode
 * before calling this function
 */
.globl free_stack_and_exit
free_stack_and_exit:
  # First, swap the stack to our free stack
  # Very first, grab a lock
  # Setup our bp and stuff...
  push %ebp
  mov %esp, %ebp

lock_loop:
  movl $1, %eax
  lock xchgl (stack_lock), %eax
  test %eax, %eax
  jnz lock_loop

  # Load our argument from the old stack
  mov 0x8(%ebp), %eax

  # Switch stacks
  mov %esp, (swap_stack + 0x100)
  push %ebp
  mov %esp, %ebp

  # Now, free the memory on the new stack
  pushl %eax
  call free

  # Release the lock
  xor %eax, %eax
  lock xchg %eax, stack_lock

  movl $SYS_exit, %eax
  # Never returns
  int $T_SYSCALL


.comm swap_stack, 0x100

stack_lock:
  .word 0
  .word 0

