// Fork tree test taken from CS3210 Fall20.
#include "types.h"
#include "stat.h"
#include "user.h"

#define DEPTH 3

void forktree(char *cur);

void forkchild(char *cur, char branch) {
  char nxt[DEPTH+1];

  if (strlen(cur) >= DEPTH)
    return;


  int idx = strlen(cur);
  strcpy(nxt, cur);
  nxt[idx] = branch;
  nxt[idx+1] = '\0';
  if (fork() == 0) {
    forktree(nxt);
    exit();
  } else {
    wait();
  }
}

void forktree(char *cur) {
  printf(1,"%d: I am '%s'\n", getpid(), cur);

  forkchild(cur, '0');
  forkchild(cur, '1');
}

  int
main(int argc, char **argv)
{
  forktree("");
  exit();
}

