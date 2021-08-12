#include "types.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"
#include "sched.h"
#include "stat.h"

void *thrd(void *arg) {
  // change our shared resource (cwd)
  int rc = chdir("tmp");
  if (rc == -1) { printf(1, "ERROR: chdir\n"); exit(); }
  return 0;
}

int main(void) {
  // create the tmp directory
  mkdir("tmp");

  // Put a file in tmp.
  int fd = open("tmp/test_tmpfil", O_CREATE | O_RDWR);
  if (fd == -1) { printf(1, "ERROR open tmp/test"); exit(); }
  close(fd);

  // create a child
  int rc = thread_create(thrd, 0);
  if (rc == -1) { printf(1, "ERROR: thread_create\n"); exit(); }

  rc = thread_wait();
  if (rc == -1) { printf(1, "ERROR: thread_wait\n"); exit(); }

  // NOTE: after thread_wait our cwd should be our old cwd + "tmp"
  fd = open("test_tmpfil", O_RDWR);
  if (fd == -1) { printf(1, "ERROR: test not found?  cwd is probably wrong?\n"); exit(); }
  else {
    printf(1, "Success, opened test after child chdir\n");
    close(fd);
  }

  exit();
}