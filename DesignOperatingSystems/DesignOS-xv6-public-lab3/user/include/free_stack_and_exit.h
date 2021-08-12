#ifndef __INCLUDE_free_stack_and_exit_h_
#define __INClUDE_free_stack_and_exit_h_

/**
 * Safely frees the stack pointed to by "stack" -- even if its the stack of the
 * currently running thread.  Then calls exit() safely.
 *
 * @param stack -- the stacks to be freed.
 * @return Doesn't return
 */
void free_stack_and_exit(void *stack) __attribute__((noreturn));

#endif  // __INCLUDE_free_stack_and_exit_h_

