// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "fs.h"
#include "stat.h"

const char *path = "testPermFile";
const char *path1 = "testPermFile1";
const char *path2 = "testPermFile2";
const char *path3 = "testPermFile3";
const char *dir1 = "testdir1";
const char *dir2 = "testdir2";


int main(void)
{
  printf(1, "Testing Perms methods\n");
  //Create files and modify permissions 
  int fd = open(path, O_CREATE | O_RDWR);
  int fd1 = open(path1, O_CREATE | O_RDWR);
  int fd2 = open(path2, O_CREATE | O_RDWR);
  int fd3 = open(path3, O_CREATE | O_RDWR);

  chmod(path, PROT_R);
  chmod(path1, PROT_W);
  chmod(path2, PROT_R|PROT_W);

  struct stat fstat;
  stat(path, &fstat);
  printf(1, "FD: %d, Perms: %d\n", fstat.dev, fstat.perms);
  stat(path1, &fstat);
  printf(1, "FD: %d, Perms: %d\n", fstat.dev, fstat.perms);
  stat(path2, &fstat);
  printf(1, "FD: %d, Perms: %d\n", fstat.dev, fstat.perms);

  //Write to each file
  printf(fd, "Root Write\n");
  printf(fd1, "Root Write\n");
  printf(fd2, "Root Write\n");

  close(fd);
  close(fd1);
  close(fd2);
  close(fd3);

  mkdir(dir1);
  mkdir(dir2);
  chmod(dir2, PROT_R | PROT_W);
  if(stat(dir2, &fstat) != -1) {
    printf(1, "Perms: %x\n", fstat.perms);
  }
  mkdir("a");
  mkdir("a/b");
  mkdir("a/b/c");
  chmod("a", PROT_R);
  chmod("a/b", PROT_R);
  chmod("a/b/c", PROT_R | PROT_W);
  mknod("a/b/remove",0,0);
  mknod("a/b/c/remove", 0,0);
  printf(1, "\nPerms Tests done\n");

  exit();
}
