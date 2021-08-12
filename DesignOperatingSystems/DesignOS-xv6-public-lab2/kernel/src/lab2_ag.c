
#include "lab2_ag.h"

#include "defs.h"
#include "mmu.h"
#include "types.h"

void lab2_pgzero(void *va, uint user_va) {
  cprintf("PGZERO: 0x%x\n", user_va);
  memset(va, 0, PGSIZE);
}

void lab2_pgcopy(void *dest, void *src, uint user_va) {
  cprintf("PGCOPY: 0x%x\n", user_va);
  memmove(dest, src, PGSIZE);
}

void lab2_report_pagefault(struct trapframe *tf) {
  uint va = rcr2();
  uint err = tf->err;
  cprintf("PGTRAP: err: 0x%x, va = 0x%x\n", err, va);
}


