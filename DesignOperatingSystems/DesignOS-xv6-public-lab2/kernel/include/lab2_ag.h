#ifndef __INCLUDE_LAB2_AG_h_
#define __INCLUDE_LAB2_AG_h_

#include "types.h"
#include "asm/x86.h"

void lab2_pgzero(void *va, uint user_va);
void lab2_pgcopy(void *dest, void *src, uint user_va);

void lab2_report_pagefault(struct trapframe *tf);

#endif  // __INCLUDE_LAB2_AG_h_
