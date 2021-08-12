#include "asm/x86.h"
#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

struct
{
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

struct
{
  struct proc *head;
  struct spinlock queuelock;
} queue;

void print_queue()
{
  struct proc *p = queue.head;
  cprintf("\n");
  while (p)
  {
    cprintf("%s(%d)->", p->name, p->pid);
    p = p->next;
  }
  cprintf("\n");
}
//Remove process with that pid from queue
void remove(uint pid)
{
  acquire(&queue.queuelock);
  struct proc *p = queue.head;
  if (p && p->pid == pid)
  {
    //Process was found at head
    queue.head = p->next;
    release(&queue.queuelock);
    return;
  }
  while (p && p->next)
  {
    if (p->next->pid != pid)
    {
      p = p->next;
    }
    else
    {
      break;
    }
  }
  if (p && p->next)
  {
    if (p->next->pid == pid)
    {
      p->next = p->next->next;
    }
  }
  release(&queue.queuelock);
}

struct proc *pop()
{
  acquire(&queue.queuelock);
  struct proc *p = queue.head;
  if (queue.head)
  {
    queue.head = queue.head->next;
  }
  release(&queue.queuelock);
  return p;
}

void push(struct proc *p)
{
  if (!p || p->pid <= 0)
  {
    //Proc is no good
    return;
  }
  acquire(&queue.queuelock);
  struct proc *curr = queue.head;
  if (!curr)
  {
    //List is empty
    queue.head = p;
    p->next = 0;
    release(&queue.queuelock);
    return;
  }
  else if ((curr->policy == p->policy || p->policy == SCHED_FIFO) && p->priority > curr->priority)
  {
    p->next = curr;
    queue.head = p;
    release(&queue.queuelock);
    return;
  }
  if (p->policy == SCHED_RR)
  {
    while (curr->next && curr->policy == SCHED_FIFO)
      curr = curr->next;

    while (curr->next && curr->next->priority >= p->priority)
      curr = curr->next;
  }
  else
  {
    //Must be FIFOi
    while (curr->next && curr->next->priority >= p->priority && curr->next->priority == SCHED_FIFO)
      curr = curr->next;
  }
  p->next = curr->next;
  curr->next = p;
  release(&queue.queuelock);
  //not positive on PUSH logic, could be a source of pain if there are bugs and its involved.
}

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

//Set scheduler sets a user-space process's scheduler policy & priority.
int setscheduler(int pid, int policy, int priority)
{
  if (pid <= 0 || (policy != SCHED_FIFO && policy != SCHED_RR) || priority < 0)
    return -1;
  pushcli();
  acquire(&ptable.lock);

  if (myproc()->pid == pid)
  {
    //Currently running, so we don't need to worry about prempting the processor
    myproc()->policy = policy;
    myproc()->priority = priority;
    release(&ptable.lock);
    popcli();
    yield();
  }
  else
  {
    for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {

      if (p->pid == pid && p->parent == myproc())
      {
        p->priority = priority;
        p->policy = policy;
        remove(p->pid);
        push(p);
        release(&ptable.lock);
        popcli();
        if ((p->policy == myproc()->policy && p->priority > myproc()->priority) || (p->policy == SCHED_FIFO && myproc()->policy == SCHED_RR))
          yield();
        return 0;
      }
    }
  }
  return 0;
}

void pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int cpuid()
{
  return mycpu() - cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
  int apicid, i;

  if (readeflags() & FL_IF)
    panic("mycpu called with interrupts enabled\n");

  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
  {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc *
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if (p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  // Set default policy and priority
  p->priority = 0;
  p->policy = SCHED_RR;
  p->next = 0;

  release(&ptable.lock);

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
  {
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe *)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint *)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context *)sp;
  //Don't need to call locks here because clone should be holding those locks
  p->context->eip = (uint)forkret;
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  initproc = p;
  if ((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0; // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  push(p); //put p in the queue

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();
  acquire(&curproc->tg->lk);
  if(curproc->sz != curproc->tg->sz)
    curproc->sz = curproc->tg->sz;
  sz = curproc->sz;
  if (n > 0)
  {
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0) {
      release(&curproc->tg->lk);
      return -1;
    }
  }
  else if (n < 0)
  {
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0) {
      release(&curproc->tg->lk);
      return -1;
    }
  }
  curproc->sz = sz;
  curproc->tg->sz = sz;
  release(&curproc->tg->lk);
  switchuvm(curproc);
  return 0;
}

int clone(void *stack, int stack_size)
{
  struct proc *np;
  struct proc *curproc = myproc();
  acquire(&curproc->tg->lk);
  uint *bp = (uint *)curproc->tf->ebp;
  uint *sp = (uint *)curproc->tf->esp;
  //Make sure both stack pointer and stack size are "inbounds"
  //What is upper bound on stack_size?
  uint stack_start = ((uint)stack + (uint)(stack_size - 4));
  //We want to memcpy everything between the bp's, and then increment bp's by
  //the offset from the start of the old stack to this one.

  //Deterime the start of the current processes stack (last return
  //addres is 0xffffffff)
  uint p_stack_start;
  while (*(bp + 1) != 0xffffffff)
  {
    bp = (uint *)*bp;
  }
  p_stack_start = (uint)(bp + 1);
  uint p_stack_size = p_stack_start - (uint)(sp);
  //uint stack_end = stack_start - stack_size;
  //uint p_stack_end = (uint)sp;

  //Checks if we have space to copy the parent stack, and that we are not writing over the old parent stack when we copy it.
  //if (p_stack_size > stack_size || (stack_end >= p_stack_start && stack_start <= p_stack_start) || (stack_end >= p_stack_end && stack_start <= p_stack_end))
  if(p_stack_size > stack_size || stack_start >= KERNBASE || (np = allocproc()) == 0) {
    release(&curproc->tg->lk);
    return -1;
  }
  
  uint new_sp = stack_start - p_stack_size;
  memmove((uint *)new_sp, (uint *)sp, p_stack_size + 4);
  //So much of this can be cleand up
  int offset = (int)stack_start - (int)p_stack_start;
  bp = (uint *)curproc->tf->ebp;
  uint new_bp = (uint)bp + offset;
  while (*(bp + 1) != 0xffffffff)
  {
    uint bp_tmp = *bp + offset;
    if(bp_tmp >= KERNBASE || *(bp+1) >= KERNBASE) {
      release(&curproc->tg->lk);
      return -1;
    }
    *(uint *)((uint)bp + offset) = bp_tmp;
    bp = (uint *)*bp;
  }
  release(&curproc->tg->lk);


  // Copy pr2cess state from proc.
  np->pgdir = curproc->pgdir;
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  np->tf->ebp = new_bp;
  np->tf->esp = new_sp;

  for (uint i = 0; i < NOFILE; i++)
    if (curproc->ofile[i])
      np->ofile[i] = curproc->tg->ofile[i];
  np->cwd = curproc->tg->cwd;

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  np->tg = curproc->tg;
  uint pid = np->pid;
  acquire(&ptable.lock);

  np->state = RUNNABLE;
  //ADD np to queue
  push(np);

  release(&ptable.lock);

  return pid;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if ((np = allocproc()) == 0)
  {
    return -1;
  }

  // Copy process state from proc.
  // if(curproc->pid == 2) {
  //   //This works lol
  //   curproc->sz = 0x4000;
  // }
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
  {
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for (i = 0; i < NOFILE; i++)
    if (curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  np->tg = np;
  initlock(&np->tg->lk, "TG LK");
  pid = np->pid;
  acquire(&ptable.lock);

  np->state = RUNNABLE;
  //ADD np to queue
  push(np);

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;
  if (curproc == initproc)
    panic("init exiting");

  // Close all open files.
  uint i = 0;
  for (fd = 0; fd < NOFILE; fd++)
  {
    
    if (curproc->ofile[fd] && curproc->pid == curproc->tg->pid)
    {
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
      i++;
    }
  }

  begin_op();
    if(curproc->pid == curproc->tg->pid)
      iput(curproc->cwd);
  end_op();
  if(curproc->pid == curproc->tg->pid) {
    curproc->cwd = 0;
  }

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->parent == curproc)
    {
      p->parent = initproc;
      if (p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->parent != curproc)
        continue;
      havekids = 1;
      if (p->state == ZOMBIE)
      {
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        if (p->tg->pid != curproc->tg->pid) {
           freevm(p->pgdir);
        }
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
    {
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  for (;;)
  {
    // Enable interrupts on this processor.
    sti();
    acquire(&ptable.lock);
    /*    // Loop over process table looking for process to run.
    acquire(&ptable.lock);/
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }

*/
    //Pop the first item off the queue. If its runnable, schedule it. Once it is done, check if it can be scheduled again
    p = pop();
    if (p && p->state == RUNNABLE)
    {
      //Process is runnable. Becasue it is at the head of the queue, it should be the highest priority process we have
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;
      //Jump into the process
      swtch(&(c->scheduler), p->context);
      //Process is done running for now, switch back to kvm
      switchkvm();
      //Check if process needs to be rescheduled
      if (p->state == RUNNABLE)
      {
        push(p);
      }

      c->proc = 0;
    }
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
  int intena;
  struct proc *p = myproc();

  if (!holding(&ptable.lock))
    panic("sched ptable.lock");
  if (mycpu()->ncli != 1)
    panic("sched locks");
  if (p->state == RUNNING)
    panic("sched running");
  if (readeflags() & FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void yield(void)
{
  acquire(&ptable.lock); //DOC: yieldlock
  myproc()->state = RUNNABLE;

  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first)
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  if (p == 0)
    panic("sleep");

  if (lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
  {                        //DOC: sleeplock0
    acquire(&ptable.lock); //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if (lk != &ptable.lock)
  { //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;
  //Dam this syntax
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if (p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
      push(p);
    }
}

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->pid == pid)
    {
      p->killed = 1;
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
  static char *states[] = {
      [UNUSED] "unused",
      [EMBRYO] "embryo",
      [SLEEPING] "sleep ",
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if (p->state == SLEEPING)
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
      for (i = 0; i < 10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
