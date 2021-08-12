#include "asm/x86.h"
#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "traps.h"
#include "spinlock.h"
#include "lab2_ag.h"

#define ZERO_PAGE(pa)    (pa == V2P(zero_page))

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
extern char pageref[];
extern struct spinlock pageref_lock;
extern char *zero_page;
uint ticks;

pde_t *
walkpgdir_trap(pde_t *pgdir, uint va) {
    pde_t *pde;
    pte_t *pgtab;

    pde = &pgdir[PDX(va)];
    if (*pde & PTE_P) {
        pgtab = (pte_t *) P2V(PTE_ADDR(*pde));
        return &pgtab[PTX(va)];
    } else {
        return 0;
    }
}


void
tvinit(void) {
    int i;

    for (i = 0; i < 256; i++) SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);

    initlock(&tickslock, "time");
}

void
idtinit(void) {
    lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf) {
    if (tf->trapno == T_SYSCALL) {
        if (myproc()->killed)
            exit();
        myproc()->tf = tf;
        syscall();
        if (myproc()->killed)
            exit();
        return;
    }

    switch (tf->trapno) {
        case T_IRQ0 + IRQ_TIMER:
            if (cpuid() == 0) {
                acquire(&tickslock);
                ticks++;
                wakeup(&ticks);
                release(&tickslock);
            }
            lapiceoi();
            break;
        case T_IRQ0 + IRQ_IDE:
            ideintr();
            lapiceoi();
            break;
        case T_IRQ0 + IRQ_IDE + 1:
            // Bochs generates spurious IDE1 interrupts.
            break;
        case T_IRQ0 + IRQ_KBD:
            kbdintr();
            lapiceoi();
            break;
        case T_IRQ0 + IRQ_COM1:
            uartintr();
            lapiceoi();
            break;
        case T_IRQ0 + 7:
        case T_IRQ0 + IRQ_SPURIOUS:
            cprintf("cpu%d: spurious interrupt at %x:%x\n",
                    cpuid(), tf->cs, tf->eip);
            lapiceoi();
            break;
        case T_PGFLT:
            lab2_report_pagefault(tf); //Report page fault
            uint va = PGROUNDDOWN(rcr2()); //Attempted va (rounded down to page)
            pte_t *pte = walkpgdir_trap(myproc()->pgdir, va); // Get pte for faulted page
            if (pte == 0) {
                //   cprintf("WESLEY: KILLING PROCESS BECAUSE pte did not exist\n");
                myproc()->killed = 1;
                break;
            }
            uint src = PTE_ADDR(*pte); //This is a physical address
            uint flags = PTE_FLAGS(*pte);
            uint pgind = PGIND(src);

            if ((tf->cs & 3) == DPL_USER && !(*pte & PTE_U)) {
               // 	cprintf("WESLEY: Trap was caused by process %d\n", myproc()->pid);

                 //   cprintf("WELSEY: Invalid Page: Killing Proc %d\n", myproc()->pid);
                  // cprintf("WESLEY: Tried to write to va %x, pa %x, flags %x\n", va, src, flags);

                myproc()->killed = 1;
                break;
            } else {
                //	cprintf("Trap was cased by kernel\n");
            }

            acquire(&pageref_lock);

            if (ZERO_PAGE(src)) {
                char *mem;
                if ((mem = kalloc()) == 0) {
                   // cprintf("WESLEY: Trap.c: Kalloc failed allocating Zero Page\n");
                    //cprintf("WESLEY: Killing proc %d\n", myproc()->pid);
                    myproc()->killed = 1;
                    goto PAGEFAULT_END;
//			while(1);
                }
                //Zero new mem
                lab2_pgzero(mem, va);
                //Give write access to this page
                *pte = V2P(mem) | flags | PTE_W;
                //We are done with this. Do not copy the page
                goto PAGEFAULT_END;
            }

            //Does more than one process refrence this physical page
            if (!(pageref[pgind])) {
                //No. This proc is the only one to refrence this page, update PTE_W
                *pte |= PTE_W;
                goto PAGEFAULT_END;
            }

            //Go and copy some pages..

            char *mem; //This will be a virtual address
            if ((mem = kalloc()) == 0) {
                //cprintf("Trap.c: Kalloc failed allocating Copy Page\n");
                //cprintf("Killing proc %d\n", myproc()->pid);
                myproc()->killed = 1;
                goto PAGEFAULT_END;
            }
            lab2_pgcopy(mem, (char *) V2P(src), va);
            //Update pte
            *pte = V2P(mem) | flags | PTE_W;
            //Update page refrence counter for src
            pageref[pgind]--;


        PAGEFAULT_END:
            invlpg((void *) va);
            release(&pageref_lock);
            break;
            //PAGEBREAK: 13
        default:
            if (myproc() == 0 || (tf->cs & 3) == 0) {
                // In kernel, it must be our mistake.
                cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
                        tf->trapno, cpuid(), tf->eip, rcr2());
                panic("trap");
            }
            // In user space, assume process misbehaved.
            cprintf("pid %d %s: trap %d err %d on cpu %d "
                    "eip 0x%x addr 0x%x--kill proc\n",
                    myproc()->pid, myproc()->name, tf->trapno,
                    tf->err, cpuid(), tf->eip, rcr2());
            myproc()->killed = 1;
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
        exit();

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    // NOTE(lab2): Disabled preemptive yield for testing.
    /*
    if(myproc() && myproc()->state == RUNNING &&
       tf->trapno == T_IRQ0+IRQ_TIMER)
      yield();
    */

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
        exit();
}
